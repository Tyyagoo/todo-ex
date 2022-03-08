defmodule TodoEx.Database do
  use GenServer

  @path "./db"

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  @doc """
  Starts a new Database server.
  If this server is already started, only return it's pid.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_) do
    IO.puts("[DatabaseServer]: Starting...")

    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Asynchronously stores data in a file named `key`.
  """
  @spec store(key :: String.t(), data :: term()) :: :ok
  def store(key, data) do
    worker = choose_worker(key)
    GenServer.cast(__MODULE__, {:store, key, data, worker})
  end

  @doc """
  Read data from the `key` file synchronously.
  """
  @spec get(key :: String.t()) :: term()
  def get(key) do
    worker = choose_worker(key)
    GenServer.call(__MODULE__, {:get, key, worker})
  end

  @spec choose_worker(key :: String.t()) :: pid()
  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  @doc false
  @impl GenServer
  def init(_) do
    workers =
      0..2
      |> Stream.map(fn i -> {i, TodoEx.Database.Worker.start_link(@path)} end)
      |> Enum.into(%{})

    case File.mkdir_p(@path) do
      :ok -> {:ok, workers}
      {:error, reason} -> {:stop, reason}
    end
  end

  @doc false
  @impl GenServer
  def handle_cast({:store, key, data, worker}, state) do
    GenServer.cast(worker, {:store, key, data})
    {:noreply, state}
  end

  @doc false
  @impl GenServer
  def handle_call({:get, key, worker}, caller, state) do
    GenServer.cast(worker, {:get, key, caller})
    {:noreply, state}
  end

  def handle_call({:choose_worker, key}, _, state) do
    {:reply, Map.get(state, :erlang.phash2(key, 3)), state}
  end
end

defmodule TodoEx.Database.Worker do
  use GenServer

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  def start_link(path) do
    IO.puts("[DatabaseWorkerServer]: Starting...")

    {:ok, pid} = GenServer.start_link(__MODULE__, path)
    pid
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  @doc false
  @impl GenServer
  def init(path) do
    {:ok, path}
  end

  @doc false
  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    file_name(state, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_cast({:get, key, caller}, state) do
    data =
      file_name(state, key)
      |> File.read()
      |> case do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    GenServer.reply(caller, data)
    {:noreply, state}
  end

  defp file_name(path, key) do
    Path.join(path, key)
  end
end

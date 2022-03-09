defmodule TodoEx.Database do
  alias TodoEx.Database.Worker

  @path "./db"
  @pool_size 5

  @doc """
  Asynchronously stores data in a file named `key`.
  """
  @spec store(key :: String.t(), data :: term()) :: :ok
  def store(key, data) do
    :poolboy.transaction(__MODULE__, &Worker.store(&1, key, data))
  end

  @doc """
  Read data from the `key` file synchronously.
  """
  @spec get(key :: String.t()) :: term()
  def get(key) do
    :poolboy.transaction(__MODULE__, &Worker.get(&1, key))
  end

  def child_spec(_) do
    IO.puts("[DatabaseSupervisor]: Starting...")
    File.mkdir_p!(@path)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Worker,
        size: 5
      ],
      [@path]
    )
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
    GenServer.start_link(__MODULE__, path)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
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

  @doc false
  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data =
      file_name(state, key)
      |> File.read()
      |> case do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(path, key) do
    Path.join(path, key)
  end
end

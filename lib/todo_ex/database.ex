defmodule TodoEx.Database do
  alias TodoEx.Database.Worker

  @path "./db"
  @pool_size 5

  @doc """
  Starts a new Database Supervisor.
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    IO.puts("[DatabaseSupervisor]: Starting...")
    File.mkdir_p!(@path)

    1..@pool_size
    |> Enum.map(&worker_spec/1)
    |> Supervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @doc """
  Asynchronously stores data in a file named `key`.
  """
  @spec store(key :: String.t(), data :: term()) :: :ok
  def store(key, data) do
    key
    |> choose_worker()
    |> Worker.store(key, data)
  end

  @doc """
  Read data from the `key` file synchronously.
  """
  @spec get(key :: String.t()) :: term()
  def get(key) do
    key
    |> choose_worker()
    |> Worker.get(key)
  end

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  @spec choose_worker(key :: String.t()) :: non_neg_integer()
  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  @spec worker_spec(worker_id :: non_neg_integer()) :: Supervisor.child_spec()
  defp worker_spec(worker_id) do
    default = {Worker, {@path, worker_id}}
    Supervisor.child_spec(default, id: worker_id)
  end
end

defmodule TodoEx.Database.Worker do
  use GenServer

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  def start_link({path, id}) do
    IO.puts("[DatabaseWorkerServer@#{id}]: Starting...")
    GenServer.start_link(__MODULE__, path, name: via(id))
  end

  def store(id, key, data) do
    GenServer.cast(via(id), {:store, key, data})
  end

  def get(id, key) do
    GenServer.call(via(id), {:get, key})
  end

  defp via(id) do
    TodoEx.ProcessRegistry.via({__MODULE__, id})
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

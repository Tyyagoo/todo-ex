defmodule TodoEx.Cache do
  use GenServer
  alias TodoEx.Server

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  @doc """
  Starts an Cache Server that keeps `name~pid` of TodoListServer's.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_) do
    IO.puts("[CacheServer]: Starting...")

    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Receives an name and always return a pid.
  If the server already exists, it only return it's pid.
  If the server doesn't exist, it creates a new one and return it's pid.
  """
  @spec server_process(todo_list_name :: String.t()) :: pid()
  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  @doc false
  @impl GenServer
  def init(initial_state) do
    {:ok, initial_state}
  end

  @doc false
  @impl GenServer
  def handle_call({:server_process, name}, _, state) do
    case Map.fetch(state, name) do
      {:ok, server_pid} ->
        {:reply, server_pid, state}

      :error ->
        server_pid = Server.start_link(name)
        {:reply, server_pid, Map.put(state, name, server_pid)}
    end
  end
end

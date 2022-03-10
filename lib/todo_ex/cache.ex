defmodule TodoEx.Cache do
  alias TodoEx.Server

  @doc """
  Starts an Cache Supervisor that is useful to start and retrieve TodoListServer's.
  """
  @spec start_link() :: GenServer.on_start()
  def start_link() do
    IO.puts("[CacheSupervisor]: Starting...")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @doc """
  Receives an name and always return a pid.
  If the server already exists, it only return it's pid.
  If the server doesn't exist, it creates a new one and return it's pid.
  """
  @spec server_process(todo_list_name :: String.t()) :: pid()
  def server_process(todo_list_name) do
    existing_server(todo_list_name) || new_server(todo_list_name)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp existing_server(todo_list_name) do
    Server.whereis(todo_list_name)
  end

  defp new_server(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(__MODULE__, {Server, todo_list_name})
  end
end

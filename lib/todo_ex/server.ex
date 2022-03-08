defmodule TodoEx.Server do
  use GenServer, restart: :temporary
  alias TodoEx.{Database, Entry, List}

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  @doc """
  Starts an stateful process to handle TodoList operations.
  """
  @spec start_link(name :: String.t()) :: GenServer.on_start()
  def start_link(name) when is_binary(name) do
    IO.puts("[TodoListServer@#{name}]: Starting...")
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  @doc """
  Cast an `fire & forget` operation into the process that's adds an Entry to TodoList.
  """
  @spec add_entry(pid :: pid(), entry :: Entry.t()) :: :ok
  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  @doc """
  Cast an `fire & forget` operation into the process that's removes an Entry from TodoList.
  """
  @spec delete_entry(pid :: pid(), id :: non_neg_integer()) :: :ok
  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  @doc """
  Cast an `fire & forget` operation into the process that's updates an Entry on TodoList.
  """
  @spec update_entry(pid :: pid(), id :: non_neg_integer(), content :: map()) :: :ok
  def update_entry(pid, id, content) do
    GenServer.cast(pid, {:update_entry, id, content})
  end

  @doc """
  Query an specific entry from TodoList process and awaits the response.
  """
  @spec entry(pid :: pid(), id :: non_neg_integer()) :: Entry.t() | nil
  def entry(pid, id) do
    GenServer.call(pid, {:query_entry, id})
  end

  @doc """
  Query all entries from TodoList process and awaits the response.
  """
  @spec entries(pid :: pid()) :: list(Entry.t())
  def entries(pid) do
    GenServer.call(pid, :query_all_entries)
  end

  @doc """
  Query all entries of the desired date from TodoList process and awaits the response.
  """
  @spec entries(pid :: pid(), date :: Date.t()) :: list(Entry.t())
  def entries(pid, date) do
    GenServer.call(pid, {:query_entries_by_date, date})
  end

  defp via(name) do
    TodoEx.ProcessRegistry.via({__MODULE__, name})
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  @doc false
  @impl GenServer
  def init(name) do
    send(self(), :initialize)
    {:ok, {name, nil}}
  end

  @doc false
  @impl GenServer
  def handle_info(:initialize, {name, nil}) do
    initial_state = Database.get(name) || List.new()
    {:noreply, {name, initial_state}}
  end

  @doc false
  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, list}) do
    new_list = List.add_entry(list, entry)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:delete_entry, id}, {name, list}) do
    new_list = List.delete_entry(list, id)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:update_entry, id, content}, {name, list}) do
    new_list = List.update_entry(list, id, content)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @doc false
  @impl GenServer
  def handle_call({:query_entry, id}, _, {_, list} = state) do
    {:reply, List.entry(list, id), state}
  end

  def handle_call(:query_all_entries, _, {_, list} = state) do
    {:reply, List.entries(list), state}
  end

  def handle_call({:query_entries_by_date, date}, _, {_, list} = state) do
    {:reply, List.entries(list, date), state}
  end
end

defmodule TodoEx.Server do
  use GenServer
  alias TodoEx.{Entry, List}

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  @doc """
  Starts an stateful process to handle TodoList operations with an desired initial state.
  """
  @spec start(initial_state :: list()) :: pid()
  def start(initial_state \\ []) when is_list(initial_state) do
    {:ok, pid} = GenServer.start(__MODULE__, initial_state, name: __MODULE__)
    pid
  end

  @doc """
  Cast an `fire & forget` operation into the process that's adds an Entry to TodoList.
  """
  @spec add_entry(entry :: Entry.t()) :: :ok
  def add_entry(entry) do
    GenServer.cast(__MODULE__, {:add_entry, entry})
  end

  @doc """
  Cast an `fire & forget` operation into the process that's removes an Entry from TodoList.
  """
  @spec delete_entry(id :: non_neg_integer()) :: :ok
  def delete_entry(id) do
    GenServer.cast(__MODULE__, {:delete_entry, id})
  end

  @doc """
  Cast an `fire & forget` operation into the process that's updates an Entry on TodoList.
  """
  @spec update_entry(id :: non_neg_integer(), content :: map()) :: :ok
  def update_entry(id, content) do
    GenServer.cast(__MODULE__, {:update_entry, id, content})
  end

  @doc """
  Query an specific entry from TodoList process and awaits the response.
  """
  @spec entry(id :: non_neg_integer()) :: Entry.t() | nil
  def entry(id) do
    GenServer.call(__MODULE__, {:query_entry, id})
  end

  @doc """
  Query all entries from TodoList process and awaits the response.
  """
  @spec entries() :: list(Entry.t())
  def entries() do
    GenServer.call(__MODULE__, :query_all_entries)
  end

  @doc """
  Query all entries of the desired date from TodoList process and awaits the response.
  """
  @spec entries(date :: Date.t()) :: list(Entry.t())
  def entries(date) do
    GenServer.call(__MODULE__, {:query_entries_by_date, date})
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  @doc false
  @impl GenServer
  def init(initial_state) do
    {:ok, List.new(initial_state)}
  end

  @doc false
  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {:noreply, List.add_entry(state, entry)}
  end

  def handle_cast({:delete_entry, id}, state) do
    {:noreply, List.delete_entry(state, id)}
  end

  def handle_cast({:update_entry, id, content}, state) do
    {:noreply, List.update_entry(state, id, content)}
  end

  @doc false
  @impl GenServer
  def handle_call({:query_entry, id}, _, state) do
    {:reply, List.entry(state, id), state}
  end

  def handle_call(:query_all_entries, _, state) do
    {:reply, List.entries(state), state}
  end

  def handle_call({:query_entries_by_date, date}, _, state) do
    {:reply, List.entries(state, date), state}
  end
end

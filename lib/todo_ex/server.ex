defmodule TodoEx.Server do
  alias TodoEx.{Entry, List}

  #   _____________________
  # ((                    ))
  # )) Client   Interface ((
  # ((                    ))
  #  ---------------------

  @doc """
  Starts an stateful process to handle TodoList operations.
  """
  @spec start() :: pid()
  def start(), do: start(List.new())

  @doc """
  Starts an stateful process to handle TodoList operations with an desired initial state.
  """
  @spec start(initial_state :: List.t()) :: pid()
  def start(%List{} = initial_state) do
    spawn(fn ->
      loop(initial_state)
    end)
  end

  @doc """
  Cast an `fire & forget` operation into the process that's adds an Entry to TodoList.
  """
  @spec add_entry(pid :: pid(), entry :: Entry.t()) :: pid()
  def add_entry(pid, entry) do
    send(pid, {:add_entry, entry})
    pid
  end

  @doc """
  Cast an `fire & forget` operation into the process that's removes an Entry from TodoList.
  """
  @spec delete_entry(pid :: pid(), id :: non_neg_integer()) :: pid()
  def delete_entry(pid, id) do
    send(pid, {:delete_entry, id})
    pid
  end

  @doc """
  Cast an `fire & forget` operation into the process that's updates an Entry on TodoList.
  """
  @spec update_entry(pid :: pid(), id :: non_neg_integer(), content :: map()) :: pid()
  def update_entry(pid, id, content) do
    send(pid, {:update_entry, id, content})
    pid
  end

  @doc """
  Query an specific entry from TodoList process and awaits the response.
  """
  @spec entry(pid :: pid, id :: non_neg_integer()) :: Entry.t() | nil
  def entry(pid, id) do
    send(pid, {:query_entry, self(), id})

    receive do
      {:reply, response} -> response
    end
  end

  @doc """
  Query all entries from TodoList process and awaits the response.
  """
  @spec entries(pid :: pid) :: list(Entry.t())
  def entries(pid) do
    send(pid, {:query_all_entries, self()})

    receive do
      {:reply, response} -> response
    end
  end

  @doc """
  Query all entries of the desired date from TodoList process and awaits the response.
  """
  @spec entries(pid :: pid, date :: Date.t()) :: Entry.t() | nil
  def entries(pid, date) do
    send(pid, {:query_entries_by_date, self(), date})

    receive do
      {:reply, response} -> response
    end
  end

  #   __________________________
  # ((                         ))
  # )) Server   Implementation ((
  # ((                         ))
  #  --------------------------

  defp loop(state) do
    receive do
      msg -> handle_message(msg, state)
    end
    |> loop()
  end

  defp handle_message({:add_entry, entry}, state) do
    List.add_entry(state, entry)
  end

  defp handle_message({:delete_entry, id}, state) do
    List.delete_entry(state, id)
  end

  defp handle_message({:update_entry, id, content}, state) do
    List.update_entry(state, id, content)
  end

  defp handle_message({:query_entry, caller, id}, state) do
    send(caller, {:reply, List.entry(state, id)})
    state
  end

  defp handle_message({:query_all_entries, caller}, state) do
    send(caller, {:reply, List.entries(state)})
    state
  end

  defp handle_message({:query_entries_by_date, caller, date}, state) do
    send(caller, {:reply, List.entries(state, date)})
    state
  end
end

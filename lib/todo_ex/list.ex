defmodule TodoEx.List do
  alias TodoEx.{List, Entry}
  defstruct incremental_id: 1, entries: %{}

  @type t :: %List{incremental_id: non_neg_integer(), entries: map()}

  @doc """
  Creates a new TodoList from a list of entries. Ignores invalid entries.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> title = "Task"
      iex> date = ~D[2022-03-06]
      iex> entry = Entry.new(title, date)
      iex> list = List.new([entry, %{title: "Invalid", date: ~D[2022-03-06]}])
      %List{incremental_id: 2, entries: %{1 => %Entry{id: 1, title: title, date: date}}}
  """
  @spec new(entries :: list()) :: t()
  def new(entries \\ []) when is_list(entries) do
    entries
    |> Stream.filter(fn
      %Entry{} -> true
      _ -> false
    end)
    |> Enum.reduce(%List{}, &add_entry(&2, &1))
  end

  @doc """
  Adds a new entry to TodoList
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> title = "Task"
      iex> date = ~D[2022-03-06]
      iex> entry = Entry.new(title, date)
      iex> list = List.new()
      %List{incremental_id: 1, entries: %{}}
      iex> List.add_entry(list, entry)
      %List{incremental_id: 2, entries: %{1 => %Entry{id: 1, title: title, date: date}}}
  """
  @spec add_entry(list :: t(), entry :: Entry.t()) :: t()
  def add_entry(%List{incremental_id: id, entries: entries}, %Entry{} = entry) do
    %List{incremental_id: id + 1, entries: Map.put(entries, id, %Entry{entry | id: id})}
  end

  @doc """
  Deletes an entry in the TodoList according to the specified id.
  If the ID does not exist, the TodoList is not modified.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> title = "Task"
      iex> date = ~D[2022-03-06]
      iex> entry = Entry.new(title, date)
      iex> list = List.new([entry])
      %List{incremental_id: 2, entries: %{1 => %Entry{id: 1, title: title, date: date}}}
      iex> List.delete_entry(list, 1)
      %List{incremental_id: 2, entries: %{}}
  """
  @spec delete_entry(list :: t(), id :: non_neg_integer()) :: t()
  def delete_entry(%List{} = list, id) do
    %List{list | entries: Map.delete(list.entries, id)}
  end

  @doc """
  Updates an entry in the TodoList according to the specified id and content map.
  If the ID does not exist, the TodoList is not modified.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> title = "Task"
      iex> date = ~D[2022-03-06]
      iex> entry = Entry.new(title, date)
      iex> list = List.new([entry])
      %List{incremental_id: 2, entries: %{1 => %Entry{id: 1, title: title, date: date}}}
      iex> List.update_entry(list, 1, %{id: 5, title: "Fix: Task"})
      %List{incremental_id: 2, entries: %{1 => %Entry{id: 1, title: "Fix: Task", date: date}}}
  """
  @spec update_entry(list :: t(), id :: non_neg_integer(), content :: map()) :: t()
  def update_entry(%List{entries: entries} = list, id, content) do
    try do
      %List{
        list
        | entries:
            Map.update!(entries, id, fn entry ->
              %Entry{
                entry
                | title: content[:title] || entry.title,
                  date: content[:date] || entry.date
              }
            end)
      }
    rescue
      _e in KeyError -> list
    end
  end

  @doc """
  Returns an input from an ID, if the ID does not exist, returns nil.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> title = "Task"
      iex> date = ~D[2022-03-06]
      iex> list = List.new([Entry.new(title, date)])
      iex> List.entry(list, 1)
      %Entry{id: 1, title: title, date: date}
      iex> List.entry(list, :unknown_id)
      nil
  """
  @spec entry(list :: t(), id :: non_neg_integer()) :: Entry.t() | nil
  def entry(%List{entries: entries}, id) do
    Map.get(entries, id)
  end

  @doc """
  Returns all entries.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> list = List.new([
      ...> Entry.new("Task", ~D[2022-03-06]),
      ...> Entry.new("Another Task", ~D[2023-05-07])
      ...> ])
      iex> List.entries(list)
      [
        %Entry{id: 1, title: "Task", date: ~D[2022-03-06]},
        %Entry{id: 2, title: "Another Task", date: ~D[2023-05-07]}
      ]
  """
  @spec entries(list :: t()) :: list(Entry.t())
  def entries(%List{entries: entries}) do
    entries
    |> Enum.map(fn {_key, entry} -> entry end)
  end

  @doc """
  Returns all entries according a given date.
  
    ## Examples
  
      iex> alias TodoEx.{List, Entry}
      [TodoEx.List, TodoEx.Entry]
      iex> list = List.new([
      ...> Entry.new("Task", ~D[2022-03-06]),
      ...> Entry.new("Go to Mars", ~D[2050-05-07]),
      ...> Entry.new("Another Task", ~D[2022-03-06]),
      ...> ])
      iex> List.entries(list, ~D[2022-03-06])
      [
        %Entry{id: 1, title: "Task", date: ~D[2022-03-06]},
        %Entry{id: 3, title: "Another Task", date: ~D[2022-03-06]}
      ]
  """
  @spec entries(list :: t(), date :: Date.t()) :: list(Entry.t())
  def entries(%List{entries: entries}, %Date{} = date) do
    entries
    |> Stream.filter(fn
      {_key, %Entry{date: ^date}} -> true
      _ -> false
    end)
    |> Stream.map(fn {_key, entry} -> entry end)
    |> Enum.to_list()
  end
end

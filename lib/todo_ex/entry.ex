defmodule TodoEx.Entry do
  alias __MODULE__
  defstruct id: nil, date: nil, title: nil

  @type t :: %Entry{id: non_neg_integer() | nil, date: Date.t(), title: String.t()}

  @doc """
  Creates a new entry from a title and date.

    ## Examples

      iex> alias TodoEx.Entry
      TodoEx.Entry
      iex> {:ok, date} = Date.new(2022, 03, 06)
      iex> Entry.new("Task", date)
      %Entry{id: nil, title: "Task", date: date}
  """
  @spec new(title :: String.t(), date :: Date.t()) :: t()
  def new(title, %Date{} = date) when is_binary(title) do
    %Entry{title: title, date: date}
  end

  @doc """
  Creates a new entry from a map that contains the title and date fields.

    ## Examples

      iex> alias TodoEx.Entry
      TodoEx.Entry
      iex> {:ok, date} = Date.new(2022, 03, 06)
      iex> Entry.new(%{title: "Task", date: date})
      %Entry{id: nil, title: "Task", date: date}
  """
  @spec new(map :: map()) :: t()
  def new(%{title: title, date: date = %Date{}}) when is_binary(title) do
    %Entry{title: title, date: date}
  end
end

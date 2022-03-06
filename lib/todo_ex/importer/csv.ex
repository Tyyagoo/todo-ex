defmodule TodoEx.Importer.CSV do
  alias TodoEx.{Entry, List}

  def import!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title | _] -> Entry.new(title, parse_date!(date)) end)
    |> Enum.to_list()
    |> List.new()
  end

  defp parse_date!(date_str) do
    [year, month, day] =
      date_str
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    Date.new!(year, month, day)
  end
end

defmodule TodoEx.List.Test do
  use ExUnit.Case
  alias TodoEx.{Entry, List}
  doctest TodoEx.List

  describe "when trying to update an entry" do
    setup do
      [Entry.new("Task", ~D[2022-03-06])]
      |> List.new()
      |> (&%{list: &1}).()
    end

    test "must be able to modify only the title", %{list: list} do
      %{id: id, title: _, date: date} = list |> List.entry(1)
      entry = list |> List.update_entry(1, %{title: "(fix): Task"}) |> List.entry(1)

      assert entry.id == id
      assert entry.date == date
      assert entry.title == "(fix): Task"
    end

    test "must be able to modify only the date", %{list: list} do
      %{id: id, title: title, date: _} = list |> List.entry(1)
      entry = list |> List.update_entry(1, %{date: ~D[2022-03-05]}) |> List.entry(1)

      assert entry.id == id
      assert entry.title == title
      assert entry.date == ~D[2022-03-05]
    end

    test "must be able to modify title and date together", %{list: list} do
      %{id: id, title: _, date: _} = list |> List.entry(1)

      entry =
        list
        |> List.update_entry(1, %{title: "(procrastinate): Task", date: ~D[2022-03-07]})
        |> List.entry(1)

      assert entry.id == id
      assert entry.title == "(procrastinate): Task"
      assert entry.date == ~D[2022-03-07]
    end

    test "must not be able to modify id", %{list: list} do
      %{id: id, title: title, date: date} = list |> List.entry(1)

      entry =
        list
        |> List.update_entry(1, %{id: 5})
        |> List.entry(1)

      assert entry.id == id
      assert entry.title == title
      assert entry.date == date
    end

    test "must not modify the list if ID doesn't exist", %{list: list} do
      updated_list =
        list
        |> List.update_entry(2, %{title: "Must be ignored"})

      assert list == updated_list
    end
  end
end

defmodule TodoEx.Importer.CSV.Test do
  use ExUnit.Case
  alias TodoEx.{Entry, List}

  test "must import correctly" do
    path = ~S(./test/fixtures/todos.csv)
    loaded_list = TodoEx.Importer.CSV.import!(path)

    assert loaded_list == %List{
             incremental_id: 4,
             entries: %{
               1 => %Entry{
                 id: 1,
                 title: "Dentist",
                 date: ~D[2022-03-19]
               },
               2 => %Entry{
                 id: 2,
                 title: "Shopping",
                 date: ~D[2022-03-20]
               },
               3 => %Entry{
                 id: 3,
                 title: "Movies",
                 date: ~D[2022-03-19]
               }
             }
           }
  end

  test "must not import if an wrong path is given" do
    path = ~S(./test/fixtures/not_existing_file.csv)

    assert_raise File.Error, fn ->
      TodoEx.Importer.CSV.import!(path)
    end
  end
end

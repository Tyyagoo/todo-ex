defmodule TodoEx.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")

    entries =
      list_name
      |> TodoEx.Cache.server_process()
      |> TodoEx.Server.entries()
      |> Enum.map(&"[#{&1.date}] #{&1.title}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, entries)
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)

    %{
      "list" => list_name,
      "title" => title,
      "date" => date
    } = conn.params

    date = Date.from_iso8601!(date)

    list_name
    |> TodoEx.Cache.server_process()
    |> TodoEx.Server.add_entry(TodoEx.Entry.new(title, date))

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  def child_spec(_) do
    IO.puts("[WebAPI] Starting...")

    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:todo_ex, :http_port)],
      plug: __MODULE__
    )
  end
end

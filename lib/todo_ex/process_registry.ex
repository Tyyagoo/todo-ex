defmodule TodoEx.ProcessRegistry do
  def start_link() do
    IO.puts("[ProcessRegistry]: Starting...")
    Registry.start_link(name: __MODULE__, keys: :unique)
  end

  def via(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end

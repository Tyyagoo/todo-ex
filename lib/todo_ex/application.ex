defmodule TodoEx.Application do
  use Application
  alias TodoEx.{Cache, Database, Metrics, ProcessRegistry, Web}

  @doc false
  @impl Application
  def start(_type, _args) do
    children = [ProcessRegistry, Database, Cache, Metrics, Web]
    opts = [strategy: :one_for_one, name: TodoEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

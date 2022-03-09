defmodule TodoEx do
  alias TodoEx.{Cache, Database, Metrics, ProcessRegistry}

  def start_link() do
    Supervisor.start_link([ProcessRegistry, Database, Cache, Metrics], strategy: :one_for_one)
  end
end

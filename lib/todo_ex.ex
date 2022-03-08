defmodule TodoEx do
  alias TodoEx.{Cache, Database, ProcessRegistry}

  def start_link() do
    Supervisor.start_link([ProcessRegistry, Database, Cache], strategy: :one_for_one)
  end
end

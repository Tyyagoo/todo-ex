defmodule TodoEx do
  alias TodoEx.{Cache, Database}

  def start_link() do
    Supervisor.start_link([Cache, Database], strategy: :one_for_one)
  end
end

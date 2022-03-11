defmodule TodoEx.Metrics do
  use Task

  def start_link(_) do
    IO.puts("[MetricsCollector]: Starting...")
    Task.start_link(&loop/0)
  end

  def loop() do
    Process.sleep(:timer.seconds(10))
    IO.inspect(collect_metrics(), label: "Metrics")
    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end

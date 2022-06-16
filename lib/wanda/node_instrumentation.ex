defmodule Wanda.Instrumentation do
  @moduledoc """
  Remote targets instrumentation module.
  """

  def trigger_facts_gathering(execution_id, target, checks) do
    IO.puts("trigger_facts_gathering")
    IO.inspect(checks)

    # given the checks identifiers we can retieve their information (facts gathering DSL mainly)
    # once we have the DSL we can choose whether to parse it in wanda or on the agent side

    Enum.each(checks, fn check -> simulate_facts_gathering(execution_id, target, check) end)

    :ok
  end

  defp simulate_facts_gathering(execution_id, target, check) do
    Task.async(fn ->
      # simulate a real execution by sleeping for a while
      1000..4000 |> Enum.random() |> Process.sleep()

      # this would be executed from a Receiver that listens for Agent published messages related to facts gathering
      Wanda.ExecutionServer.collect_gathered_facts(
        execution_id,
        %{
          execution_id: execution_id,
          host_id: target,
          check: check,
          gathered_facts:
            "facts for execution " <> execution_id <> " target " <> target <> " check " <> check
        }
      )
    end)
  end
end

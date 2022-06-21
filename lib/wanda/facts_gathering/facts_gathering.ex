defmodule Wanda.FactsGathering do
  @moduledoc """
  Remote targets instrumentation module.
  """

  def start(execution_id, target, checks) do
    # 1000..2000 |> Enum.random() |> Process.sleep()
    IO.puts("staring facts_gathering on target #{target} - execution: " <> execution_id)
    IO.inspect(checks)

    # given the checks identifiers we can retieve their information (facts gathering DSL mainly)
    # once we have the DSL we can choose whether to parse it in wanda or on the agent side

    checks
    |> Enum.flat_map(fn check -> Wanda.ChecksRepository.load_check(check) end)
    |> Enum.flat_map(fn {_check_key, %{"id" => _id, "facts" => facts}} ->
      # is the check id needed per fact?
      # Enum.map(facts, fn fact -> Map.put(fact, "check_id", id) end)
      facts
    end)
    |> IO.inspect()

    Enum.each(checks, fn check -> simulate_facts_gathering(execution_id, target, check) end)

    :ok
  end

  defp simulate_facts_gathering(execution_id, target, check) do
    Task.async(fn ->
      # simulate a real execution by sleeping for a while
      1000..4000 |> Enum.random() |> Process.sleep()

      # this would be executed from a Receiver that listens for Agent published messages related to facts gathering
      Wanda.ExecutionServer.gather_facts(
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

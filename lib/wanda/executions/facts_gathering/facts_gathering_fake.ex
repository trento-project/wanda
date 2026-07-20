# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FactsGathering.Fake do
  @moduledoc """
  Demo/dev facts gathering source: it does not reach out to any agent. Instead
  it synthesizes fake facts (see `Wanda.Executions.FakeGatheredFacts`) and feeds
  them back into `Wanda.Executions.Server` through the same `receive_facts/4`
  entry point the real agents use.

  Because of this the execution flows through the exact same evaluation,
  exclusion and finalization path as in production: `exclude` predicates are
  honoured and `excluded_by_policy` results are produced in demo just like with
  the real server.

  Facts are delivered asynchronously (after an optional `:sleep` delay) so the
  server process is never blocked and the round-trip mimics real agents.
  """

  @behaviour Wanda.Executions.FactsGathering

  alias Trento.Checks.V1.{FactRequest, FactsGatheringRequested, FactsGatheringRequestedTarget}

  alias Wanda.Executions.Fact, as: ExecutionFact
  alias Wanda.Executions.{FakeGatheredFacts, Server}
  alias Wanda.Messaging

  @default_sleep 2_000

  @impl true
  def request_facts(execution_id, group_id, targets, specs) do
    sleep = Application.get_env(:wanda, __MODULE__, [])[:sleep] || @default_sleep

    Task.start(fn ->
      if sleep > 0, do: Process.sleep(sleep)

      # Build the exact same request the production (AMQP) path would send to the
      # agents. The Fake acts as an in-process agent: it answers precisely the
      # facts that were requested, so it can never drift from production on *which*
      # (agent, check, fact) triples get gathered.
      execution_id
      |> Messaging.Mapper.to_facts_gathering_requested(group_id, targets, specs)
      |> synthesize_facts()
      |> Enum.each(&Server.receive_facts(execution_id, group_id, &1.agent_id, &1.facts))
    end)

    :ok
  end

  @doc """
  Synthesizes fake facts for exactly the requests carried by a
  `FactsGatheringRequested`, returning `[%{agent_id: String.t(), facts: [%Executions.Fact{}]}]`.

  Kept public and pure so it can be asserted against the request it consumes.
  """
  @spec synthesize_facts(FactsGatheringRequested.t()) :: [
          %{agent_id: String.t(), facts: [ExecutionFact.t()]}
        ]
  def synthesize_facts(%FactsGatheringRequested{targets: targets}) do
    Enum.map(targets, fn %FactsGatheringRequestedTarget{
                           agent_id: agent_id,
                           fact_requests: fact_requests
                         } ->
      facts =
        Enum.map(fact_requests, fn %FactRequest{check_id: check_id, name: name} ->
          %ExecutionFact{
            check_id: check_id,
            name: name,
            value: FakeGatheredFacts.fake_value(check_id, agent_id, name)
          }
        end)

      %{agent_id: agent_id, facts: facts}
    end)
  end
end

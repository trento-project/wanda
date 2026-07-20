# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FactsGathering.FakeTest do
  use Wanda.Support.MessagingCase, async: false
  use Wanda.DataCase

  import Mox
  import Wanda.Factory

  alias Trento.Checks.V1.ExecutionCompleted

  alias Wanda.Catalog
  alias Wanda.Executions.{Execution, Server}
  alias Wanda.Executions.FactsGathering.Fake
  alias Wanda.Executions.Messaging.Publisher
  alias Wanda.Messaging.Mapper

  setup [:set_mox_from_context, :verify_on_exit!]

  setup do
    previous_server = Application.get_env(:wanda, Server)

    Application.put_env(:wanda, Server,
      facts_gathering_impl: Wanda.Executions.FactsGathering.Fake
    )

    on_exit(fn -> Application.put_env(:wanda, Server, previous_server) end)

    :ok
  end

  defp build_check do
    [%Catalog.Fact{name: fact_name}] =
      catalog_facts = build_list(1, :catalog_fact, name: "fact_name1")

    spec =
      build(:check,
        id: "CHECK1",
        facts: catalog_facts,
        values: [],
        expectations: [build(:catalog_expectation, type: :expect, expression: "#{fact_name}")]
      )

    build(:selected_check, spec: spec)
  end

  @tag capture_log: true
  test "delivers synthesized facts through Server.receive_facts and completes the execution" do
    pid = self()
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    check = build_check()

    # agent ids match the fixture targets so fake facts resolve
    agent_1 = "0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4"
    agent_2 = "13e8c25c-3180-5a9a-95c8-51ec38e50cfc"

    targets =
      for agent_id <- [agent_1, agent_2],
          do: build(:target, agent_id: agent_id, checks: [check.id])

    # No dispatch to "agents": the fake gatherer never publishes a gathering
    # request, so only execution_started + execution_completed are published.
    expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
      Publisher, "results", %ExecutionCompleted{}, _ ->
        send(pid, :completed)
        :ok

      _, _, _, _ ->
        :ok
    end)

    start_supervised!(
      {Server,
       execution_id: execution_id, group_id: group_id, targets: targets, checks: [check], env: %{}}
    )

    assert_receive :completed, 1_000

    assert %Execution{execution_id: ^execution_id, status: :completed} = Repo.one!(Execution)
  end

  @tag capture_log: true
  test "synthesizes exactly the facts encoded in the shared FactsGatheringRequested" do
    execution_id = UUID.uuid4()
    group_id = UUID.uuid4()

    check_a = build(:check, id: "CHECK_A", facts: [build(:catalog_fact, name: "fact_a")])

    check_b =
      build(:check,
        id: "CHECK_B",
        facts: [build(:catalog_fact, name: "fact_b1"), build(:catalog_fact, name: "fact_b2")]
      )

    specs = [check_a, check_b]

    agent_1 = UUID.uuid4()
    agent_2 = UUID.uuid4()

    targets = [
      build(:target, agent_id: agent_1, checks: ["CHECK_A", "CHECK_B"]),
      # agent_2 only runs CHECK_A
      build(:target, agent_id: agent_2, checks: ["CHECK_A"])
    ]

    # The Fake must answer exactly the request the production mapper builds — no
    # more, no less — so demo can't drift from production on request contents.
    request = Mapper.to_facts_gathering_requested(execution_id, group_id, targets, specs)

    requested_triples =
      for %{agent_id: agent_id, fact_requests: fact_requests} <- request.targets,
          %{check_id: check_id, name: name} <- fact_requests,
          do: {agent_id, check_id, name}

    synthesized_triples =
      for %{agent_id: agent_id, facts: facts} <- Fake.synthesize_facts(request),
          %{check_id: check_id, name: name} <- facts,
          do: {agent_id, check_id, name}

    assert MapSet.new(synthesized_triples) == MapSet.new(requested_triples)

    # A target that does not carry a check gets none of its facts.
    refute Enum.any?(synthesized_triples, fn {agent, check, _} ->
             agent == agent_2 and check == "CHECK_B"
           end)
  end
end

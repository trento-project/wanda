defmodule Wanda.Execution.ServerTest do
  use Wanda.Support.MessagingCase, async: false

  import Mox
  import Wanda.Factory

  alias Wanda.Execution.Server

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "start_link/3" do
    test "should accept an execution_id, a group_id and targets on start" do
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      assert {:ok, pid} =
               start_supervised(
                 {Server,
                  [
                    execution_id: execution_id,
                    group_id: group_id,
                    targets: build_list(10, :target)
                  ]}
               )

      assert pid == :global.whereis_name({Server, execution_id})
    end
  end

  describe "execution orchestration" do
    test "should start an execution" do
      pid = self()
      execution_id = "d4a2cdd6-119e-40d3-96ef-9406ad993360"
      group_id = "d1f268b4-d8df-4433-bab4-b094d32068a8"

      target_agents =
        [agent1, agent2, agent3] = [
          "b6dc7b6d-5637-4c56-bcab-25c06bd27886",
          "b5c82c8e-ade0-4e23-af51-01699db6b156",
          "4e2ae182-83ee-4db0-9404-6efea74c7698"
        ]

      expected_facts_request = %Wanda.Execution.FactsRequest{
        execution_id: execution_id,
        group_id: group_id,
        targets: target_agents,
        facts: [
          %Wanda.Execution.AgentFacts{
            agent_id: agent1,
            facts: [
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "expect_check",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              },
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "expect_same_check",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              }
            ]
          },
          %Wanda.Execution.AgentFacts{
            agent_id: agent2,
            facts: [
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "expect_check",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              },
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "expect_same_check",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              }
            ]
          },
          %Wanda.Execution.AgentFacts{
            agent_id: agent3,
            facts: [
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "0A0A0A",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              },
              %Wanda.Catalog.Fact{
                argument: "SBD_PACEMAKER",
                check_id: "0A0A0A",
                gatherer: "sbd_config",
                name: "sbd_pacemaker"
              },
              %Wanda.Catalog.Fact{
                argument: "SBD_STARTMODE",
                check_id: "0A0A0A",
                gatherer: "sbd_config",
                name: "sbd_startmode"
              },
              %Wanda.Catalog.Fact{
                argument: "totem.token",
                check_id: "expect_check",
                gatherer: "corosync",
                name: "corosync_token_timeout"
              }
            ]
          }
        ]
      }

      # TODO: fix function call expectation as per the agreed behaviour
      expect(Wanda.Messaging.Adapters.Mock, :publish, fn _routing_key, _expected_facts_request ->
        send(pid, :wandalorian)

        :ok
      end)

      targets = [
        build(:target, agent_id: agent1, checks: ["expect_check", "expect_same_check"]),
        build(:target, agent_id: agent2, checks: ["expect_check", "expect_same_check"]),
        build(:target, agent_id: agent3, checks: ["0A0A0A", "expect_check"])
      ]

      start_supervised!(
        {Server,
         [
           execution_id: execution_id,
           group_id: group_id,
           targets: targets
         ]}
      )

      assert_receive :wandalorian
    end

    test "should exit when all facts are sent by all agents" do
      pid = self()
      execution_id = UUID.uuid4()
      group_id = UUID.uuid4()

      targets = build_list(3, :target, %{checks: ["expect_check"]})

      expect(Wanda.Messaging.Adapters.Mock, :publish, 2, fn
        "checks.execution", _ ->
          send(pid, :executed)

          :ok

        _, _ ->
          :ok
      end)

      {:ok, pid} =
        start_supervised(
          {Server,
           [
             execution_id: execution_id,
             group_id: group_id,
             targets: targets
           ]}
        )

      ref = Process.monitor(pid)

      Enum.each(targets, fn target ->
        Server.receive_facts(execution_id, target.agent_id, [
          %Wanda.Execution.Fact{
            check_id: "expect_check",
            name: "corosync_token_timeout",
            value: 30_000
          }
        ])
      end)

      # assert_receive :executed
      # assert_receive {:DOWN, ^ref, _, ^pid, :normal}

      # TODO: according to decided implementation of process cache, this test might need to be updated
      assert_receive {:DOWN, ^ref, _, ^pid, _}
    end
  end
end

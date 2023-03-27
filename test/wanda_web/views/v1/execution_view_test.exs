defmodule WandaWeb.V1.ExecutionViewTest do
  use WandaWeb.ConnCase, async: true

  import Phoenix.View
  import Wanda.Factory

  alias Wanda.Executions.{
    AgentCheckResult,
    CheckResult,
    Execution,
    ExpectationEvaluation,
    ExpectationResult
  }

  describe "ExecutionView" do
    test "renders index.json" do
      started_at = DateTime.utc_now()

      [
        %Execution{execution_id: execution_id_1, group_id: group_id_1},
        %Execution{execution_id: execution_id_2, group_id: group_id_2}
      ] =
        executions =
        Enum.map(1..2, fn _ ->
          :execution
          |> build(started_at: started_at)
          |> insert(returning: true)
        end)

      assert %{
               items: [
                 %{
                   execution_id: ^execution_id_1,
                   group_id: ^group_id_1,
                   started_at: ^started_at
                 },
                 %{
                   execution_id: ^execution_id_2,
                   group_id: ^group_id_2,
                   started_at: ^started_at
                 }
               ],
               total_count: 10
             } =
               render(WandaWeb.V1.ExecutionView, "index.json",
                 executions: executions,
                 total_count: 10
               )
    end

    test "renders show.json for a running execution" do
      started_at = DateTime.utc_now()

      %Execution{execution_id: execution_id, group_id: group_id, targets: targets} =
        execution =
        :execution
        |> build(started_at: started_at)
        |> insert(returning: true)

      assert %{
               execution_id: ^execution_id,
               group_id: ^group_id,
               started_at: ^started_at,
               completed_at: nil,
               status: :running,
               result: nil,
               critical_count: nil,
               warning_count: nil,
               passing_count: nil,
               timeout: nil,
               targets: ^targets,
               check_results: nil
             } = render(WandaWeb.V1.ExecutionView, "show.json", execution: execution)
    end

    test "renders show.json for a completed execution" do
      passing_checks = ["check_1", "check_2"]
      warning_checks = ["check_3"]
      critical_checks = ["check_4"]

      passing_targets = build_pair(:execution_target, checks: passing_checks)
      warning_targets = build_pair(:execution_target, checks: warning_checks)
      critical_targets = build_pair(:execution_target, checks: critical_checks)
      targets = passing_targets ++ warning_targets ++ critical_targets

      passing_check_results = build(:check_results_from_targets, targets: passing_targets)

      warning_check_results =
        build(:check_results_from_targets, targets: warning_targets, result: :warning)

      critical_check_results =
        build(:check_results_from_targets, targets: critical_targets, result: :critical)

      check_results = passing_check_results ++ warning_check_results ++ critical_check_results

      result =
        build(:result,
          check_results: check_results,
          result: :critical
        )

      %Execution{
        execution_id: execution_id,
        group_id: group_id,
        started_at: started_at,
        completed_at: completed_at,
        result: %{
          "timeout" => timeout
        }
      } =
        execution =
        :execution
        |> build(
          targets: targets,
          result: result,
          completed_at: DateTime.utc_now(),
          status: :completed
        )
        |> insert(returning: true)

      assert %{
               execution_id: ^execution_id,
               group_id: ^group_id,
               started_at: ^started_at,
               completed_at: ^completed_at,
               status: :completed,
               passing_count: 2,
               warning_count: 1,
               critical_count: 1,
               result: "critical",
               timeout: ^timeout,
               check_results: [
                 %{"check_id" => "check_1"},
                 %{"check_id" => "check_2"},
                 %{"check_id" => "check_3"},
                 %{"check_id" => "check_4"}
               ]
             } = render(WandaWeb.V1.ExecutionView, "show.json", execution: execution)
    end

    test "renders show.json stripping nil failure_message keys" do
      passing_checks = ["check_1", "check_2"]
      critical_checks = ["check_3"]

      passing_targets = build_pair(:execution_target, checks: passing_checks)
      critical_targets = build_pair(:execution_target, checks: critical_checks)
      targets = passing_targets ++ critical_targets

      [
        %CheckResult{
          expectation_results: [
            %ExpectationResult{
              name: passing_expectation_result_name,
              result: passing_expectation_result,
              type: passing_expectation_result_type
            }
            | _
          ],
          agents_check_results: [
            %AgentCheckResult{
              expectation_evaluations: [
                %ExpectationEvaluation{
                  name: passing_check_result_name,
                  return_value: passing_check_result_value,
                  type: passing_check_result_type
                }
                | _
              ]
            }
            | _
          ]
        }
        | _
      ] = passing_check_results = build(:check_results_from_targets, targets: passing_targets)

      failure_message = Faker.StarWars.quote()

      critical_check_results =
        build(:check_results_from_targets,
          targets: critical_targets,
          result: :critical,
          failure_message: failure_message
        )

      check_results = passing_check_results ++ critical_check_results

      result =
        build(:result,
          check_results: check_results,
          result: :critical
        )

      execution =
        :execution
        |> build(
          targets: targets,
          result: result,
          completed_at: DateTime.utc_now(),
          status: :completed
        )
        |> insert(returning: true)

      %{
        check_results: [
          %{
            "expectation_results" => [rendered_passing_expectation_result | _],
            "agents_check_results" => [
              %{
                "expectation_evaluations" => [rendered_passing_expectation_evaluation | _]
              }
              | _
            ]
          },
          _,
          %{
            "agents_check_results" => [
              _,
              %{"expectation_evaluations" => critical_expectation_evaluations}
            ]
          }
        ]
      } = render(WandaWeb.V1.ExecutionView, "show.json", execution: execution)

      Enum.each(critical_expectation_evaluations, fn
        %{
          "type" => "expect",
          "return_value" => false,
          "failure_message" => expectation_failure_message
        } ->
          assert expectation_failure_message === failure_message

        _ ->
          :ok
      end)

      assert rendered_passing_expectation_evaluation == %{
               "name" => passing_check_result_name,
               "type" => to_string(passing_check_result_type),
               "return_value" => passing_check_result_value
             }

      assert rendered_passing_expectation_result == %{
               "name" => passing_expectation_result_name,
               "type" => to_string(passing_expectation_result_type),
               "result" => passing_expectation_result
             }
    end
  end
end

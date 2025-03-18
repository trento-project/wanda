defmodule WandaWeb.V1.OperationJSONTest do
  use ExUnit.Case, async: true

  import Wanda.Factory

  alias WandaWeb.V1.OperationJSON

  describe "OperationJSON" do
    test "renders index.json" do
      %{id: catalog_operation_id, name: operation_name} =
        catalog_operation = build(:catalog_operation)

      [%{operation_id: id_1}, %{operation_id: id_2}, %{operation_id: id_3}] =
        operations =
        3
        |> build_list(:operation,
          agent_reports: build_list(2, :step_report),
          catalog_operation_id: catalog_operation_id
        )
        |> Enum.map(fn operation -> %{operation | catalog_operation: catalog_operation} end)

      assert %{
               items: [
                 %{operation_id: ^id_1, name: ^operation_name},
                 %{operation_id: ^id_2, name: ^operation_name},
                 %{operation_id: ^id_3, name: ^operation_name}
               ],
               total_count: 3
             } =
               OperationJSON.index(%{
                 operations: operations
               })
    end

    test "renders show.json for a running execution" do
      %{
        id: catalog_operation_id,
        name: operation_name,
        description: operation_description,
        steps: [
          %{
            name: step_name_1,
            timeout: step_timeout_1,
            operator: step_operator_1,
            predicate: step_predicate_1
          },
          %{
            name: step_name_2,
            timeout: step_timeout_2,
            operator: step_operator_2,
            predicate: step_predicate_2
          }
        ]
      } = catalog_operation = build(:catalog_operation)

      [%{agents: agents_1}, %{agents: agents_2}] = agent_reports = build_list(2, :step_report)

      %{
        operation_id: operation_id,
        group_id: group_id,
        targets: targets,
        started_at: started_at,
        updated_at: updated_at,
        completed_at: completed_at,
        result: result,
        status: status
      } =
        operation =
        build(:operation,
          catalog_operation_id: catalog_operation_id,
          agent_reports: agent_reports
        )

      operation = %{operation | catalog_operation: catalog_operation}

      expected_operation =
        %{
          operation_id: operation_id,
          group_id: group_id,
          targets: targets,
          started_at: started_at,
          updated_at: updated_at,
          completed_at: completed_at,
          result: result,
          status: status,
          name: operation_name,
          description: operation_description,
          operation: catalog_operation_id,
          agent_reports: [
            %{
              name: step_name_1,
              timeout: step_timeout_1,
              operator: step_operator_1,
              predicate: step_predicate_1,
              agents: agents_1
            },
            %{
              name: step_name_2,
              timeout: step_timeout_2,
              operator: step_operator_2,
              predicate: step_predicate_2,
              agents: agents_2
            }
          ]
        }

      assert expected_operation == OperationJSON.show(%{operation: operation})
    end
  end
end

defmodule WandaWeb.V1.OperationJSON do
  alias Wanda.Operations.Operation

  def index(%{operations: operations}) do
    %{
      items: Enum.map(operations, &operation/1),
      total_count: length(operations)
    }
  end

  def show(%{operation: operation}) do
    operation(operation)
  end

  defp operation(%Operation{
         operation_id: operation_id,
         group_id: group_id,
         result: result,
         status: status,
         targets: targets,
         agent_reports: agent_reports,
         catalog_operation_id: catalog_operation_id,
         catalog_operation: %{
           name: name,
           description: description,
           steps: steps
         },
         started_at: started_at,
         updated_at: updated_at,
         completed_at: completed_at
       }) do
    %{
      operation_id: operation_id,
      group_id: group_id,
      result: result,
      status: status,
      targets: targets,
      agent_reports: map_agent_reports(agent_reports, steps),
      operation: catalog_operation_id,
      name: name,
      description: description,
      started_at: started_at,
      updated_at: updated_at,
      completed_at: completed_at
    }
  end

  defp map_agent_reports(agent_reports, steps) do
    agent_reports
    |> Enum.with_index()
    |> Enum.map(fn {%{"agents" => agents}, index} ->
      %{name: name, timeout: timeout, operator: operator, predicate: predicate} =
        Enum.at(steps, index)

      %{
        agents: agents,
        name: name,
        timeout: timeout,
        operator: operator,
        predicate: predicate
      }
    end)
  end
end

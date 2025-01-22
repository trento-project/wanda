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
      agent_reports: agent_reports,
      started_at: started_at,
      updated_at: updated_at,
      completed_at: completed_at
    }
  end
end

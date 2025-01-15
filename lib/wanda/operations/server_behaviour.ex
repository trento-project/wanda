defmodule Wanda.Operations.ServerBehaviour do
  @moduledoc """
  Operation server API behaviour.
  """

  require Wanda.Operations.Enums.Result, as: Result

  alias Wanda.Operations.Catalog.Operation
  alias Wanda.Operations.OperationTarget

  @callback start_operation(
              operation_id :: String.t(),
              group_id :: String.t(),
              operation :: Operation.t(),
              targets :: [OperationTarget.t()]
            ) ::
              :ok
              | {:error, :arguments_missing}
              | {:error, :already_running}
              | {:error, :operation_not_found}

  @callback start_operation(
              operation_id :: String.t(),
              group_id :: String.t(),
              operation :: Operation.t(),
              targets :: [OperationTarget.t()],
              config :: Keyword.t()
            ) ::
              :ok
              | {:error, :arguments_missing}
              | {:error, :already_running}
              | {:error, :operation_not_found}

  @callback receive_operation_reports(
              operation_id :: String.t(),
              group_id :: String.t(),
              step_id :: number(),
              agent_id :: String.t(),
              operation_result :: Result.t()
            ) ::
              :ok | {:error, any}
end

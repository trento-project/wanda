defmodule Wanda.Results do
  @moduledoc """
  This module exposes functionalities to interact with the historycal log of ExecutionResults.
  It allows to:
   - append an item to the log
  """

  alias Wanda.Execution.{ExecutionResult, Result}

  @spec append(Result.t()) :: {:ok, any()} | {:error, any()}
  def append(
        %Result{
          execution_id: execution_id,
          group_id: group_id
        } = result
      ) do
    %ExecutionResult{
      execution_id: execution_id,
      group_id: group_id,
      payload: result
    }
    |> Wanda.Repo.insert()
  end
end

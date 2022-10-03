defmodule Wanda.Results do
  @moduledoc """
  This module exposes functionalities to interact with the historycal log of ExecutionResults.
  It allows to:
   - append an item to the log
  """

  alias Wanda.Execution.Result
  alias Wanda.Results.ExecutionResult

  @spec save_result(Result.t()) :: ExecutionResult.t()
  def save_result(
        %Result{
          execution_id: execution_id,
          group_id: group_id
        } = result
      ) do
    Wanda.Repo.insert!(%ExecutionResult{
      execution_id: execution_id,
      group_id: group_id,
      payload: result
    })
  end
end

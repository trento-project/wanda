defmodule Wanda.Messaging.EventsRegistry do
  @moduledoc """
  Cloudevents type registry of the internal representations
  """

  @execution_completed_event "trento.checks.v1.ExecutionCompleted"

  @spec extract_metadata(any) :: {:ok, String.t(), String.t()} | {:error, any()}
  def extract_metadata(%Wanda.Execution.Result{execution_id: execution_id}),
    do: {:ok, @execution_completed_event, execution_id}

  def extract_metadata(_), do: {:error, :unsupported_event}
end

defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps messages to events.
  """
  alias Cloudevents.Format.V_1_0.Event, as: CloudEvent

  alias Wanda.JsonSchema

  # TODO: move this in the contract repository, keep this module to map domain structure to events.

  @spec from_json(binary()) :: {:ok, CloudEvent.t()} | {:error, any}
  def from_json(json) do
    with {:ok, %CloudEvent{data: data, type: type} = cloud_event} <- Cloudevents.from_json(json),
         :ok <- JsonSchema.validate(type, data) do
      {:ok, cloud_event}
    end
  end
end

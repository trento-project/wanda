defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps messages to and from events.
  """
  alias Cloudevents.Format.V_1_0.Event, as: CloudEvent

  alias Wanda.JsonSchema

  alias Wanda.Messaging.EventsRegistry

  # TODO: move this in the contract repository, keep this module to map domain structure to events.

  @spec from_json(binary()) :: {:ok, CloudEvent.t()} | {:error, any}
  def from_json(json) do
    with {:ok, %CloudEvent{data: data, type: type} = cloud_event} <- Cloudevents.from_json(json),
         :ok <- JsonSchema.validate(type, data) do
      {:ok, cloud_event}
    end
  end

  @spec to_json(struct()) :: binary() | {:error, any()}
  def to_json(event) do
    with {:ok, type, identifier} <- EventsRegistry.extract_metadata(event),
         {:ok, cloud_event} <- build_cloud_event(identifier, type, event) do
      Cloudevents.to_json(cloud_event)
    end
  end

  defp build_cloud_event(id, type, event) do
    %{
      "specversion" => "1.0",
      "id" => id,
      "type" => type,
      "source" => "https://github.com/trento-project/wanda",
      "data" => event
    }
    |> CloudEvent.from_map()
  end
end

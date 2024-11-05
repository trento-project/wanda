defmodule Wanda.Messaging.Adapters.AMQP do
  @moduledoc """
  AMQP adapter
  """

  @behaviour Wanda.Messaging.Adapters.Behaviour

  alias Wanda.Messaging.Adapters.AMQP.Publisher

  @impl true

  def publish(routing_key, message) do
    message
    |> Trento.Contracts.to_event(source: "github.com/trento-project/wanda")
    |> Publisher.publish_message(routing_key)
  end

  @impl true
  def publish_signed(routing_key, message) do
    # load this from a configuration option
    private_key =
      "/home/xarbulu/Desktop/test_key.pem"
      |> File.read!()
      |> :public_key.pem_decode()
      |> Enum.at(0)
      |> :public_key.pem_entry_decode()

    message
    |> Trento.Contracts.to_event(
      source: "github.com/trento-project/wanda",
      private_key: private_key
    )
    |> Publisher.publish_message(routing_key)
  end

  # @impl true
  # def publish_signed(routing_key, message) do
  #   private_key =
  #     "/home/xarbulu/Desktop/test_key.pem"
  #     |> File.read!()
  #     |> :public_key.pem_decode()
  #     |> Enum.at(0)
  #     |> :public_key.pem_entry_decode()

  #   message
  #   |> Trento.Contracts.to_event(
  #     source: "github.com/trento-project/wanda"
  #   )
  #   |> Trento.Contracts.add_signature(private_key)
  #   |> Publisher.publish_message(routing_key)
  # end
end

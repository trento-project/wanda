# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FactsGathering.AMQP do
  @moduledoc """
  Production facts gathering source: dispatches a `FactsGatheringRequested`
  message to the agents over AMQP. The gathered facts flow back asynchronously
  through `Wanda.Executions.Server.receive_facts/4`.
  """

  @behaviour Wanda.Executions.FactsGathering

  alias Wanda.Executions.Messaging.Publisher
  alias Wanda.Messaging

  @impl true
  def request_facts(execution_id, group_id, targets, specs) do
    facts_gathering_requested =
      Messaging.Mapper.to_facts_gathering_requested(execution_id, group_id, targets, specs)

    Messaging.publish(Publisher, "agents", facts_gathering_requested)
  end
end

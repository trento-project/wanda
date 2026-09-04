# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FactsGathering do
  @moduledoc """
  Behaviour for the facts gathering source of a check execution.

  An implementation is responsible for causing the facts for the given active
  targets to eventually reach `Wanda.Executions.Server.receive_facts/4`.

  The production implementation (`Wanda.Executions.FactsGathering.AMQP`)
  dispatches a `FactsGatheringRequested` message to the agents; the demo
  implementation (`Wanda.Executions.FactsGathering.Fake`) synthesizes the facts
  locally. In both cases everything after dispatch (accumulation, evaluation,
  exclusion injection and finalization) runs through the exact same `Server`
  code path.
  """

  alias Wanda.Catalog.Check
  alias Wanda.Executions.Target

  @callback request_facts(
              execution_id :: String.t(),
              group_id :: String.t(),
              targets :: [Target.t()],
              specs :: [Check.t()]
            ) :: :ok
end

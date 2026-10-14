# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Operations.StepReport do
  @moduledoc """
  Report of all agent execution of an operation step
  """

  alias Wanda.Operations.AgentReport

  @derive Jason.Encoder
  defstruct [
    :step_number,
    :agents
  ]

  @type t :: %__MODULE__{
          step_number: integer(),
          agents: [AgentReport.t()]
        }
end

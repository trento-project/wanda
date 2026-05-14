# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.Messaging.Consumer do
  @moduledoc """
  Executions messagging consumer module
  """

  use Wanda.Messaging.Adapters.AMQP.Consumer, id: __MODULE__, name: :checks
end

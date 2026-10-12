# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Executions.Messaging.Consumer do
  @moduledoc """
  Executions messagging consumer module
  """

  use Wanda.Messaging.Adapters.AMQP.Consumer, id: __MODULE__, name: :checks
end

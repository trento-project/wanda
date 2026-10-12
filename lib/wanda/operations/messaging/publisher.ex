# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Operations.Messaging.Publisher do
  @moduledoc """
  Operations messagging publisher module
  """

  use Wanda.Messaging.Adapters.AMQP.Publisher, id: __MODULE__, name: :operations
end

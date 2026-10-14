# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Support.Messaging.Adapters.Stub do
  @moduledoc false

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(_, _, _, _), do: :ok
end

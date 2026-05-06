# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Support.Messaging.Adapters.Stub do
  @moduledoc false

  @behaviour Wanda.Messaging.Adapters.Behaviour

  @impl true
  def publish(_, _, _, _), do: :ok
end

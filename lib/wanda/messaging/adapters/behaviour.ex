# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

defmodule Wanda.Messaging.Adapters.Behaviour do
  @moduledoc false

  @callback publish(
              publisher :: module(),
              topic :: String.t(),
              message :: any,
              opts :: Keyword.t()
            ) ::
              :ok | {:error, any()}
end

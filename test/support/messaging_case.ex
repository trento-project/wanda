# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Support.MessagingCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup _ do
    Mox.stub_with(Wanda.Messaging.Adapters.Mock, Wanda.Support.Messaging.Adapters.Stub)

    :ok
  end
end

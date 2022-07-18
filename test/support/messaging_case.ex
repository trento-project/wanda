defmodule Wanda.Support.MessagingCase do
  @moduledoc nil

  use ExUnit.CaseTemplate

  setup _ do
    Mox.stub_with(Wanda.Messaging.Adapters.Mock, Wanda.Support.PublisherStub)

    :ok
  end
end

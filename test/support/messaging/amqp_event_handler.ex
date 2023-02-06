defmodule Wanda.Support.Messaging.AMQPEventHandler do
  @moduledoc false

  def handle_event([:gen_rmq, type, _, _], _, _, %{pid: pid}) do
    send(pid, {:connected, type})
  end
end

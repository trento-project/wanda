defmodule Wanda.Messaging.ProcessCache do
  use Nebulex.Cache,
    otp_app: :wanda,
    adapter: Nebulex.Adapters.Local
end

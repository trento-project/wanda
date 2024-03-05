defmodule WandaWeb.Auth.AccessToken do
  @moduledoc """
    Jwt Token is the module responsible for creating a proper jwt access token.
    Uses Joken as jwt base library
  """

  use Joken.Config, default_signer: :access_token_signer

  @iss "https://github.com/trento-project/web"
  @aud "trento_app"

  @impl true
  def token_config do
    default_claims(iss: @iss, aud: @aud)
  end
end

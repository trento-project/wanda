defmodule WandaWeb.Auth.Client.AuthClient do
  @moduledoc """
  Client for interacting with the authentication server.
  """

  @type introspected_token :: %{
          active: boolean(),
          sub: integer(),
          abilities: list(%{name: String.t(), resource: String.t()})
        }

  @callback introspect_token(token :: String.t()) ::
              {:ok, introspected_token()} | {:error, atom()}

  def introspect_token(token), do: impl().introspect_token(token)

  defp impl,
    do: Application.get_env(:wanda, :auth_client, WandaWeb.Auth.Client.HttpClient)
end

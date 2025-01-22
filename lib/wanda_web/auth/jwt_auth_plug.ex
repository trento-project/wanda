defmodule WandaWeb.Auth.JWTAuthPlug do
  @moduledoc """
    Plug responsible for reading the JWT from the authorization header and
    validating it.

    If the token is valid, the user_id is added to the private section of the
    connection.
    If the token is invalid, the connection is halted with a 401 response.
  """
  @behaviour Plug

  import Plug.Conn

  alias WandaWeb.Auth.AccessToken

  require Logger

  def init(opts), do: opts

  @doc """
    Read, validate and decode the JWT from authorization header at each call
  """
  def call(conn, _) do
    authenticate(conn)
  end

  defp authenticate(conn) do
    with {:ok, jwt_token} <- read_token(conn),
         {:ok, %{"sub" => sub, "abilities" => abilities}} <-
           AccessToken.verify_and_validate(jwt_token) do
      conn
      |> put_private(:user_id, sub)
      |> put_private(:abilities, abilities_to_atom_map(abilities))
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "Unauthorized"}))
        |> halt()
    end
  end

  defp read_token(conn) do
    case get_req_header(conn, "authorization") do
      [bearer_token | _] ->
        token = bearer_token |> String.replace("Bearer", "") |> String.trim()
        {:ok, token}

      _ ->
        Logger.debug("No token found in request")

        {:error, :no_token}
    end
  end

  defp abilities_to_atom_map(abilities) when is_list(abilities) do
    Enum.map(abilities, fn %{"name" => name, "resource" => resource} ->
      %{
        name: name,
        resource: resource
      }
    end)
  end

  defp abilities_to_atom_map(_), do: []
end

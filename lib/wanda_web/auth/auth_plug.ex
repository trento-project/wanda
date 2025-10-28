defmodule WandaWeb.Auth.AuthPlug do
  @moduledoc """
    Plug responsible for reading the Token from the authorization header and
    validating it.

    If the token is valid, the user_id is added to the private section of the
    connection.
    If the token is invalid, the connection is halted with a 401 response.
  """
  @behaviour Plug

  import Plug.Conn

  alias WandaWeb.Auth.Client.AuthClient

  require Logger

  def init(opts), do: opts

  @doc """
    Read, validate and decode the Token from authorization header at each call
  """
  def call(conn, _) do
    authenticate(conn)
  end

  defp authenticate(conn) do
    with {:ok, token} <- read_token(conn),
         {:ok, %{active: true, sub: sub, abilities: abilities}} <-
           AuthClient.introspect_token(token) do
      conn
      |> put_private(:user_id, sub)
      |> put_private(:abilities, abilities)
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
end

defmodule WandaWeb.Auth.Client.HttpClient do
  @moduledoc """
  Http AuthClient implementation.
  """

  @behaviour WandaWeb.Auth.Client.AuthClient

  alias WandaWeb.Auth.Client.AuthClient

  require Logger

  @impl AuthClient
  def introspect_token(token) do
    "#{auth_server_url()}/api/session/token/introspect"
    |> HTTPoison.post(
      Jason.encode!(%{"token" => token}),
      [{"Content-type", "application/json"}]
    )
    |> get_response_body(
      error_atom: :unable_to_get_introspect_response,
      error_log: "Unable to retrieve token introspection response body"
    )
    |> decode_response(
      error_atom: :cannot_decode_introspect_response,
      error_log: "Unable to decode token introspection response body"
    )
  end

  defp get_response_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _),
    do: {:ok, body}

  defp get_response_body(error, error_atom: error_atom, error_log: error_log) do
    Logger.error("#{error_log} Error: #{inspect(error)}")

    {:error, error_atom}
  end

  defp decode_response({:ok, body}, error_atom: error_atom, error_log: error_log) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, _} = result ->
        result

      error ->
        Logger.error("#{error_log} Error: #{inspect(error)}")

        {:error, error_atom}
    end
  end

  defp decode_response({:error, _} = error, _) do
    Logger.error("Unable to decode response body Error: #{inspect(error)}")

    error
  end

  defp auth_server_url do
    Application.fetch_env!(:wanda, :auth_server)[:url]
  end
end

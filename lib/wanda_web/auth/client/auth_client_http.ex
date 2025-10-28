defmodule WandaWeb.Auth.Client.HttpClient do
  @moduledoc """
  Http AuthClient implementation.
  """

  @behaviour WandaWeb.Auth.Client.AuthClient

  alias WandaWeb.Auth.Client.AuthClient

  require Logger

  @impl AuthClient
  def introspect_token(token) do
    with response <- make_introspect_request(token),
         {:ok, body} <- get_response_body(response),
         {:ok, _} = result <- decode_response(body) do
      result
    end
  end

  defp make_introspect_request(token) do
    HTTPoison.post(
      "#{auth_server_url()}/api/session/token/introspect",
      Jason.encode!(%{"token" => token}),
      [{"Content-type", "application/json"}]
    )
  end

  defp get_response_body({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: {:ok, body}

  defp get_response_body(error) do
    Logger.error("Unable to retrieve token introspection response body Error: #{inspect(error)}")

    {:error, :unable_to_get_introspect_response}
  end

  defp decode_response(body) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, _} = result ->
        result

      error ->
        Logger.error("Unable to decode response body Error: #{inspect(error)}")

        {:error, :cannot_decode_introspect_response}
    end
  end

  defp auth_server_url do
    Application.fetch_env!(:wanda, :auth_server)[:url]
  end
end

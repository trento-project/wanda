defmodule WandaWeb.Plugs.SwaggerUIRuntime do
  @moduledoc """
    This Plug updates the original SwaggerUI configuration, by adding the
    configuration of oas_server_url (OAS_SERVER_URL in runtime) url subpath
    to the individual urls as prefix.
    This is needed if the OAS_SERVER_URL is given, most probably because
    wanda requests are coming from a proxy.
  """
  @behaviour Plug

  alias OpenApiSpex.Plug.SwaggerUI

  @impl true
  def init(opts) do
    case Application.fetch_env!(:wanda, :oas_server_url) do
      nil ->
        opts

      oas_server_url ->
        %{path: oas_path} = URI.parse(oas_server_url)
        replace_paths(oas_path, opts)
    end
  end

  @impl true
  def call(conn, opts) do
    opts = SwaggerUI.init(opts)
    SwaggerUI.call(conn, opts)
  end

  defp replace_paths(nil, opts), do: opts
  defp replace_paths("/", opts), do: opts

  defp replace_paths(oas_path, [path: path, urls: urls] = opts) do
    opts
    |> Keyword.replace(:path, Path.join(oas_path, path))
    |> Keyword.replace(
      :urls,
      Enum.map(urls, fn %{url: url} = url_item ->
        Map.replace(url_item, :url, Path.join(oas_path, url))
      end)
    )
  end
end

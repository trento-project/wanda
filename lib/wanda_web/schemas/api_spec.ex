defmodule WandaWeb.Schemas.ApiSpec do
  @moduledoc """
  OpenApi specification entry point

  `api_version` must be provided to specify the version of this openapi specification

  Example:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "v1"
  """

  defmacro __using__(opts) do
    api_version =
      Keyword.get(opts, :api_version) || raise ArgumentError, "expected :api_version option"

    quote do
      alias OpenApiSpex.{
        Components,
        Info,
        OpenApi,
        Paths,
        SecurityScheme,
        Server,
        Tag
      }

      alias WandaWeb.{Endpoint, Router}
      @behaviour OpenApi

      @impl OpenApi
      def spec(router \\ Router) do
        OpenApiSpex.resolve_schema_modules(%OpenApi{
          servers: [
            endpoint()
          ],
          info: %Info{
            title: "Wanda",
            description: to_string(Application.spec(:wanda, :description)),
            version: to_string(Application.spec(:wanda, :vsn))
          },
          components: %Components{
            securitySchemes: %{"authorization" => %SecurityScheme{type: "http", scheme: "bearer"}}
          },
          security: [%{"authorization" => []}],
          paths: build_paths_for_version(unquote(api_version), router),
          tags: []
        })
      end

      defp endpoint do
        if Process.whereis(Endpoint) do
          # Populate the Server info from a phoenix endpoint
          Server.from_endpoint(Endpoint)
        else
          # If the endpoint is not running, use a placeholder
          # this happens when generarting openapi.json with --start-app=false
          # e.g. mix openapi.spec.json --start-app=false --spec WandaWeb.ApiSpec
          %OpenApiSpex.Server{url: "https://demo.trento-project.io"}
        end
      end

      defp build_paths_for_version(version, router) do
        excluded_versions = List.delete(router.available_api_versions(), version)

        router
        |> Paths.from_router()
        |> Enum.reject(fn {path, _info} ->
          current_version =
            path
            |> String.trim("/")
            |> String.split("/")
            |> Enum.at(1)

          Enum.member?(excluded_versions, current_version)
        end)
        |> Map.new()
      end
    end
  end
end

defmodule WandaWeb.Schemas.ApiSpec do
  @moduledoc """
  OpenApi specification entry point

  `api_version` must be provided to specify the version of this openapi specification

  Example:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "v1"

    # For unversioned endpoints:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "unversioned"
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
            version: to_string(Application.spec(:wanda, :vsn)) <> "-" <> unquote(api_version)
          },
          components: %Components{
            securitySchemes: %{"authorization" => %SecurityScheme{type: "http", scheme: "bearer"}}
          },
          security: [%{"authorization" => []}],
          paths: build_paths_for_version(unquote(api_version), router),
          tags: [
            %Tag{
              name: "Platform",
              description: "Providing access to Wanda Platform features"
            },
          ]
        })
      end

      defp endpoint do
        if Process.whereis(Endpoint) do
          # Populate the Server info from a phoenix endpoint
          Server.from_endpoint(Endpoint)
        else
          # If the endpoint is not running, use a placeholder
          # this happens when generating openapi.json with --start-app=false
          # e.g. mix openapi.spec.json --start-app=false --spec WandaWeb.ApiSpec
          %OpenApiSpex.Server{url: "https://demo.trento-project.io"}
        end
      end

      defp build_paths_for_version(version, router) do
        router
        |> Paths.from_router()
        |> Enum.reject(fn {path, _info} ->
          current_version =
            path
            |> String.trim("/")
            |> String.split("/")
            |> Enum.at(1)

          cond do
            # When generating "unversioned" version, include only unversioned endpoints
            version == "unversioned" ->
              current_version in router.available_api_versions()

            # When generating specific version, exclude unversioned and other versions
            true ->
              excluded_versions = List.delete(router.available_api_versions(), version)

              current_version in excluded_versions or
                current_version not in router.available_api_versions()
          end
        end)
        |> Map.new()
      end
    end
  end
end

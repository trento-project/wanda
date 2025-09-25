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
        Contact,
        Info,
        License,
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
            version: to_string(Application.spec(:wanda, :vsn)) <> "-" <> unquote(api_version),
            license: %OpenApiSpex.License{
              name: "Apache 2.0",
              url: "https://www.apache.org/licenses/LICENSE-2.0"
            },
            contact: %Contact{
              name: "Trento Project",
              url: "https://www.trento-project.io",
              email: "trento-project@suse.com"
            }
          },
          components: %Components{
            securitySchemes: %{
              "authorization" => %SecurityScheme{
                type: "http",
                scheme: "bearer",
                description:
                  "This security scheme uses Bearer token authentication for API access. Please provide a valid token in the Authorization header."
              }
            }
          },
          security: [%{"authorization" => []}],
          paths: build_paths_for_version(unquote(api_version), router),
          tags: [
            %Tag{
              name: "Checks Engine",
              description:
                "Endpoints for managing and executing checks, including configuration and results retrieval."
            },
            %Tag{
              name: "Checks/Operations Platform",
              description: "Endpoints for accessing checks/operations platform features."
            },
            %Tag{
              name: "MCP",
              description:
                "Exposes endpoints as tools for Model Context Protocol (MCP) integration, enabling those endpoints to be consumed by any LLM."
            },
            %Tag{
              name: "Operations Engine",
              description:
                "Endpoints for managing and executing operations and related information."
            }
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
          %OpenApiSpex.Server{
            url: "https://demo.trento-project.io",
            description:
              "This is the Trento demo server, provided for testing and demonstration purposes."
          }
        end
      end

      defp build_paths_for_version(version, router) do
        available_versions = router.available_api_versions()

        excluded_versions = List.delete(available_versions, version)
        actual_versions = List.delete(available_versions, "unversioned")

        router
        |> Paths.from_router()
        |> Enum.reject(fn {path, _info} ->
          current_version =
            path
            |> String.trim("/")
            |> String.split("/")
            |> Enum.at(1)
            |> map_version(actual_versions)

          Enum.member?(excluded_versions, current_version)
        end)
        |> Map.new()
      end

      defp map_version(version, actual_versions) do
        case version in actual_versions do
          true -> version
          _ -> "unversioned"
        end
      end
    end
  end
end

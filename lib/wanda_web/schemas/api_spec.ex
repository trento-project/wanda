defmodule WandaWeb.Schemas.ApiSpec do
  @moduledoc """
  OpenApi specification entry point

  `api_version` must be provided to specify the version of this openapi specification

  Example:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "v1"

    # For all endpoints:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "all"

    # For unversioned endpoints:
    use WandaWeb.OpenApi.ApiSpec,
      api_version: "unversioned"
  """
  alias WandaWeb.Schemas.ApiSpec

  alias OpenApiSpex.Paths

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
            version: ApiSpec.build_version(unquote(api_version)),
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
          paths: ApiSpec.build_paths_for_version(unquote(api_version), router),
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
              name: "Operations Engine",
              description:
                "Endpoints for managing and executing operations and related information."
            }
          ]
        })
      end

      defp endpoint do
        oas_server_url = Application.fetch_env!(:wanda, :oas_server_url)

        cond do
          not is_nil(oas_server_url) ->
            %OpenApiSpex.Server{
              url: build_server_url(oas_server_url)
            }

          Process.whereis(Endpoint) ->
            %{url: url} = Server.from_endpoint(Endpoint)

            %OpenApiSpex.Server{
              url: build_server_url(url)
            }

          true ->
            %OpenApiSpex.Server{
              url: "{url}",
              variables: %{
                url: %{
                  default: build_server_url("https://demo.trento-project.io")
                }
              },
              description:
                "This is the Trento demo server, provided for testing and demonstration purposes."
            }
        end
      end

      defp build_server_url(url), do: Path.join(url, "wanda")
    end
  end

  def build_version("all"), do: to_string(Application.spec(:wanda, :vsn))
  def build_version(version), do: to_string(Application.spec(:wanda, :vsn)) <> "-" <> version

  def build_paths_for_version("all", router), do: Paths.from_router(router)

  def build_paths_for_version(version, router) do
    available_versions = router.available_api_versions()

    router
    |> Paths.from_router()
    |> Enum.filter(fn {path, _info} ->
      path
      |> String.trim("/")
      |> String.split("/")
      |> Enum.at(1)
      |> include_path?(version, available_versions)
    end)
    |> Map.new()
  end

  defp include_path?(route_api_version, "unversioned", available_versions),
    do: not Enum.member?(available_versions, route_api_version)

  defp include_path?(version, version, _available_versions),
    do: true

  defp include_path?(_route_api_version, _api_version, _available_versions),
    do: false
end

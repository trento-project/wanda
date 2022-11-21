defmodule WandaWeb.ApiSpec do
  @moduledoc false

  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias WandaWeb.{Endpoint, Router}

  @impl true
  def spec do
    # Discover request/response schemas from path specs
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      servers: [
        endpoint()
      ],
      info: %Info{
        title: "Wanda",
        version: "1.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router)
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
      %OpenApiSpex.Server{url: "https://trento-project.io/wanda"}
    end
  end
end

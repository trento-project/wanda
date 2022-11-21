defmodule WandaWeb.ApiSpec do
  @moduledoc false

  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias WandaWeb.{Endpoint, Router}

  @impl true
  def spec do
    # Discover request/response schemas from path specs
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      # Populate the Server info from a phoenix endpoint
      # If the endpoint is not running, the server info will be empty
      # this happens when generarting openapi.json with --start-app=false
      # e.g. mix openapi.spec.json --start-app=false --spec WandaWeb.ApiSpec
      servers:
        if Process.whereis(Endpoint) do
          Server.from_endpoint(Endpoint)
        end,
      info: %Info{
        title: "Wanda",
        version: "1.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router)
    })
  end
end

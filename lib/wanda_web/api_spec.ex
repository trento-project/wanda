defmodule WandaWeb.ApiSpec do
  @moduledoc false

  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias WandaWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    # Discover request/response schemas from path specs
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "Wanda",
        version: "1.0"
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router)
    })
  end
end

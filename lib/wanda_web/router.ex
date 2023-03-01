defmodule WandaWeb.Router do
  use WandaWeb, :router

  @latest_api_version "v1"

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.ApiSpec
  end

  pipeline :protected_api do
    plug Unplug,
      if: {Unplug.Predicates.AppConfigEquals, {:wanda, :jwt_authentication_enabled, true}},
      do: WandaWeb.Auth.JWTAuthPlug
  end

  scope "/api" do
    scope "/v1", WandaWeb.V1 do
      scope "/checks" do
        pipe_through [:api, :protected_api]

        resources "/executions", ExecutionController, only: [:index, :show]
        get "/groups/:id/executions/last", ExecutionController, :last
        post "/executions/start", ExecutionController, :start
        get "/catalog", CatalogController, :catalog
      end
    end
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api" do
    pipe_through :api

    match :*, "/*path/", WandaWeb.Plugs.ApiRedirector,
      latest_version: @latest_api_version,
      router: __MODULE__
  end

  get "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
    path: "/api/openapi",
    urls: [%{url: "/api/openapi", name: "Version 1"}]
end

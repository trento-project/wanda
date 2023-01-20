defmodule WandaWeb.Router do
  use WandaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.ApiSpec
  end

  pipeline :protected_api do
    if Application.get_env(:wanda, :jwt_authentication)[:enabled] do
      plug WandaWeb.Auth.JWTAuthPlug
    end
  end

  scope "/api/checks", WandaWeb do
    pipe_through [:api, :protected_api]

    resources "/executions", ExecutionController, only: [:index, :show]
    get "/groups/:id/executions/last", ExecutionController, :last
    post "/executions/start", ExecutionController, :start
    get "/catalog", CatalogController, :catalog
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
end

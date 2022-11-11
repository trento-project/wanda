defmodule WandaWeb.Router do
  use WandaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.ApiSpec

    plug CORSPlug
  end

  scope "/api/checks", WandaWeb do
    pipe_through :api

    resources "/executions", ExecutionController, only: [:index, :show]
    post "/executions/start", ExecutionController, :start
    get "/catalog", CatalogController, :catalog
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
end

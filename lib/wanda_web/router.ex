defmodule WandaWeb.Router do
  use WandaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.ApiSpec
  end

  scope "/api/checks", WandaWeb do
    pipe_through :api

    resources "/results", ResultController, only: [:index]
    get "/catalog", CatalogController, :catalog
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
end

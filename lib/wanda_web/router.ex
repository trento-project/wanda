defmodule WandaWeb.Router do
  use WandaWeb, :router

  alias OpenApiSpex.Plug.CastAndValidate

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.ApiSpec
  end

  scope "/api", WandaWeb do
    pipe_through :api
    get "/checks/executions", ExecutionsController, :list_checks_executions
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
end

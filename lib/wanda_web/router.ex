defmodule WandaWeb.Router do
  use WandaWeb, :router

  # From newest to oldest
  @available_api_versions ["v3", "v2", "v1"]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_v1 do
    plug :api
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.Schemas.V1.ApiSpec
  end

  pipeline :api_v2 do
    plug :api
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.Schemas.V2.ApiSpec
  end

  pipeline :api_v3 do
    plug :api
    plug OpenApiSpex.Plug.PutApiSpec, module: WandaWeb.Schemas.V3.ApiSpec
  end

  pipeline :protected_api do
    plug Unplug,
      if: {Unplug.Predicates.AppConfigEquals, {:wanda, :jwt_authentication_enabled, true}},
      do: WandaWeb.Auth.JWTAuthPlug
  end

  scope "/" do
    pipe_through :browser

    get "/api/doc", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/v1/openapi",
      urls: [
        %{url: "/api/v1/openapi", name: "Version 1"},
        %{url: "/api/v2/openapi", name: "Version 2"},
        %{url: "/api/v3/openapi", name: "Version 3"}
      ]
  end

  scope "/api" do
    scope "/v1", WandaWeb.V1 do
      scope "/checks" do
        pipe_through [:api_v1, :protected_api]

        resources "/executions", ExecutionController, only: [:index, :show]
        get "/groups/:id/executions/last", ExecutionController, :last
        post "/executions/start", ExecutionController, :start
        get "/catalog", CatalogController, :catalog

        get "/groups/:group_id/checks_selection", CatalogController, :selectable_checks

        post "/:check_id/customize/:group_id",
             ChecksCustomizationsController,
             :apply_custom_values
      end

      if Application.compile_env!(:wanda, :operations_enabled) do
        scope "/operations" do
          pipe_through [:api_v1, :protected_api]

          resources "/executions", OperationController, only: [:index, :show]
        end
      end
    end

    scope "/v2", WandaWeb.V2 do
      scope "/checks" do
        pipe_through [:api_v2, :protected_api]

        resources "/executions", ExecutionController, only: [:index, :show]
        get "/groups/:id/executions/last", ExecutionController, :last
        post "/executions/start", ExecutionController, :start
        get "/catalog", CatalogController, :catalog
      end
    end

    scope "/v3", WandaWeb.V3 do
      scope "/checks" do
        pipe_through [:api_v3, :protected_api]

        get "/catalog", CatalogController, :catalog
      end
    end
  end

  scope "/api" do
    pipe_through :api

    scope "/v1" do
      pipe_through :api_v1
      get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    end

    scope "/v2" do
      pipe_through :api_v2
      get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    end

    scope "/v3" do
      pipe_through :api_v3
      get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    end
  end

  scope "/api", WandaWeb do
    pipe_through :api
    get "/healthz", HealthController, :health
    get "/readyz", HealthController, :ready
  end

  scope "/api" do
    pipe_through :api

    match :*, "/*path/", WandaWeb.Plugs.ApiRedirector,
      available_api_versions: @available_api_versions,
      router: __MODULE__
  end

  def available_api_versions, do: @available_api_versions
end

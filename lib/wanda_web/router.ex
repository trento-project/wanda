defmodule WandaWeb.Router do
  use WandaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WandaWeb do
    pipe_through :api
    get "/results/:group_id", ResultsController, :results
  end
end

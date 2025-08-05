defmodule WandaWeb.HealthController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Ecto.Adapters.SQL

  alias WandaWeb.Schemas.{
    Health,
    Ready
  }

  operation :ready,
    summary: "Wanda ready.",
    tags: ["Wanda Platform"],
    description:
      "This endpoint checks if the Wanda platform is ready to accept requests and operate normally.",
    security: [],
    responses: [
      ok:
        {"This response confirms that the Wanda platform is ready for operation.",
         "application/json", Ready}
    ]

  def ready(conn, _) do
    conn
    |> put_status(200)
    |> json(%{ready: true})
  end

  operation :health,
    summary: "Wanda health.",
    tags: ["Wanda Platform"],
    description:
      "This endpoint returns the health status of the Wanda platform, including database connectivity and overall system readiness.",
    security: [],
    responses: [
      ok:
        {"This response provides the current health status of the Wanda platform, including database connectivity.",
         "application/json", Health}
    ]

  def health(conn, _) do
    db_status =
      case SQL.query(Wanda.Repo, "SELECT 1", []) do
        {:ok, _} -> :pass
        {:error, _} -> :fail
      end

    conn
    |> put_status(if db_status == :pass, do: 200, else: 500)
    |> render(:health, health: %{database: db_status})
  end
end

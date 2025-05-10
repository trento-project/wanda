defmodule WandaWeb.HealthController do
  use WandaWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Ecto.Adapters.SQL

  alias WandaWeb.Schemas.{
    Health,
    Ready
  }

  alias Wanda.Catalog

  operation :ready,
    summary: "Wanda ready",
    tags: ["Platform"],
    description: "Check if Wanda is ready",
    security: [],
    responses: [
      ok: {"Wanda is ready", "application/json", Ready}
    ]

  def ready(conn, _) do
    conn
    |> put_status(200)
    |> json(%{ready: true})
  end

  operation :health,
    summary: "Wanda health",
    tags: ["Platform"],
    description: "Get the health status of the Wanda platform",
    security: [],
    responses: [
      ok: {"Wanda health status", "application/json", Health}
    ]

  def health(conn, _) do
    db_status =
      case SQL.query(Wanda.Repo, "SELECT 1", []) do
        {:ok, _} -> :pass
        {:error, _} -> :fail
      end

    catalog_status =
      case Catalog.get_catalog() do
        [] -> :fail
        _ -> :pass
      end

    health = %{
      database: db_status,
      catalog: catalog_status
    }

    status =
      health
      |> Enum.all?(fn {_key, value} -> value == :pass end)
      |> case do
        true -> :ok
        false -> :internal_server_error
      end

    conn
    |> put_status(status)
    |> render(:health, health: health)
  end
end

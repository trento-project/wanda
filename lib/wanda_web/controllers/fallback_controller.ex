defmodule WandaWeb.FallbackController do
  use Phoenix.Controller

  alias WandaWeb.ErrorJSON

  def call(conn, {:error, :no_checks_selected}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ErrorJSON)
    |> render(:"422", reason: "No checks were selected.")
  end

  def call(conn, {:error, :already_running}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ErrorJSON)
    |> render(:"422", reason: "Execution already running.")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: ErrorJSON)
    |> render(:"403")
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: ErrorJSON)
    |> render(:"500")
  end
end

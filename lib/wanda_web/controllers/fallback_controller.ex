defmodule WandaWeb.FallbackController do
  use Phoenix.Controller

  alias WandaWeb.ErrorView

  def call(conn, {:error, :no_checks_selected}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render(:"422", reason: "No checks were selected.")
  end

  def call(conn, {:error, :already_running}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render(:"422", reason: "Execution already running.")
  end
end

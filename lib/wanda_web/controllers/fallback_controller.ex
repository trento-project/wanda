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

  def call(conn, {:error, :check_not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:"404", reason: "Referenced check was not found.")
  end

  def call(conn, {:error, :check_not_customizable}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: ErrorJSON)
    |> render(:"403", reason: "Referenced check is not customizable.")
  end

  def call(conn, {:error, :invalid_custom_values}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: ErrorJSON)
    |> render(:"400",
      reason:
        "Some of the custom values do not exist in the check, they're not customizable or a type mismatch occurred."
    )
  end

  def call(conn, {:error, :customization_not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:"404", reason: "Referenced check customization was not found.")
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: ErrorJSON)
    |> render(:"500")
  end
end

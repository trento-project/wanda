defmodule WandaWeb.FallbackControllerTest do
  use WandaWeb.ConnCase

  alias WandaWeb.FallbackController

  test "should return a 500 if the error is not handled", %{conn: conn} do
    conn =
      conn
      |> Phoenix.Controller.accepts(["json"])
      |> FallbackController.call({:error, :not_handled})

    assert %{
             "errors" => [
               %{"detail" => "An error has occurred.", "title" => "Internal Server Error"}
             ]
           } == json_response(conn, 500)
  end

  test "should return a 403 on forbidden requests", %{conn: conn} do
    conn =
      conn
      |> Phoenix.Controller.accepts(["json"])
      |> FallbackController.call({:error, :forbidden})

    assert %{
             "errors" => [
               %{"detail" => "Unauthorized to perform operation.", "title" => "Forbidden"}
             ]
           } == json_response(conn, 403)
  end
end

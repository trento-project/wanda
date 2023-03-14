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
end

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
    errors_raising_forbidden = [
      {:forbidden, "Unauthorized to perform operation."},
      {:check_not_customizable, "Referenced check is not customizable."}
    ]

    for {error, message} <- errors_raising_forbidden do
      conn =
        conn
        |> Phoenix.Controller.accepts(["json"])
        |> FallbackController.call({:error, error})

      assert %{
               "errors" => [
                 %{"detail" => message, "title" => "Forbidden"}
               ]
             } == json_response(conn, 403)
    end
  end

  test "should return a 404 on relevant errors", %{conn: conn} do
    errors_raising_not_found = [
      {:check_not_found, "Referenced check was not found."}
    ]

    for {error, message} <- errors_raising_not_found do
      conn =
        conn
        |> Phoenix.Controller.accepts(["json"])
        |> FallbackController.call({:error, error})

      assert %{
               "errors" => [
                 %{"detail" => message, "title" => "Not Found"}
               ]
             } == json_response(conn, 404)
    end
  end

  test "should return a 400 on relevant errors", %{conn: conn} do
    errors_raising_bad_request = [
      {:invalid_custom_values,
       "Some of the custom values do not exist in the check, they're not customizable or a type mismatch occurred."}
    ]

    for {error, message} <- errors_raising_bad_request do
      conn =
        conn
        |> Phoenix.Controller.accepts(["json"])
        |> FallbackController.call({:error, error})

      assert %{
               "errors" => [
                 %{"detail" => message, "title" => "Bad Request"}
               ]
             } == json_response(conn, 400)
    end
  end
end

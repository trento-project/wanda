defmodule WandaWeb.ErrorJSONTest do
  use WandaWeb.ConnCase, async: true
  alias WandaWeb.ErrorJSON

  test "renders 422.json" do
    assert ErrorJSON.render("422.json", %{reason: "Invalid values."}) == %{
             errors: [%{detail: "Invalid values.", title: "Unprocessable Entity"}]
           }
  end

  test "renders 404.json" do
    assert ErrorJSON.render("404.json", %{}) == %{
             errors: [
               %{detail: "The requested resource was not found.", title: "Not Found"}
             ]
           }
  end

  test "renders a generic error" do
    assert ErrorJSON.render("418.json", %{}) == %{
             errors: [%{detail: "An error has occurred.", title: "I'm a teapot"}]
           }
  end
end

defmodule WandaWeb.ErrorJSONTest do
  use WandaWeb.ConnCase, async: true
  alias WandaWeb.ErrorJSON

  test "renders 422.json" do
    assert ErrorJSON.render("422.json", %{reason: "Invalid values."}) == %{
             errors: [%{detail: "Invalid values.", title: "Unprocessable Entity"}]
           }
  end

  test "renders a default 404.json" do
    assert ErrorJSON.render("404.json", %{}) == %{
             errors: [
               %{detail: "The requested resource was not found.", title: "Not Found"}
             ]
           }
  end

  test "renders 404.json with custom reason" do
    assert ErrorJSON.render("404.json", %{reason: "Custom reason."}) == %{
             errors: [
               %{detail: "Custom reason.", title: "Not Found"}
             ]
           }
  end

  test "renders 400.json" do
    assert ErrorJSON.render("400.json", %{reason: "Bad request reason."}) == %{
             errors: [
               %{detail: "Bad request reason.", title: "Bad Request"}
             ]
           }
  end

  test "renders a default 403.json" do
    assert ErrorJSON.render("403.json", %{}) == %{
             errors: [
               %{
                 detail: "Unauthorized to perform operation.",
                 title: "Forbidden"
               }
             ]
           }
  end

  test "should render a 403 error with custom reason" do
    assert %{
             errors: [
               %{
                 detail: "Insufficient permissions.",
                 title: "Forbidden"
               }
             ]
           } == ErrorJSON.render("403.json", %{reason: "Insufficient permissions."})
  end

  test "renders a generic error" do
    assert ErrorJSON.render("418.json", %{}) == %{
             errors: [%{detail: "An error has occurred.", title: "I'm a teapot"}]
           }
  end
end

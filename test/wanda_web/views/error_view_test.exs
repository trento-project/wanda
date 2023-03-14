defmodule WandaWeb.ErrorViewTest do
  use WandaWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 422.json" do
    assert render(WandaWeb.ErrorView, "422.json", reason: "Invalid values.") == %{
             errors: [%{detail: "Invalid values.", title: "Unprocessable Entity"}]
           }
  end

  test "renders 404.json" do
    assert render(WandaWeb.ErrorView, "404.json", []) == %{
             errors: [
               %{detail: "The requested resource was not found.", title: "Not Found"}
             ]
           }
  end

  test "renders a generic error" do
    assert render(WandaWeb.ErrorView, "418.json", []) == %{
             errors: [%{detail: "An error has occurred.", title: "I'm a teapot"}]
           }
  end
end

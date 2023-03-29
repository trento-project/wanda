defmodule WandaWeb.HealthcheckViewTest do
  use ExUnit.Case

  import Phoenix.View

  test "should render data indicating that the database is in a healthy state" do
    assert %{database: "pass"} ==
             render(WandaWeb.HealthView, "health.json", health: %{database: "pass"})
  end

  test "should render data indicating that the database is in an unhealthy state" do
    assert %{database: "fail"} ==
             render(WandaWeb.HealthView, "health.json", health: %{database: "fail"})
  end
end

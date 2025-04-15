defmodule WandaWeb.HealthJSONTest do
  use ExUnit.Case

  alias WandaWeb.HealthJSON

  test "should render data indicating that the database is in a healthy state" do
    health = %{database: "pass", catalog: "pass"}
    assert health == HealthJSON.health(%{health: health})
  end

  test "should render data indicating that the database is in an unhealthy state" do
    health = %{database: "fail", catalog: "pass"}
    assert health == HealthJSON.health(%{health: health})
  end
end

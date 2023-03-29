defmodule WandaWeb.HealthView do
  use WandaWeb, :view

  def render("health.json", %{health: health}), do: health
end

defmodule WandaWeb.V2.CatalogView do
  use WandaWeb, :view

  def render("catalog.json", %{catalog: catalog}) do
    %{items: render_many(catalog, WandaWeb.V1.CatalogView, "check.json", as: :check)}
  end
end

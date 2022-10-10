defmodule WandaWeb.CatalogView do
  use WandaWeb, :view

  alias Wanda.Catalog.Check

  def render("list_catalog.json", %{catalog: catalog}) do
    %{data: render_many(catalog, WandaWeb.CatalogView, "check.json", as: :check)}
  end

  def render("check.json", %{check: %Check{} = check}), do: check
end

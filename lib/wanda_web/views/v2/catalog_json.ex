defmodule WandaWeb.V2.CatalogJSON do
  alias WandaWeb.V1.CatalogJSON

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, fn check -> CatalogJSON.check(check) end)}
  end
end

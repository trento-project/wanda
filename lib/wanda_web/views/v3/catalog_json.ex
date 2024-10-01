defmodule WandaWeb.V3.CatalogJSON do
  alias Wanda.Catalog.Check

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &check/1)}
  end

  def check(%Check{} = check) do
    check
  end
end

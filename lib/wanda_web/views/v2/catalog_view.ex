defmodule WandaWeb.V2.CatalogView do
  use WandaWeb, :view

  alias Wanda.Catalog.Check

  def render("catalog.json", %{catalog: catalog}) do
    %{items: render_many(catalog, WandaWeb.V2.CatalogView, "check.json", as: :check)}
  end

  def render("check.json", %{check: %Check{} = check}), do: adapt_v2(check)

  def adapt_v2(%{expectations: expectations} = check) do
    adapted_expectations =
      Enum.map(expectations, fn
        %{type: :expect_enum} = expectation -> Map.put(expectation, :type, :unknown)
        expectation -> expectation
      end)

    %{check | expectations: adapted_expectations}
  end
end

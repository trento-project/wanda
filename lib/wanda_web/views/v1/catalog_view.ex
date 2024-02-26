defmodule WandaWeb.V1.CatalogView do
  use WandaWeb, :view

  alias WandaWeb.V1.CatalogView

  alias Wanda.Catalog.Check

  def render("catalog.json", %{catalog: catalog}) do
    %{items: render_many(catalog, CatalogView, "check.json", as: :check)}
  end

  def render("check.json", %{check: %Check{} = check}), do: adapt_v1(check)

  def adapt_v1(%{expectations: expectations} = check) do
    adapted_expectations =
      Enum.map(expectations, fn
        %{type: :expect_enum} = expectation -> Map.put(expectation, :type, :unknown)
        expectation -> expectation
      end)

    %{check | expectations: adapted_expectations}
  end
end

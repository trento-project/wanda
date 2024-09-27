defmodule WandaWeb.V1.CatalogJSON do
  alias Wanda.Catalog.Check

  def catalog(%{catalog: catalog}) do
    %{items: Enum.map(catalog, &check/1)}
  end

  def check(%Check{} = check), do: adapt_v1(check)

  def adapt_v1(%{expectations: expectations} = check) do
    adapted_expectations =
      expectations
      |> Enum.map(fn
        %{type: :expect_enum} = expectation -> Map.put(expectation, :type, :unknown)
        expectation -> expectation
      end)
      |> Enum.map(&Map.drop(Map.from_struct(&1), [:warning_message]))

    %{check | expectations: adapted_expectations}
  end
end

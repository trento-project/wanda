defmodule Wanda.Support.CatalogCase do
  @moduledoc """
  Base case for testing the checks catalog only against fixtures in the `test/fixtures/catalog` directory.

  This is needed to exclude fixtures in `test/fixtures/non_scalar_values_catalog` in controller tests where the response is expected to only have scalar values.

  """
  use ExUnit.CaseTemplate

  setup do
    configured_paths = Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_paths]

    Application.put_env(
      :wanda,
      Wanda.Catalog,
      catalog_paths: List.delete_at(configured_paths, 1)
    )

    on_exit(fn ->
      Application.put_env(
        :wanda,
        Wanda.Catalog,
        catalog_paths: configured_paths
      )
    end)

    :ok
  end
end

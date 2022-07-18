defmodule Wanda.Catalog do
  @moduledoc """
  Function to interact with the checks catalog.
  """

  @catalog_path Application.compile_env!(:wanda, [__MODULE__, :catalog_path])

  def get_facts_names(check_id) do
    check_id
    |> get_check()
    |> Map.get("facts")
    |> Enum.map(& &1["name"])
  end

  def get_expectations(check_id) do
    check_id
    |> get_check()
    |> Map.fetch!("expectations")
  end

  defp get_check(check_id) do
    @catalog_path
    |> Path.join("#{check_id}.yaml")
    |> YamlElixir.read_from_file!()
  end
end

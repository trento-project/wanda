defmodule Wanda.Catalog do
  @moduledoc """
  Function to interact with the checks catalog.
  """

  alias Wanda.Catalog.Expectation

  @catalog_path Application.compile_env!(:wanda, [__MODULE__, :catalog_path])

  @doc """
  Get a list of expectations for a given check.
  """
  @spec get_expectations(String.t()) :: [Expectation.t()]
  def get_expectations(check_id) do
    check_id
    |> get_check()
    |> Map.fetch!("expectations")
    |> Enum.map(&map_expectation/1)
  end

  def get_expectation(check_id, name) do
    check_id
    |> get_expectations()
    |> Enum.find(&(&1.name == name))
  end

  defp get_check(check_id) do
    @catalog_path
    |> Path.join("#{check_id}.yaml")
    |> YamlElixir.read_from_file!()
  end

  defp map_expectation(%{"name" => name, "expect" => expression}) do
    %Expectation{
      name: name,
      type: :expect,
      expression: expression
    }
  end

  defp map_expectation(%{"name" => name, "expect_same" => expression}) do
    %Expectation{
      name: name,
      type: :expect_same,
      expression: expression
    }
  end
end

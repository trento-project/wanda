defmodule Wanda.Catalog do
  @moduledoc """
  Function to interact with the checks catalog.
  """

  alias Wanda.Catalog.{
    Check,
    Expectation,
    Fact
  }

  @default_severity :critical

  @doc """
  Get a check from the catalog.
  """
  def get_check(check_id) do
    get_catalog_path()
    |> Path.join("#{check_id}.yaml")
    |> YamlElixir.read_from_file!()
    |> map_check()
  end

  defp get_catalog_path do
    Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_path]
  end

  defp map_check(
         %{
           "id" => id,
           "name" => name,
           "facts" => facts,
           "expectations" => expectations
         } = check
       ) do
    %Check{
      id: id,
      name: name,
      severity: map_severity(check),
      facts: Enum.map(facts, &map_fact/1),
      expectations: Enum.map(expectations, &map_expectation/1)
    }
  end

  defp map_severity(%{"severity" => "critical"}), do: :critical
  defp map_severity(%{"severity" => "warning"}), do: :warning
  defp map_severity(_), do: @default_severity

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

  defp map_fact(%{"name" => name, "gatherer" => gatherer, "argument" => argument}) do
    %Fact{
      name: name,
      gatherer: gatherer,
      argument: argument
    }
  end
end

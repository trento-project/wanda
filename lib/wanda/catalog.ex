defmodule Wanda.Catalog do
  @moduledoc """
  Function to interact with the checks catalog.
  """

  alias Wanda.Catalog.{
    Check,
    Condition,
    Expectation,
    Fact,
    Value
  }

  @default_severity :critical

  @doc """
  Get the checks catalog with all checks
  """
  @spec get_catalog() :: [Check.t()]
  def get_catalog do
    get_catalog_path()
    |> Path.join("/*")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".yaml"))
    |> Enum.map(&get_check(&1))
  end

  @doc """
  Get a check from the catalog.
  """
  @spec get_check(String.t()) :: Check.t()
  def get_check(check_id) do
    get_catalog_path()
    |> Path.join("#{check_id}.yaml")
    |> YamlElixir.read_from_file!()
    |> map_check()
  end

  @doc """
  Get specific checks from the catalog.
  """
  @spec get_checks([String.t()]) :: [Check.t()]
  def get_checks(checks_id) do
    Enum.map(checks_id, &get_check/1)
  end

  defp get_catalog_path do
    Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_path]
  end

  defp map_check(
         %{
           "id" => id,
           "name" => name,
           "group" => group,
           "description" => description,
           "remediation" => remediation,
           "facts" => facts,
           "expectations" => expectations
         } = check
       ) do
    %Check{
      id: id,
      name: name,
      group: group,
      description: description,
      remediation: remediation,
      severity: map_severity(check),
      facts: Enum.map(facts, &map_fact/1),
      values: map_values(check),
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

  defp map_fact(%{"name" => name, "gatherer" => gatherer} = fact) do
    %Fact{
      name: name,
      gatherer: gatherer,
      argument: Map.get(fact, "argument", "")
    }
  end

  defp map_values(%{"values" => values}) do
    Enum.map(values, &map_value/1)
  end

  defp map_values(_), do: []

  defp map_value(%{"name" => name, "default" => default} = value) do
    conditions =
      value
      |> Map.get("conditions", [])
      |> Enum.map(fn %{"value" => condition_value, "when" => expression} ->
        %Condition{
          value: condition_value,
          expression: expression
        }
      end)

    %Value{name: name, default: default, conditions: conditions}
  end
end

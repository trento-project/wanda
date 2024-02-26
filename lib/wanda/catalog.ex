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

  alias Wanda.EvaluationEngine

  require Logger

  @default_severity :critical

  @doc """
  Get the checks catalog with all checks
  """
  @spec get_catalog(%{String.t() => String.t()}) :: [Check.t()]
  def get_catalog(env \\ %{}) do
    get_catalog_path()
    |> Path.join("/*")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".yaml"))
    |> get_checks(env)
  end

  @doc """
  Get a check from the catalog.
  """
  @spec get_check(String.t()) :: {:ok, Check.t()} | {:error, any}
  def get_check(check_id) do
    with path <- Path.join(get_catalog_path(), "#{check_id}.yaml"),
         {:ok, file_content} <- YamlElixir.read_from_file(path),
         {:ok, check} <- map_check(file_content) do
      {:ok, check}
    else
      {:error, :malformed_check} = error ->
        Logger.error(
          "Check with ID #{check_id} is malformed. Check if all the required fields are present."
        )

        error

      {:error, reason} = error ->
        Logger.error("Error getting Check with ID #{check_id}: #{inspect(reason)}")
        error
    end
  end

  @doc """
  Get specific checks from the catalog.
  """
  @spec get_checks([String.t()], map()) :: [Check.t()]
  def get_checks(checks_id, env) do
    checks_id
    |> Enum.flat_map(fn check_id ->
      case get_check(check_id) do
        {:ok, check} -> [check]
        {:error, _} -> []
      end
    end)
    |> Enum.filter(fn check -> when_condition(check, env) && match_metadata(check, env) end)
  end

  defp when_condition(_, env) when env == %{}, do: true

  defp when_condition(%Check{when: nil}, _), do: true

  defp when_condition(%Check{when: when_clause}, env) do
    engine = EvaluationEngine.new()

    case EvaluationEngine.eval(engine, when_clause, %{"env" => env}) do
      {:ok, true} -> true
      _ -> false
    end
  end

  defp match_metadata(_, env) when env == %{}, do: true

  defp match_metadata(%Check{metadata: nil}, _), do: true

  defp match_metadata(%Check{metadata: metadata}, env) do
    env
    |> Map.to_list()
    |> Enum.all?(fn {key, env_value} ->
      metadata_value = Map.get(metadata, key)

      match_metadata_value?(env_value, metadata_value)
    end)
  end

  defp match_metadata_value?(_env_value, nil), do: true

  defp match_metadata_value?(env_value, metadata_value) when is_list(metadata_value),
    do: Enum.any?(metadata_value, fn value -> match_metadata_value?(env_value, value) end)

  defp match_metadata_value?(env_value, metadata_value), do: env_value === metadata_value

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
    {:ok,
     %Check{
       id: id,
       name: name,
       group: group,
       description: description,
       remediation: remediation,
       metadata: Map.get(check, "metadata"),
       when: Map.get(check, "when"),
       premium: Map.get(check, "premium", false),
       severity: map_severity(check),
       facts: Enum.map(facts, &map_fact/1),
       values: map_values(check),
       expectations: Enum.map(expectations, &map_expectation/1)
     }}
  end

  defp map_check(_), do: {:error, :malformed_check}

  defp map_severity(%{"severity" => "critical"}), do: :critical
  defp map_severity(%{"severity" => "warning"}), do: :warning
  defp map_severity(_), do: @default_severity

  defp map_expectation(%{"name" => name, "expect" => expression} = expectation) do
    %Expectation{
      name: name,
      type: :expect,
      expression: expression,
      failure_message: Map.get(expectation, "failure_message")
    }
  end

  defp map_expectation(%{"name" => name, "expect_same" => expression} = expectation) do
    %Expectation{
      name: name,
      type: :expect_same,
      expression: expression,
      failure_message: Map.get(expectation, "failure_message")
    }
  end

  defp map_expectation(%{"name" => name, "expect_enum" => expression} = expectation) do
    %Expectation{
      name: name,
      type: :expect_enum,
      expression: expression,
      failure_message: Map.get(expectation, "failure_message"),
      warning_message: Map.get(expectation, "warning_message")
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

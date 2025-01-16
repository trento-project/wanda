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

  require Wanda.Catalog.Enums.ExpectType, as: ExpectType
  require Wanda.Catalog.Enums.Severity, as: Severity

  @default_severity Severity.critical()

  @doc """
  Get the checks catalog with all checks
  """
  @spec get_catalog(%{String.t() => String.t()}) :: [Check.t()]
  def get_catalog(env \\ %{}) do
    get_catalog_paths()
    |> Enum.flat_map(fn path ->
      path
      |> Path.join("/*")
      |> Path.wildcard()
      |> Enum.map(&Path.basename(&1, ".yaml"))
    end)
    |> get_checks(env)
  end

  @doc """
  Get a check from the catalog.
  """
  @spec get_check(String.t(), String.t()) :: {:ok, Check.t()} | {:error, any}
  def get_check(path, check_id) do
    with path <- Path.join(path, "#{check_id}.yaml"),
         {:ok, file_content} <- read_check(path, check_id) do
      map_check(file_content, check_id)
    end
  end

  @doc """
  Get specific checks from the catalog.
  """
  @spec get_checks([String.t()], map()) :: [Check.t()]
  def get_checks(checks_id, env) do
    get_catalog_paths()
    |> Enum.flat_map(fn path ->
      get_checks_from_path(checks_id, path)
    end)
    |> Enum.filter(fn check -> when_condition(check, env) && match_metadata(check, env) end)
  end

  defp read_check(path, check_id) do
    case YamlElixir.read_from_file(path) do
      {:ok, file_content} ->
        {:ok, file_content}

      {:error, %YamlElixir.FileNotFoundError{}} = error ->
        error

      {:error, reason} = error ->
        Logger.error("Error getting Check with ID #{check_id}: #{inspect(reason)}")
        error
    end
  end

  defp get_checks_from_path(checks_id, path) do
    Enum.flat_map(checks_id, fn check_id ->
      case get_check(path, check_id) do
        {:ok, check} -> [check]
        {:error, _} -> []
      end
    end)
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

  defp get_catalog_paths do
    Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_paths]
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
         } = check,
         _
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
       severity: map_severity(check),
       facts: Enum.map(facts, &map_fact/1),
       values: map_values(check),
       expectations: Enum.map(expectations, &map_expectation/1)
     }}
  end

  defp map_check(_, id) do
    Logger.error(
      "Check with ID #{id} is malformed. Check if all the required fields are present."
    )

    {:error, :malformed_check}
  end

  defp map_severity(%{"severity" => "critical"}), do: Severity.critical()
  defp map_severity(%{"severity" => "warning"}), do: Severity.warning()
  defp map_severity(_), do: @default_severity

  defp map_expectation(%{"name" => name, "expect" => expression} = expectation) do
    %Expectation{
      name: name,
      type: ExpectType.expect(),
      expression: expression,
      failure_message: Map.get(expectation, "failure_message")
    }
  end

  defp map_expectation(%{"name" => name, "expect_same" => expression} = expectation) do
    %Expectation{
      name: name,
      type: ExpectType.expect_same(),
      expression: expression,
      failure_message: Map.get(expectation, "failure_message")
    }
  end

  defp map_expectation(%{"name" => name, "expect_enum" => expression} = expectation) do
    %Expectation{
      name: name,
      type: ExpectType.expect_enum(),
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

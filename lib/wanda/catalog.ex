defmodule Wanda.Catalog do
  @moduledoc """
  Function to interact with the checks catalog.
  """

  alias Wanda.Catalog.{
    Check,
    CheckCustomization,
    Condition,
    Expectation,
    Fact,
    SelectableCheck,
    Value
  }

  alias Wanda.ChecksCustomizations

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
  @spec get_check(String.t()) :: {:ok, Check.t()} | {:error, any}
  def get_check(check_id) do
    Enum.reduce_while(get_catalog_paths(), nil, fn path, _ ->
      with path <- Path.join(path, "#{check_id}.yaml"),
           {:ok, file_content} <- read_check(path, check_id) do
        {:halt, map_check(file_content, check_id)}
      else
        error ->
          {:cont, error}
      end
    end)
  end

  @doc """
  Get specific checks from the catalog.
  """
  @spec get_checks([String.t()], map()) :: [Check.t()]
  def get_checks(checks_ids, env) do
    checks_ids
    |> Enum.flat_map(fn check_id ->
      case get_check(check_id) do
        {:ok, check} -> [check]
        {:error, _} -> []
      end
    end)
    |> Enum.filter(fn check -> when_condition(check, env) && match_metadata(check, env) end)
  end

  @spec get_catalog_for_group(group_id :: String.t(), env :: map()) :: [SelectableCheck.t()]
  def get_catalog_for_group(group_id, env) do
    available_customizations = ChecksCustomizations.get_customizations(group_id)

    env
    |> get_catalog()
    |> Enum.map(&map_to_selectable_check(&1, available_customizations))
  end

  defp map_to_selectable_check(%Check{} = check, available_customizations) do
    mapped_values =
      check.id
      |> find_custom_values(available_customizations)
      |> map_values(check.values)

    %SelectableCheck{
      id: check.id,
      name: check.name,
      group: check.group,
      description: check.description,
      values: mapped_values,
      customizable: check.customizable,
      customized:
        check.customizable &&
          Enum.any?(mapped_values, &(&1.customizable && Map.has_key?(&1, :custom_value)))
    }
  end

  defp find_custom_values(check_id, available_customizations) do
    Enum.find_value(available_customizations, [], fn
      %CheckCustomization{check_id: ^check_id, custom_values: custom_values} ->
        custom_values

      _ ->
        nil
    end)
  end

  defp map_values(custom_values, check_values) do
    Enum.map(check_values, fn %Value{
                                name: value_name,
                                customizable: customizable,
                                default: default_value
                              } ->
      %{
        name: value_name,
        customizable: customizable
      }
      |> maybe_add_current_value(default_value)
      |> maybe_add_customization(custom_values)
    end)
  end

  defp maybe_add_current_value(%{customizable: false} = value, _), do: value

  defp maybe_add_current_value(%{customizable: true} = value, default_value),
    do: Map.put(value, :current_value, default_value)

  defp maybe_add_customization(%{customizable: false} = value, _), do: value

  defp maybe_add_customization(
         %{
           name: value_name,
           customizable: true
         } = value,
         custom_values
       ) do
    case Enum.find(custom_values, &(&1.name == value_name)) do
      nil ->
        value

      %{value: overriding_value} ->
        Map.put(value, :custom_value, overriding_value)
    end
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
    mapped_values = map_values(check)

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
       values: mapped_values,
       expectations: Enum.map(expectations, &map_expectation/1),
       customizable:
         detect_check_customizability(mapped_values, Map.get(check, "customizable", true))
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

    %Value{
      name: name,
      default: default,
      conditions: conditions,
      customizable: detect_value_customizability(value)
    }
  end

  defp detect_value_customizability(%{"customizable" => false}), do: false

  defp detect_value_customizability(%{"default" => default_value}),
    do: not (is_list(default_value) or is_map(default_value))

  defp detect_value_customizability(_), do: true

  defp detect_check_customizability([] = _values, _root_customizability), do: false

  defp detect_check_customizability(values, root_customizability) do
    has_at_least_one_customizable_value? =
      Enum.any?(values, fn %Value{customizable: customizable} -> customizable end)

    root_customizability and has_at_least_one_customizable_value?
  end
end

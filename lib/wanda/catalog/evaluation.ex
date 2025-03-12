defmodule Wanda.Catalog.Evaluation do
  @moduledoc """
  This module provides functions to evaluate check values based on their conditions.
  """

  alias Wanda.Catalog.{Condition, CustomizedValue, ResolvedValue, Value}

  alias Wanda.EvaluationEngine

  @spec resolve_values(
          [Value.t()],
          [CustomizedValue.t()],
          map(),
          Rhai.Engine.t()
        ) :: [ResolvedValue.t()]
  def resolve_values(spec_values, customizations, env, engine \\ EvaluationEngine.new()) do
    Enum.map(spec_values, fn %Value{name: name} = specified_value ->
      %ResolvedValue{
        name: name,
        spec: specified_value,
        customized: false
      }
      |> add_default_value(specified_value, env, engine)
      |> add_custom_value(Enum.find(customizations, &(&1.name == name)))
    end)
  end

  defp add_default_value(
         %ResolvedValue{} = resolved_value,
         %Value{} = spec,
         evaluation_scope,
         engine
       ) do
    %ResolvedValue{
      resolved_value
      | default_value: resolve_default_value(spec, evaluation_scope, engine)
    }
  end

  defp add_custom_value(%ResolvedValue{} = resolved_value, nil = _customized_value),
    do: resolved_value

  defp add_custom_value(%ResolvedValue{} = resolved_value, %CustomizedValue{value: custom_value}),
    do: %ResolvedValue{
      resolved_value
      | custom_value: custom_value,
        customized: true
    }

  defp resolve_default_value(
         %Value{default: default, conditions: conditions},
         env,
         engine
       ) do
    Enum.find_value(conditions, default, fn %Condition{value: value, expression: expression} ->
      case EvaluationEngine.eval(engine, expression, %{"env" => env}) do
        {:ok, true} ->
          value

        _ ->
          false
      end
    end)
  end
end

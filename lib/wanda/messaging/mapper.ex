defmodule Wanda.Messaging.Mapper do
  @moduledoc """
  Maps domain structures to integration events.
  """

  alias Wanda.Catalog

  alias Wanda.Executions.{
    Fact,
    FactError,
    Result,
    Target
  }

  alias Wanda.Operations.{
    OperationTarget,
    OperatorError,
    OperatorResult
  }

  alias Trento.Checks.V1.{
    ExecutionCompleted,
    ExecutionRequested,
    ExecutionStarted,
    FactRequest,
    FactsGathered,
    FactsGatheringRequested,
    FactsGatheringRequestedTarget
  }

  alias Trento.Checks.V1.{
    CheckCustomizationApplied,
    CheckCustomizationReset,
    CheckCustomValue
  }

  alias Trento.Operations.V1.{
    OperationCompleted,
    OperationRequested,
    OperationStarted,
    OperatorExecutionCompleted,
    OperatorExecutionRequested,
    OperatorExecutionRequestedTarget
  }

  require Wanda.Operations.Enums.OperatorPhase, as: OperatorPhase

  @spec to_execution_started(String.t(), String.t(), [Target.t()]) :: ExecutionStarted.t()
  def to_execution_started(execution_id, group_id, targets) do
    %ExecutionStarted{
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &map_target(&1))
    }
  end

  def to_facts_gathering_requested(execution_id, group_id, targets, checks) do
    %FactsGatheringRequested{
      execution_id: execution_id,
      group_id: group_id,
      targets: Enum.map(targets, &to_facts_gathering_requested_target(&1, checks))
    }
  end

  def to_execution_completed(
        %Result{
          execution_id: execution_id,
          group_id: group_id,
          result: result
        },
        target_type
      ) do
    %ExecutionCompleted{
      execution_id: execution_id,
      group_id: group_id,
      result: map_result(result),
      target_type: target_type
    }
  end

  @spec from_execution_requested(ExecutionRequested.t()) :: %{
          execution_id: String.t(),
          group_id: String.t(),
          targets: [Target.t()],
          target_type: String.t() | nil,
          env: %{String.t() => boolean() | number() | String.t() | nil}
        }
  def from_execution_requested(%ExecutionRequested{
        execution_id: execution_id,
        group_id: group_id,
        targets: targets,
        target_type: target_type,
        env: env
      }) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      targets: Target.map_targets(targets),
      target_type: target_type,
      env: from_value(env)
    }
  end

  @spec from_facts_gathererd(FactsGathered.t()) :: %{
          execution_id: String.t(),
          group_id: String.t(),
          agent_id: String.t(),
          facts_gathered: [Fact.t() | FactError.t()]
        }
  def from_facts_gathererd(%FactsGathered{
        execution_id: execution_id,
        group_id: group_id,
        agent_id: agent_id,
        facts_gathered: facts_gathered
      }) do
    %{
      execution_id: execution_id,
      group_id: group_id,
      agent_id: agent_id,
      facts_gathered:
        Enum.map(facts_gathered, fn %{check_id: check_id, name: name, fact_value: fact_value} ->
          from_gathered_fact(check_id, name, fact_value)
        end)
    }
  end

  @spec to_operation_started(String.t(), String.t(), String.t(), [OperationTarget.t()]) ::
          OperationStarted.t()
  def to_operation_started(operation_id, group_id, operation_type, targets) do
    %OperationStarted{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      targets: Enum.map(targets, &map_operation_target(&1))
    }
  end

  @spec to_operation_completed(String.t(), String.t(), String.t(), atom()) ::
          OperationCompleted.t()
  def to_operation_completed(operation_id, group_id, operation_type, result) do
    %OperationCompleted{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      result: map_operation_result(result)
    }
  end

  @spec from_operation_requested(OperationRequested.t()) :: %{
          operation_id: String.t(),
          group_id: String.t(),
          operation_type: String.t(),
          targets: [OperationTarget.t()]
        }
  def from_operation_requested(%OperationRequested{
        operation_id: operation_id,
        group_id: group_id,
        operation_type: operation_type,
        targets: targets
      }) do
    %{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      targets:
        Enum.map(targets, fn %{agent_id: agent_id, arguments: arguments} ->
          %OperationTarget{agent_id: agent_id, arguments: from_value(arguments)}
        end)
    }
  end

  @spec to_operator_execution_requested(String.t(), String.t(), number(), String.t(), [
          OperationTarget.t()
        ]) ::
          OperatorExecutionRequested.t()
  def to_operator_execution_requested(operation_id, group_id, step_number, operator, targets) do
    %OperatorExecutionRequested{
      operation_id: operation_id,
      group_id: group_id,
      step_number: step_number,
      operator: operator,
      targets:
        Enum.map(targets, fn %{agent_id: agent_id, arguments: arguments} ->
          %OperatorExecutionRequestedTarget{
            agent_id: agent_id,
            arguments: map_value(arguments)
          }
        end)
    }
  end

  @spec from_operator_execution_completed(OperatorExecutionCompleted.t()) :: %{
          operation_id: String.t(),
          group_id: String.t(),
          step_number: number(),
          agent_id: String.t(),
          operator_result: OperatorResult.t() | OperatorError.t()
        }
  def from_operator_execution_completed(%OperatorExecutionCompleted{
        operation_id: operation_id,
        group_id: group_id,
        step_number: step_number,
        agent_id: agent_id,
        result: result
      }) do
    %{
      operation_id: operation_id,
      group_id: group_id,
      step_number: step_number,
      agent_id: agent_id,
      operator_result: from_operator_result(result)
    }
  end

  @spec to_check_customization_applied(
          String.t(),
          String.t(),
          String.t(),
          [Catalog.CustomizedValue.t()]
        ) :: CheckCustomizationApplied.t()
  def to_check_customization_applied(check_id, group_id, target_type, custom_values) do
    %CheckCustomizationApplied{
      check_id: check_id,
      group_id: group_id,
      target_type: target_type,
      custom_values:
        Enum.map(custom_values, fn %{name: name, value: value} ->
          %CheckCustomValue{
            name: name,
            value: map_check_custom_value(value)
          }
        end)
    }
  end

  @spec to_check_customization_reset(
          String.t(),
          String.t(),
          String.t()
        ) :: CheckCustomizationReset.t()
  def to_check_customization_reset(check_id, group_id, target_type) do
    %CheckCustomizationReset{
      check_id: check_id,
      group_id: group_id,
      target_type: target_type
    }
  end

  defp map_target(%Target{agent_id: agent_id, checks: checks}) do
    %Trento.Checks.V1.Target{agent_id: agent_id, checks: checks}
  end

  defp map_operation_target(%OperationTarget{agent_id: agent_id, arguments: arguments}) do
    %Trento.Operations.V1.OperationTarget{
      agent_id: agent_id,
      arguments: map_value(arguments)
    }
  end

  defp to_facts_gathering_requested_target(
         %Target{agent_id: agent_id, checks: target_checks},
         checks
       ) do
    fact_requests =
      checks
      |> Enum.filter(&(&1.id in target_checks))
      |> Enum.flat_map(fn %Catalog.Check{id: check_id, facts: facts} ->
        map_fact_requests(check_id, facts)
      end)

    %FactsGatheringRequestedTarget{agent_id: agent_id, fact_requests: fact_requests}
  end

  defp map_fact_requests(check_id, facts) do
    Enum.map(facts, fn %Catalog.Fact{name: name, gatherer: gatherer, argument: argument} ->
      %FactRequest{check_id: check_id, name: name, gatherer: gatherer, argument: argument}
    end)
  end

  defp map_result(:passing), do: :PASSING
  defp map_result(:warning), do: :WARNING
  defp map_result(:critical), do: :CRITICAL

  defp map_operation_result(:updated), do: :UPDATED
  defp map_operation_result(:not_updated), do: :NOT_UPDATED
  defp map_operation_result(:rolled_back), do: :ROLLED_BACK
  defp map_operation_result(:failed), do: :FAILED
  defp map_operation_result(:timeout), do: :FAILED
  defp map_operation_result(:aborted), do: :ABORTED
  defp map_operation_result(:skipped), do: :NOT_UPDATED
  defp map_operation_result(:not_executed), do: :NOT_UPDATED
  defp map_operation_result(:already_running), do: :ALREADY_RUNNING

  defp map_value(map) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {key, map_value(value)} end)
  end

  defp map_value(value) when is_number(value), do: %{kind: {:number_value, value}}

  defp map_value(value) when is_boolean(value), do: %{kind: {:bool_value, value}}

  defp map_value(value), do: %{kind: {:string_value, value}}

  defp map_check_custom_value(value) when is_integer(value), do: {:int_value, value}
  defp map_check_custom_value(value) when is_number(value), do: {:number_value, value}
  defp map_check_custom_value(value) when is_boolean(value), do: {:bool_value, value}
  defp map_check_custom_value(value), do: {:string_value, value}

  defp from_gathered_fact(check_id, name, {:error_value, %{type: type, message: message}}),
    do: %FactError{check_id: check_id, name: name, type: type, message: message}

  defp from_gathered_fact(check_id, name, {:value, value}),
    do: %Fact{check_id: check_id, name: name, value: from_value(value)}

  defp from_operator_result(
         {:value, %{phase: phase, diff: %{before: before, after: after_value}}}
       ),
       do: %OperatorResult{
         phase: from_operator_phase(phase),
         diff: %{before: from_value(before), after: from_value(after_value)}
       }

  defp from_operator_result({:error, %{phase: phase, message: message}}),
    do: %OperatorError{phase: from_operator_phase(phase), message: message}

  defp from_operator_phase(:PLAN), do: OperatorPhase.plan()
  defp from_operator_phase(:COMMIT), do: OperatorPhase.commit()
  defp from_operator_phase(:VERIFY), do: OperatorPhase.verify()
  defp from_operator_phase(:ROLLBACK), do: OperatorPhase.rollback()

  defp from_value(%{kind: map}) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {key, from_value(value)} end)
  end

  defp from_value(%{kind: {:list_value, %{values: values}}}) do
    Enum.map(values, &from_value/1)
  end

  defp from_value(%{kind: {:struct_value, %{fields: fields}}}) do
    Enum.into(fields, %{}, fn {key, value} -> {key, from_value(value)} end)
  end

  defp from_value(%{kind: {:number_value, value}}) do
    truncated = trunc(value)
    if truncated == value, do: truncated, else: value
  end

  defp from_value(%{kind: {:null_value, _}}), do: nil
  defp from_value(%{kind: {:null_value}}), do: nil
  defp from_value(%{kind: {_, value}}), do: value

  defp from_value(map) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {key, from_value(value)} end)
  end
end

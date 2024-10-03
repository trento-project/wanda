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
    OperationTarget
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

  alias Trento.Operations.V1.{
    OperationCompleted,
    OperationExecutionCompleted,
    OperationExecutionRequested,
    OperationExecutionRequestedTarget,
    OperationRequested,
    OperationStarted
  }

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

  def to_operation_completed(operation_id, group_id, operation_type, result) do
    %OperationCompleted{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      result: map_operation_result(result)
    }
  end

  def to_operation_execution_requested(operation_id, group_id, step_number, operator, targets) do
    %OperationExecutionRequested{
      operation_id: operation_id,
      group_id: group_id,
      step_number: step_number,
      targets:
        Enum.map(targets, fn %{agent_id: agent_id, arguments: arguments} ->
          %OperationExecutionRequestedTarget{
            agent_id: agent_id,
            name: "",
            operator: operator,
            arguments: map_google_struct(arguments)
          }
        end)
    }
  end

  def to_operation_started(operation_id, group_id, operation_type, targets) do
    %OperationStarted{
      operation_id: operation_id,
      group_id: group_id,
      operation_type: operation_type,
      targets:
        Enum.map(targets, fn %{agent_id: agent_id, arguments: arguments} ->
          %Trento.Operations.V1.OperationTarget{
            agent_id: agent_id,
            arguments: map_google_struct(arguments)
          }
        end)
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
      env: Map.new(env, fn {key, %{kind: value}} -> {key, map_env_entry(value)} end)
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
          map_gathered_fact(check_id, name, fact_value)
        end)
    }
  end

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
          %OperationTarget{
            agent_id: agent_id,
            arguments:
              Map.new(arguments, fn {key, %{kind: value}} -> {key, map_env_entry(value)} end)
          }
        end)
    }
  end

  def from_operation_execution_completed(%OperationExecutionCompleted{
        operation_id: operation_id,
        group_id: group_id,
        step_number: step_number,
        agent_id: agent_id,
        operation_result: operation_result
      }) do
    %{
      operation_id: operation_id,
      group_id: group_id,
      step_number: step_number,
      agent_id: agent_id,
      operation_result: map_operation_execution_completed(operation_result)
    }
  end

  defp map_target(%Target{agent_id: agent_id, checks: checks}) do
    %Trento.Checks.V1.Target{agent_id: agent_id, checks: checks}
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

  defp map_gathered_fact(check_id, name, {:error_value, %{type: type, message: message}}),
    do: %FactError{check_id: check_id, name: name, type: type, message: message}

  defp map_gathered_fact(check_id, name, {:value, value}),
    do: %Fact{check_id: check_id, name: name, value: map_value(value)}

  defp map_operation_execution_completed({:error_value, _}),
    do: :failed

  defp map_operation_execution_completed({:response, %{phase: :COMMIT}}),
    do: :updated

  defp map_operation_execution_completed({:response, %{phase: :PLAN}}),
    do: :not_updated

  defp map_value(%{kind: {:list_value, %{values: values}}}) do
    Enum.map(values, &map_value/1)
  end

  defp map_value(%{kind: {:struct_value, %{fields: fields}}}) do
    Enum.into(fields, %{}, fn {key, value} -> {key, map_value(value)} end)
  end

  defp map_value(%{kind: {:number_value, value}}) do
    truncated = trunc(value)
    if truncated == value, do: truncated, else: value
  end

  defp map_value(%{kind: {:null_value, _}}) do
    nil
  end

  defp map_value(%{kind: {_, value}}) do
    value
  end

  defp map_env_entry({_, value}), do: value
  defp map_env_entry({:null_value}), do: nil

  defp map_google_struct(items),
    do: Enum.into(items, %{}, fn {key, value} -> {key, map_google_value(value)} end)

  defp map_google_value(value) when is_binary(value),
    do: %{kind: {:string_value, value}}

  defp map_google_value(value) when is_integer(value),
    do: %{kind: {:number_value, value}}

  defp map_google_value(value) when is_boolean(value),
    do: %{kind: {:bool_value, value}}

  defp map_google_value(value) when is_nil(value),
    do: %{kind: {:null_value, value}}

  defp map_google_value(value) when is_list(value),
    do: %{kind: {:list_value, %{values: Enum.map(value, &map_google_value/1)}}}

  defp map_google_value(value) when is_map(value),
    do: %{
      kind:
        {:struct_value,
         %{fields: Enum.into(value, %{}, fn {key, value} -> {key, map_google_value(value)} end)}}
    }
end

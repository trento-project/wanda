defmodule Wanda.Executions.ServerBehaviour do
  @moduledoc """
  Execution server API behaviour.
  """

  alias Wanda.Executions.{Fact, FactError, Target}

  @callback start_execution(
              execution_id :: String.t(),
              group_id :: String.t(),
              targets :: [Target.t()],
              target_type :: String.t() | nil,
              env :: %{String.t() => boolean() | number() | String.t()}
            ) :: :ok | {:error, :no_checks_selected} | {:error, :already_running}

  @callback start_execution(
              execution_id :: String.t(),
              group_id :: String.t(),
              targets :: [Target.t()],
              target_type :: String.t() | nil,
              env :: %{String.t() => boolean() | number() | String.t()},
              config :: Keyword.t()
            ) :: :ok | {:error, any}

  @callback receive_facts(
              execution_id :: String.t(),
              group_id :: String.t(),
              agent_id :: String.t(),
              facts :: [Fact.t() | FactError.t()]
            ) ::
              :ok | {:error, any}
end

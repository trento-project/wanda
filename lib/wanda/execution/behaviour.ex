defmodule Wanda.Execution.Behaviour do
  @moduledoc """
  Execution API behaviour.
  """

  alias Wanda.Execution.{Fact, Target}

  @callback start_execution(
              execution_id :: String.t(),
              group_id :: String.t(),
              targets :: [Target.t()]
            ) :: :ok | {:error, any}

  @callback start_execution(
              execution_id :: String.t(),
              group_id :: String.t(),
              targets :: [Target.t()],
              config :: Keyword.t()
            ) :: :ok | {:error, any}

  @callback receive_facts(execution_id :: String.t(), agent_id :: String.t(), facts :: [Fact.t()]) ::
              :ok | {:error, any}
end

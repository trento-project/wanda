defmodule Wanda.EvaluationEngine do
  @moduledoc """
  This module wraps the Rhai engine and provides a simple interface for
  evaluating expressions.
  It also sets some default options for the engine.
  """

  alias Rhai.{Engine, Scope}

  def new do
    engine = Engine.new()

    Engine.set_fail_on_invalid_map_property(engine, true)
    # TODO: set map size, array size, string size limits
  end

  def eval(%Engine{} = engine, expression, %{} = scope) do
    scope =
      Enum.reduce(
        scope,
        Scope.new(),
        fn {key, value}, acc ->
          Scope.push(acc, key, value)
        end
      )

    Engine.eval_with_scope(engine, scope, expression)
  end
end

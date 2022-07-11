defmodule Wanda.Expectations do
  @moduledoc """
  This modules provides expectations functionalities.
  """

  alias Wanda.Facts.Fact

  @spec execute(expression :: String.t(), facts :: [Fact]) :: {:ok, number()} | {:error, any}
  def execute(expression, facts) do
    variables =
      Enum.into(facts, %{}, fn %Fact{name: name, value: value} ->
        {name, value}
      end)

    Abacus.eval(expression, variables)
  end
end

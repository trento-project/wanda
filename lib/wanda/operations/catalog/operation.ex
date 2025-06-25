defmodule Wanda.Operations.Catalog.Operation do
  @moduledoc """
  An operation is a set of actions executed step by step in agents to apply
  permanent changes in them.
  """

  alias Wanda.Operations.Catalog.Step

  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :description,
    :steps,
    required_args: []
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t(),
          steps: [Step.t()],
          required_args: [String.t()]
        }

  defmacro __using__(opts) do
    operation = opts[:operation]

    quote do
      def operation do
        unquote(operation)
      end
    end
  end

  @spec total_timeout(__MODULE__.t()) :: non_neg_integer()
  def total_timeout(%__MODULE__{steps: steps}) do
    Enum.reduce(steps, 0, fn %Step{timeout: timeout}, acc ->
      acc + timeout
    end)
  end
end

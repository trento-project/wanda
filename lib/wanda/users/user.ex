defmodule Wanda.Users.User do
  @moduledoc """
  Represents the user performing actions in the system.
  """

  defstruct [
    :id,
    :abilities
  ]

  @type ability :: %{
          name: String.t(),
          resource: String.t()
        }

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          abilities: [ability()]
        }
end

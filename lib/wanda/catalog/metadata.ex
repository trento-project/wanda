defmodule Wanda.Catalog.Metadata do
  @moduledoc """
  Represents Check Metadata.
  """

  @derive Jason.Encoder
  defstruct [:target_type, :cluster_type, :provider]

  @type t :: %__MODULE__{
          target_type: String.t(),
          cluster_type: String.t(),
          provider: [String.t()]
        }
end

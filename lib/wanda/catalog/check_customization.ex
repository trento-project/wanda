defmodule Wanda.Catalog.CheckCustomization do
  @moduledoc """
  Schema representing Customizations applied for a Check in a specific execution group.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @fields ~w(check_id group_id custom_values inserted_at updated_at)a
  @required_fields ~w(check_id group_id)a

  @custom_value_fields ~w(name value)a

  @primary_key false
  schema "check_customizations" do
    field :check_id, :string, primary_key: true
    field :group_id, Ecto.UUID, primary_key: true

    field :custom_values, {:array, :map}

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(check_customization, attrs) do
    check_customization
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_change(:custom_values, &validate_custom_values/2)
  end

  defp validate_custom_values(_, custom_values) do
    required_fields_present? =
      Enum.all?(custom_values, fn custom_value ->
        Map.keys(custom_value) == @custom_value_fields
      end)

    if required_fields_present? do
      []
    else
      [custom_values: {"invalid fields in custom values", validation: :invalid_custom_values}]
    end
  end
end

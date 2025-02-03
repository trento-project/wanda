defmodule Wanda.ChecksSelection do
  @moduledoc """
  Entry point to interact with a targeted checks selection.
  """

  alias Wanda.Catalog
  alias Wanda.Catalog.{CheckCustomization, SelectableCheck, Value}
  alias Wanda.ChecksCustomizations

  @spec selectable_checks(group_id :: String.t(), env :: map()) :: [SelectableCheck.t()]
  def selectable_checks(group_id, env) do
    available_customizations = ChecksCustomizations.get_customizations(group_id)

    env
    |> Catalog.get_catalog()
    |> Enum.map(
      &%SelectableCheck{
        id: &1.id,
        name: &1.name,
        group: &1.group,
        description: &1.description,
        values:
          &1.id
          |> find_custom_values(available_customizations)
          |> map_values(&1.values),
        customizable: &1.customizable
      }
    )
  end

  defp find_custom_values(check_id, available_customizations) do
    Enum.find_value(available_customizations, [], fn
      %CheckCustomization{check_id: ^check_id, custom_values: custom_values} ->
        custom_values

      _ ->
        nil
    end)
  end

  defp map_values(custom_values, check_values) do
    Enum.map(check_values, fn %Value{
                                name: value_name,
                                customizable: customizable,
                                default: default_value
                              } ->
      %{
        name: value_name,
        customizable: customizable
      }
      |> maybe_add_current_value(default_value)
      |> maybe_add_customization(custom_values)
    end)
  end

  defp maybe_add_current_value(%{customizable: false} = value, _), do: value

  defp maybe_add_current_value(%{customizable: true} = value, default_value),
    do: Map.put(value, :current_value, default_value)

  defp maybe_add_customization(%{customizable: false} = value, _), do: value

  defp maybe_add_customization(
         %{
           name: value_name,
           customizable: true
         } = value,
         custom_values
       ) do
    case Enum.find(custom_values, &(&1.name == value_name)) do
      nil ->
        value

      %{value: overriding_value} ->
        Map.put(value, :customization, overriding_value)
    end
  end
end

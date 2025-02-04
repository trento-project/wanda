defmodule Wanda.ChecksSelection do
  @moduledoc """
  Entry point to interact with a targeted checks selection.
  """

  alias Wanda.Catalog
  alias Wanda.Catalog.{Check, CheckCustomization, SelectableCheck, Value}
  alias Wanda.ChecksCustomizations

  @spec selectable_checks(group_id :: String.t(), env :: map()) :: [SelectableCheck.t()]
  def selectable_checks(group_id, env) do
    available_customizations = ChecksCustomizations.get_customizations(group_id)

    env
    |> Catalog.get_catalog()
    |> Enum.map(&map_to_selectable_check(&1, available_customizations))
  end

  defp map_to_selectable_check(%Check{} = check, available_customizations) do
    mapped_values =
      check.id
      |> find_custom_values(available_customizations)
      |> map_values(check.values)

    %SelectableCheck{
      id: check.id,
      name: check.name,
      group: check.group,
      description: check.description,
      values: mapped_values,
      customizable: check.customizable,
      customized:
        check.customizable &&
          Enum.any?(mapped_values, &(&1.customizable && Map.has_key?(&1, :customization)))
    }
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

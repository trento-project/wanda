defmodule Wanda.ChecksCustomizations do
  @moduledoc """
  Customization features.
  """

  alias Wanda.Catalog
  alias Wanda.Catalog.{Check, Value}
  alias Wanda.Catalog.CheckCustomization

  alias Wanda.Repo

  @type custom_value :: %{
          name: String.t(),
          value: any()
        }

  @spec customize(check_id :: String.t(), group_id :: Ecto.UUID.t(), [custom_value()]) ::
          {:ok, CheckCustomization.t()}
          | {:error, :check_not_found | :check_not_customizable | :invalid_custom_values | any()}
  def customize(check_id, group_id, custom_values) do
    with {:ok, %Check{} = check} <- load_check(check_id),
         {:ok, :customizable} <- determine_customizability(check),
         :ok <- validate_incoming_custom_values(custom_values, check) do
      apply_custom_values(check_id, group_id, custom_values)
    end
  end

  defp load_check(check_id) do
    case Catalog.get_check(check_id) do
      {:ok, %Check{}} = success ->
        success

      {:error, %YamlElixir.FileNotFoundError{}} ->
        {:error, :check_not_found}

      {:error, _} = error ->
        error
    end
  end

  defp determine_customizability(%Check{customizable: true}), do: {:ok, :customizable}

  defp determine_customizability(%Check{customizable: false}),
    do: {:error, :check_not_customizable}

  defp validate_incoming_custom_values([], _), do: {:error, :invalid_custom_values}

  defp validate_incoming_custom_values(custom_values, %Check{
         values: values
       })
       when is_list(custom_values) do
    can_customize? =
      Enum.all?(custom_values, fn %{name: customized_name, value: customized_value} ->
        case validate_value_exists_in_check(customized_name, values) do
          {:ok, %Value{customizable: customizable, default: default_value}} ->
            customizable and match_value_type(default_value, customized_value)

          {:error, :value_not_found} ->
            false
        end
      end)

    case can_customize? do
      true -> :ok
      false -> {:error, :invalid_custom_values}
    end
  end

  defp validate_incoming_custom_values(_, _), do: {:error, :invalid_custom_values}

  defp validate_value_exists_in_check(value_name, check_values) do
    Enum.find_value(
      check_values,
      {:error, :value_not_found},
      fn
        %Value{name: ^value_name} = matching_value -> {:ok, matching_value}
        _ -> false
      end
    )
  end

  defp match_value_type(specified_value, custom_value)
       when is_number(specified_value) and is_number(custom_value),
       do: true

  defp match_value_type(specified_value, custom_value)
       when is_boolean(specified_value) and is_boolean(custom_value),
       do: true

  defp match_value_type(specified_value, custom_value)
       when is_bitstring(specified_value) and is_bitstring(custom_value),
       do: true

  defp match_value_type(_, _), do: false

  defp apply_custom_values(check_id, group_id, custom_values) do
    result =
      %CheckCustomization{}
      |> CheckCustomization.changeset(%{
        check_id: check_id,
        group_id: group_id,
        custom_values: custom_values
      })
      |> Repo.insert(on_conflict: :nothing)

    case result do
      {:ok, _} = success ->
        success

      {:error, %Ecto.Changeset{}} ->
        {:error, :invalid_custom_values}
    end
  end
end

defmodule Wanda.ChecksCustomizations do
  @moduledoc """
  Customization features.
  """

  import Ecto.Query

  alias Wanda.{
    Catalog,
    Messaging,
    Repo
  }

  alias Wanda.Catalog.{
    Check,
    CheckCustomization,
    Messaging.Publisher,
    Value
  }

  alias Ecto.Multi

  require Logger

  @type custom_value :: %{
          name: String.t(),
          value: any()
        }

  @spec get_customizations(Ecto.UUID.t()) :: [CheckCustomization.t()]
  def get_customizations(group_id) do
    Repo.all(
      from c in CheckCustomization,
        where: c.group_id == ^group_id
    )
  end

  @spec customize(check_id :: String.t(), group_id :: Ecto.UUID.t(), [custom_value()]) ::
          {:ok, CheckCustomization.t()}
          | {:error, :check_not_found | :check_not_customizable | :invalid_custom_values | any()}
  def customize(check_id, group_id, custom_values) do
    with {:ok, %Check{} = check} <- load_check(check_id),
         {:ok, :customizable} <- determine_customizability(check),
         :ok <- validate_incoming_custom_values(custom_values, check) do
      apply_custom_values(check, group_id, custom_values)
    end
  end

  @spec reset_customization(check_id :: String.t(), group_id :: Ecto.UUID.t()) ::
          :ok | {:error, :customization_not_found}
  def reset_customization(check_id, group_id) do
    check_id
    |> load_check
    |> case do
      {:ok, %Check{metadata: metadata}} -> metadata
      {:error, _} -> %{}
    end
    |> reset_check_customization(check_id, group_id)
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

  defp determine_customizability(%Check{customization_disabled: false}), do: {:ok, :customizable}

  defp determine_customizability(%Check{customization_disabled: true}),
    do: {:error, :check_not_customizable}

  defp validate_incoming_custom_values([], _), do: {:error, :invalid_custom_values}

  defp validate_incoming_custom_values(custom_values, %Check{
         values: values
       })
       when is_list(custom_values) do
    can_customize? =
      Enum.all?(custom_values, fn %{name: customized_name, value: customized_value} ->
        case validate_value_exists_in_check(customized_name, values) do
          {:ok, %Value{customization_disabled: customization_disabled, default: default_value}} ->
            not customization_disabled and match_value_type(default_value, customized_value)

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
       when is_integer(specified_value) and is_integer(custom_value),
       do: true

  defp match_value_type(specified_value, custom_value)
       when is_boolean(specified_value) and is_boolean(custom_value),
       do: true

  defp match_value_type(specified_value, custom_value)
       when is_bitstring(specified_value) and is_bitstring(custom_value),
       do: true

  defp match_value_type(_, _), do: false

  defp apply_custom_values(
         %Check{id: check_id, metadata: metadata},
         group_id,
         custom_values
       ) do
    changeset =
      CheckCustomization.changeset(%CheckCustomization{}, %{
        check_id: check_id,
        group_id: group_id,
        custom_values: custom_values
      })

    result =
      Multi.new()
      |> Multi.insert(:check_customization, changeset,
        on_conflict: {:replace, [:custom_values]},
        conflict_target: [:check_id, :group_id],
        returning: true
      )
      |> Multi.run(:publish, fn _, %{check_customization: check_customization} ->
        metadata
        |> get_target_type
        |> build_customization_applied_message(check_customization)
        |> publish_message
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{check_customization: check_customization}} ->
        {:ok, check_customization}

      {:error, :check_customization, %Ecto.Changeset{}, _} ->
        {:error, :invalid_custom_values}

      {:error, :publish, reason, _} ->
        Logger.error(
          "Error while publishing check customization message. check: #{check_id}, group_id: #{group_id}, error: #{inspect(reason)}"
        )

        {:error, reason}

      {:error, reason} = error ->
        Logger.error(
          "Error while applying custom values. check: #{check_id}, group_id: #{group_id}, error: #{inspect(reason)}"
        )

        error
    end
  end

  defp reset_check_customization(metadata, check_id, group_id) do
    deletion_query =
      from c in CheckCustomization,
        where: c.group_id == ^group_id and c.check_id == ^check_id

    Multi.new()
    |> Multi.delete_all(:customization_deletion, deletion_query)
    |> Multi.run(:publish, fn _, %{customization_deletion: {deleted_items, _}} ->
      if deleted_items > 0 do
        metadata
        |> get_target_type
        |> build_customization_reset_message(check_id, group_id)
        |> publish_message
      else
        {:error, :customization_not_found}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        :ok

      {:error, :publish, reason, _} ->
        Logger.error(
          "Error while publishing check customization reset message. check: #{check_id}, group_id: #{group_id}, error: #{inspect(reason)}"
        )

        {:error, reason}

      {:error, reason} = error ->
        Logger.error(
          "Error while resetting custom values. check: #{check_id}, group_id: #{group_id}, error: #{inspect(reason)}"
        )

        error
    end
  end

  defp get_target_type(metadata),
    do: Map.get(metadata, "target_type", "unknown")

  defp build_customization_applied_message(
         target_type,
         %CheckCustomization{
           check_id: check_id,
           group_id: group_id,
           custom_values: custom_values
         }
       ) do
    Messaging.Mapper.to_check_customization_applied(
      check_id,
      group_id,
      target_type,
      custom_values
    )
  end

  defp build_customization_reset_message(
         target_type,
         check_id,
         group_id
       ) do
    Messaging.Mapper.to_check_customization_reset(
      check_id,
      group_id,
      target_type
    )
  end

  defp publish_message(message) do
    case Messaging.publish(Publisher, "customizations", message) do
      :ok ->
        {:ok, :published}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

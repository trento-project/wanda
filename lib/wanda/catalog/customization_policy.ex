defmodule Wanda.Catalog.CustomizationPolicy do
  @moduledoc """
  Policy for checks customizations.
  """
  @behaviour Bodyguard.Policy

  import Wanda.Support.AbilitiesHelper

  alias Wanda.Catalog.CheckCustomization
  alias Wanda.Users.User

  def authorize(action, %User{} = user, CheckCustomization)
      when action in [:apply_custom_values, :reset_customization],
      do: has_checks_customization_abilities?(user)

  def authorize(_, _, _), do: false

  defp has_checks_customization_abilities?(user),
    do:
      has_global_ability?(user) or
        user_has_ability?(user, %{name: "all", resource: "check_customization"})
end

defmodule Wanda.Catalog.CustomizationPolicy do
  @moduledoc """
  Policy for checks customizations.
  """
  @behaviour Bodyguard.Policy

  import Wanda.Support.AbilitiesHelper

  alias Wanda.Catalog.CheckCustomization
  alias Wanda.Users.User

  def authorize(:apply_custom_values, %User{} = user, CheckCustomization),
    do: has_checks_customization_abilities?(user)

  defp has_checks_customization_abilities?(user),
    do:
      has_global_ability?(user) or
        user_has_ability?(user, %{name: "all", resource: "check_customization"})
end

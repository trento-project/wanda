defmodule Wanda.Support.AbilitiesHelper do
  @moduledoc """
  Helper functions for bodyguard policies
  """

  def user_has_ability?(%{abilities: abilities}, %{name: name, resource: resource}),
    do: Enum.any?(abilities, &(&1.name == name and &1.resource == resource))

  def has_global_ability?(%{} = user),
    do: user_has_ability?(user, %{name: "all", resource: "all"})

  def user_has_any_ability?(%{} = user, abilities),
    do: Enum.any?(abilities, &user_has_ability?(user, &1))
end

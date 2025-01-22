defmodule WandaWeb.Auth.UserDetector do
  @moduledoc """
  This module allows extracting a very simple representation of a user from a connection.

  Only the user_id and abilities are available.
  """

  alias Wanda.Users.User

  def current_user(%{private: %{user_id: user_id, abilities: abilities}})
      when not is_nil(user_id) and is_list(abilities) do
    %User{
      id: user_id,
      abilities: abilities
    }
  end

  def current_user(_), do: nil
end

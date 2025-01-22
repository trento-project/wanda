defmodule WandaWeb.Auth.UserDetectorTest do
  use WandaWeb.ConnCase, async: false

  import Wanda.Factory

  alias WandaWeb.Auth.UserDetector

  describe "user detection" do
    test "should return nil when unable to extract relevant user information", %{conn: conn} do
      assert nil == UserDetector.current_user(conn)

      assert nil ==
               conn
               |> put_private(:user_id, nil)
               |> UserDetector.current_user()

      assert nil ==
               conn
               |> put_private(:abilities, [
                 %{
                   "name" => "foo",
                   "resource" => "bar"
                 }
               ])
               |> UserDetector.current_user()

      assert nil ==
               conn
               |> put_private(:user_id, 1)
               |> UserDetector.current_user()

      for unsupported_ability <- [nil, %{}, "foo", 1, 1.0, true, false] do
        assert nil ==
                 conn
                 |> put_private(:user_id, 1)
                 |> put_private(:abilities, unsupported_ability)
                 |> UserDetector.current_user()
      end
    end

    test "should return a lite user representation", %{conn: conn} do
      %{id: user_id, abilities: abilities} = user = build(:user)

      assert user ==
               conn
               |> put_private(:user_id, user_id)
               |> put_private(:abilities, abilities)
               |> UserDetector.current_user()

      %{id: user_id, abilities: []} = user_without_abilities = build(:user, abilities: [])

      assert user_without_abilities ==
               conn
               |> put_private(:user_id, user_id)
               |> put_private(:abilities, [])
               |> UserDetector.current_user()
    end
  end
end

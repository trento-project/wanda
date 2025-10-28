defmodule WandaWeb.Auth.AuthPlugTest do
  use WandaWeb.ConnCase, async: true

  import Mox
  import Wanda.Factory

  alias Faker.Random.Elixir, as: RandomElixir

  alias WandaWeb.Auth.AuthPlug

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "call/2" do
    test "should return the connection with the user related information" do
      active_token = Faker.String.base64(32)

      user_id = RandomElixir.random_between(1, 100)
      abilities = build_list(3, :ability)

      expect(WandaWeb.Auth.Client.AuthClientMock, :introspect_token, fn ^active_token ->
        {:ok,
         %{
           active: true,
           sub: user_id,
           abilities: abilities
         }}
      end)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> active_token)
        |> AuthPlug.call([])

      refute conn.halted
      assert conn.private.user_id == user_id

      assert conn.private.abilities == abilities
    end

    test "should return the connection with empty user abilities" do
      active_token = Faker.String.base64(32)

      user_id = RandomElixir.random_between(1, 100)

      expect(WandaWeb.Auth.Client.AuthClientMock, :introspect_token, fn ^active_token ->
        {:ok,
         %{
           active: true,
           sub: user_id,
           abilities: []
         }}
      end)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> active_token)
        |> AuthPlug.call([])

      assert conn.private.abilities == []
    end

    test "should be halted and have unauthorized status if an inactive token was passed" do
      inactive_token = Faker.String.base64(32)

      expect(WandaWeb.Auth.Client.AuthClientMock, :introspect_token, fn ^inactive_token ->
        {:ok, %{active: false}}
      end)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> inactive_token)
        |> AuthPlug.call([])

      assert conn.status == 401
      assert conn.halted
    end

    test "should be halted and have unauthorized status if no token was passed" do
      conn = AuthPlug.call(build_conn(), [])

      assert conn.status == 401
      assert conn.halted
    end
  end
end

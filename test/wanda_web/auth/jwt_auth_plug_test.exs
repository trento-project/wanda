defmodule WandaWeb.Auth.JWTAuthPlugTest do
  use WandaWeb.ConnCase, async: false

  import Mox

  alias WandaWeb.Auth.JWTAuthPlug

  setup [:set_mox_from_context, :verify_on_exit!]

  describe "call/2" do
    setup do
      stub(
        Joken.CurrentTime.Mock,
        :current_time,
        fn ->
          1_671_715_992
        end
      )

      :ok
    end

    test "should return the connection with the user_id as subject" do
      jwt =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ0cmVudG9fYXBwIiwiZXhwIjoxNjcxNzE2NTkyLCJpYXQiOjE2NzE3MTU5OTIsImlzcyI6Imh0dHBzOi8vZ2l0aHViLmNvbS90cmVudG8tcHJvamVjdC93ZWIiLCJqdGkiOiIyc3Rtb3A5NjlvdGs5M2k2NTQwMDBiZWIiLCJuYmYiOjE2NzE3MTU5OTIsInN1YiI6MSwidHlwIjoiQmVhcmVyIn0.AjZHul_2OArfDEanRIorpV85Ii4h15yRhdjJpZBMZRI"

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> jwt)
        |> JWTAuthPlug.call([])

      refute conn.halted
      assert conn.private.user_id == 1
    end

    test "should be halted and have unauthorized status if the token is expired" do
      expired_jwt =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ0cmVudG8tcHJvamVjdCIsImV4cCI6MTY3MTY0MjQxNCwiaWF0IjoxNjcxNjQxODE0LCJpc3MiOiJodHRwczovL2dpdGh1Yi5jb20vdHJlbnRvLXByb2plY3Qvd2ViIiwianRpIjoiMnNwaTFvbmxxbml1ZnE5dnVrMDAwMG9hIiwibmJmIjoxNjcxNjQxODE0LCJzdWIiOjEsInR5cCI6IkJlYXJlciJ9.oub6_NsHcVIyd0de14Lzk3SuCMMgr8O-sSWLr7Gxcp8"

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> expired_jwt)
        |> JWTAuthPlug.call([])

      assert conn.status == 401
      assert conn.halted
    end

    test "should be halted and have unauthorized status if an invalid token was passed" do
      invalid_jwt =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ0cmVudG8tcHJvamVjdCIsImV4cCI6MTY3MTU1NjY5MiwiaWF0IjoxNjcxNTQ5NDkyLCJpc3MiOiJodHRwczovL2dpdGh1Yi5jb20vdHJlbnRvLXByb2plY3Qvd2ViIiwianRpIjoiMnNwOGlxMmkxNnRlbHNycWE4MDAwMWM4IiwibmJmIjoxNjcxNTQ5NDkyLCJzdWIiOjF9.PRqQgJkfxrusFtvkwk-2utMNde0TZN9zcx7ncmVxvk8"

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer " <> invalid_jwt)
        |> JWTAuthPlug.call([])

      assert conn.status == 401
      assert conn.halted
    end

    test "should be halted and have unauthorized status if no token was passed" do
      conn = JWTAuthPlug.call(build_conn(), [])

      assert conn.status == 401
      assert conn.halted
    end
  end
end

defmodule WandaWeb.InfoControllerTest do
  @moduledoc false

  use WandaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.Unversioned.ApiSpec

  setup do
    %{api_spec: ApiSpec.spec()}
  end

  describe "Info" do
    test "returns the current Wanda instance information", %{
      conn: conn,
      api_spec: api_spec
    } do
      response =
        conn
        |> get("/api")
        |> json_response(200)

      assert %{
               "name" => "wanda",
               "version" => _,
               "checks_version" => "1.0.0"
             } = response

      assert_schema(response, "InfoV1", api_spec)
    end
  end
end

defmodule WandaWeb.Plugs.SwaggerUIRuntimeTest do
  use WandaWeb.ConnCase, async: false

  alias WandaWeb.Plugs.SwaggerUIRuntime

  @test_options [
    path: "/api/all/openapi",
    urls: [
      %{url: "/api/all/openapi", name: "All"},
      %{url: "/api/v1/openapi", name: "Version 1"}
    ]
  ]

  describe "init/1" do
    test "should use default urls if oas_server_url is nil" do
      assert @test_options == SwaggerUIRuntime.init(@test_options)
    end

    test "should use default urls if oas_server_url doesn't have any subpath" do
      on_exit(fn ->
        Application.put_env(:wanda, :oas_server_url, nil)
      end)

      for url <- ["https://my-wanda.io", "https://my-wanda.io/"] do
        Application.put_env(:wanda, :oas_server_url, url)

        assert @test_options == SwaggerUIRuntime.init(@test_options)
      end
    end

    test "should replace urls with oas_server_url subpath" do
      on_exit(fn ->
        Application.put_env(:wanda, :oas_server_url, nil)
      end)

      subpath = "/wanda"
      Application.put_env(:wanda, :oas_server_url, Path.join("https://my-wanda.io", subpath))

      assert [
               path: "/wanda/api/all/openapi",
               urls: [
                 %{url: "/wanda/api/all/openapi", name: "All"},
                 %{url: "/wanda/api/v1/openapi", name: "Version 1"}
               ]
             ] == SwaggerUIRuntime.init(@test_options)
    end
  end
end

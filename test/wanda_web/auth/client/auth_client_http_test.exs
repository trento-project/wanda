defmodule WandaWeb.Auth.Client.HTTPClientTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias WandaWeb.Auth.Client.HttpClient, as: AuthHttpClient

  @introspection_url "http://localhost:4000/api/session/token/introspect"

  @default_opts [url: @introspection_url, method: "post"]

  setup_all do
    HTTPoison.start()
    :ok
  end

  describe "token introspection" do
    test "returns error on non successful responses" do
      for status_code <- [400, 401, 403, 404, 500] do
        use_cassette :stub, stub_request(status_code: status_code) do
          assert {:error, :unable_to_get_introspect_response} =
                   AuthHttpClient.introspect_token("token")
        end
      end
    end

    test "returns error the decoding failure" do
      use_cassette :stub, stub_request(body: "invalid_json") do
        assert {:error, :cannot_decode_introspect_response} =
                 AuthHttpClient.introspect_token("token")
      end

      use_cassette :stub, stub_request(body: "{\"active\": false}") do
        assert {:ok, %{active: false}} = AuthHttpClient.introspect_token("token")
      end
    end

    test "returns the token introspection result" do
      use_cassette :stub,
                   stub_request(
                     body:
                       "{\"active\": true, \"sub\": 1, \"abilities\": [{\"name\": \"foo\", \"resource\": \"bar\"}]}"
                   ) do
        assert {:ok, %{active: true, sub: 1, abilities: [%{name: "foo", resource: "bar"}]}} ==
                 AuthHttpClient.introspect_token("token")
      end

      use_cassette :stub, stub_request(body: "{\"active\": false}") do
        assert {:ok, %{active: false}} = AuthHttpClient.introspect_token("token")
      end
    end
  end

  defp stub_request(opts), do: @default_opts ++ opts
end

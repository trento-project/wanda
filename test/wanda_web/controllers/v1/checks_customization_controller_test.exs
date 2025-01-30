defmodule WandaWeb.V1.ChecksCustomizationsControllerTest do
  use WandaWeb.ConnCase, async: true

  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.V1.ApiSpec

  setup do
    %{api_spec: ApiSpec.spec()}
  end

  describe "checks customization" do
    test "should not accept invalid body", %{conn: conn, api_spec: api_spec} do
      check_id = "ABC123"
      group_id = Faker.UUID.v4()

      missing_values_filed_errors = [
        %{
          title: "Invalid value",
          source: %{
            pointer: "/values"
          },
          detail: "Missing field: values"
        }
      ]

      invalid_body_scenarios = [
        %{
          body: nil,
          expected_errors: missing_values_filed_errors
        },
        %{
          body: %{},
          expected_errors: missing_values_filed_errors
        },
        %{
          body: "",
          expected_errors: missing_values_filed_errors
        },
        %{
          body: "{}",
          expected_errors: missing_values_filed_errors
        },
        %{
          body: %{
            values: []
          },
          expected_errors: [
            %{
              title: "Invalid value",
              source: %{
                pointer: "/values"
              },
              detail: "Array length 0 is smaller than minItems: 1"
            }
          ]
        },
        %{
          body: %{
            values: nil
          },
          expected_errors: [
            %{
              title: "Invalid value",
              source: %{
                pointer: "/values"
              },
              detail: "null value where array expected"
            }
          ]
        },
        %{
          body: "\"foo\"",
          expected_errors: [
            %{
              title: "Invalid value",
              source: %{
                pointer: "/"
              },
              detail: "Invalid object. Got: string"
            }
          ]
        },
        %{
          body: %{values: [%{value: 50}]},
          expected_errors: [
            %{
              title: "Invalid value",
              source: %{pointer: "/values/0/name"},
              detail: "Missing field: name"
            }
          ]
        },
        %{
          body: %{values: [%{name: "foo_bar"}]},
          expected_errors: [
            %{
              title: "Invalid value",
              source: %{pointer: "/values/0/value"},
              detail: "Missing field: value"
            }
          ]
        }
      ]

      for %{body: invalid_body, expected_errors: expected_errors} <- invalid_body_scenarios do
        response =
          conn
          |> put_req_header("content-type", "application/json")
          |> post("/api/v1/checks/#{check_id}/customize/#{group_id}", invalid_body)
          |> json_response(:unprocessable_entity)
          |> assert_schema("JsonErrorResponse", api_spec)

        assert %{errors: ^expected_errors} = response
      end
    end

    test "should not allow customizing a non existent check", %{conn: conn, api_spec: api_spec} do
      check_id = "ABC123"
      group_id = Faker.UUID.v4()

      request_body = %{values: [%{name: "foo", value: "bar"}]}

      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/#{check_id}/customize/#{group_id}", request_body)
        |> json_response(:not_found)
        |> assert_schema("NotFound", api_spec)

      assert %{
               errors: [
                 %{
                   title: "Not Found",
                   detail: "Referenced check was not found."
                 }
               ]
             } == response
    end

    test "should not allow customizing a non customizable check", %{
      conn: conn,
      api_spec: api_spec
    } do
      check_id = "non_customizable_check"
      group_id = Faker.UUID.v4()

      request_body = %{values: [%{name: "foo", value: "bar"}]}

      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/#{check_id}/customize/#{group_id}", request_body)
        |> json_response(:forbidden)
        |> assert_schema("Forbidden", api_spec)

      assert %{
               errors: [
                 %{
                   title: "Forbidden",
                   detail: "Referenced check is not customizable."
                 }
               ]
             } == response
    end

    test "should not allow customizing values because a mismatching name, value non customizability or type mismatch",
         %{
           conn: conn,
           api_spec: api_spec
         } do
      check_id = "mixed_values_customizability"
      group_id = Faker.UUID.v4()

      scenarios = [
        %{
          name: "value name mismatch",
          values: [
            %{
              name: "numeric_value",
              value: 42
            },
            %{
              name: "mismatching_value_name",
              value: "foo_bar"
            }
          ]
        },
        %{
          name: "non customizable value - explicitly set",
          values: [
            %{
              name: "numeric_value",
              value: 42
            },
            %{
              name: "non_customizable_string_value",
              value: "foo_bar"
            }
          ]
        },
        %{
          name: "non customizable value - inferred by non scalar type",
          values: [
            %{
              name: "numeric_value",
              value: 42
            },
            %{
              name: "list_value",
              value: "foo_bar"
            }
          ]
        },
        %{
          name: "non matching value type - numeric",
          values: [
            %{
              name: "numeric_value",
              value: "foo_bar"
            }
          ]
        },
        %{
          name: "non matching value type - string",
          values: [
            %{
              name: "customizable_string_value",
              value: 42
            }
          ]
        },
        %{
          name: "non matching value type - boolean",
          values: [
            %{
              name: "bool_value",
              value: "foo_bar"
            }
          ]
        }
      ]

      for %{values: values} <- scenarios do
        response =
          conn
          |> put_req_header("content-type", "application/json")
          |> post("/api/v1/checks/#{check_id}/customize/#{group_id}", %{
            values: values
          })
          |> json_response(:bad_request)
          |> assert_schema("BadRequest", api_spec)

        assert %{
                 errors: [
                   %{
                     title: "Bad Request",
                     detail:
                       "Some of the custom values do not exist in the check, they're not customizable or a type mismatch occurred."
                   }
                 ]
               } == response
      end
    end

    test "should allow customizing check values", %{
      conn: conn,
      api_spec: api_spec
    } do
      check_id = "mixed_values_customizability"
      group_id = Faker.UUID.v4()

      custom_values = [
        %{
          name: "numeric_value",
          value: 42
        },
        %{
          name: "customizable_string_value",
          value: "new_value"
        }
      ]

      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/checks/#{check_id}/customize/#{group_id}", %{
          values: custom_values
        })
        |> json_response(:ok)
        |> assert_schema("CustomizationResponse", api_spec)

      assert %{values: customized_values} = response

      assert length(customized_values) == 2
    end
  end
end

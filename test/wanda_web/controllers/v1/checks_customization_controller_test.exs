defmodule WandaWeb.V1.ChecksCustomizationsControllerTest do
  use WandaWeb.ConnCase, async: true
  use Wanda.Support.MessagingCase, async: true
  use WandaWeb.UserAwareConnCase

  import Ecto.Query
  import Wanda.Factory

  import OpenApiSpex.TestAssertions

  alias Wanda.Catalog.CheckCustomization
  alias WandaWeb.Schemas.V1.ApiSpec

  setup do
    %{api_spec: ApiSpec.spec()}
  end

  @allowing_abilities [
    %{
      name: "all abilities",
      abilities: [
        %{
          name: "all",
          resource: "all"
        }
      ]
    },
    %{
      name: "specific abilities",
      abilities: [
        %{
          name: "all",
          resource: "check_customization"
        }
      ]
    }
  ]

  describe "applying checks customization" do
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
          |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", invalid_body)
          |> json_response(:unprocessable_entity)
          |> assert_schema("UnprocessableEntity", api_spec)

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
        |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", request_body)
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
        |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", request_body)
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
          |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", %{
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

    for %{name: scenario_name, abilities: allowing_abilities} <- @allowing_abilities do
      @tag abilities: allowing_abilities
      test "should allow customizing check values: #{scenario_name}", %{
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
          |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", %{
            values: custom_values
          })
          |> json_response(:ok)
          |> assert_schema("CustomizationResponse", api_spec)

        assert %{values: customized_values} = response

        assert length(customized_values) == 2
      end
    end
  end

  describe "resetting check customization" do
    test "should return not found when attempting to reset a non existent check customization", %{
      conn: conn,
      api_spec: api_spec
    } do
      group_id = Faker.UUID.v4()

      %{check_id: check_id} =
        insert(:check_customization,
          group_id: group_id
        )

      insert(:check_customization,
        group_id: group_id
      )

      scenarios = [
        %{
          name: "non existent group id",
          check_id: check_id,
          group_id: Faker.UUID.v4()
        },
        %{
          name: "non existent check id",
          check_id: Faker.UUID.v4(),
          group_id: group_id
        },
        %{
          name: "non existent group and check id",
          check_id: Faker.UUID.v4(),
          group_id: Faker.UUID.v4()
        }
      ]

      for %{check_id: possibly_invalid_check_id, group_id: possibly_invalid_group_id} <- scenarios do
        assert conn
               |> delete(
                 "/api/v1/checks/#{possibly_invalid_check_id}/group/#{possibly_invalid_group_id}/customization"
               )
               |> json_response(:not_found)
               |> assert_schema("NotFound", api_spec)
      end
    end

    for %{name: scenario_name, abilities: allowing_abilities} <- @allowing_abilities do
      @tag abilities: allowing_abilities
      test "should allow resetting check customization: #{scenario_name} - something to reset", %{
        conn: conn
      } do
        group_id = Faker.UUID.v4()

        %{check_id: check_id} =
          insert(:check_customization,
            group_id: group_id
          )

        insert(:check_customization,
          group_id: group_id
        )

        assert conn
               |> delete("/api/v1/groups/#{group_id}/checks/#{check_id}/customization")
               |> response(204) == ""

        remaining_customizations =
          Wanda.Repo.all(
            from c in CheckCustomization,
              where: c.group_id == ^group_id
          )

        assert length(remaining_customizations) == 1
      end
    end
  end

  describe "forbidden actions" do
    @insufficient_abilities [
      %{
        name: "foo",
        resource: "bar"
      }
    ]

    @tag abilities: @insufficient_abilities
    test "should forbid checks customization when necessary abilities are missing", %{
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

      conn
      |> put_req_header("content-type", "application/json")
      |> post("/api/v1/groups/#{group_id}/checks/#{check_id}/customization", %{
        values: custom_values
      })
      |> json_response(:forbidden)
      |> assert_schema("Forbidden", api_spec)
    end

    @tag abilities: @insufficient_abilities
    test "should forbid resetting checks customization when necessary abilities are missing", %{
      conn: conn,
      api_spec: api_spec
    } do
      conn
      |> put_req_header("content-type", "application/json")
      |> delete("/api/v1/groups/#{Faker.UUID.v4()}/checks/#{Faker.UUID.v4()}/customization")
      |> json_response(:forbidden)
      |> assert_schema("Forbidden", api_spec)
    end
  end
end

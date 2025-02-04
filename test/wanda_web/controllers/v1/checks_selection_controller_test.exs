defmodule WandaWeb.V1.ChecksSelectionControllerTest do
  use WandaWeb.ConnCase, async: true

  import Wanda.Factory

  import OpenApiSpex.TestAssertions

  alias WandaWeb.Schemas.V1.ApiSpec

  setup do
    %{api_spec: ApiSpec.spec()}
  end

  describe "checks selection" do
    test "should return checks selection with no custom values when customizations are not available",
         %{conn: conn, api_spec: api_spec} do
      env = %{
        "id" => "mixed_values_customizability"
      }

      %{items: selectable_checks} =
        conn
        |> get("/api/v1/checks/groups/#{Faker.UUID.v4()}/checks_selection", env)
        |> json_response(:ok)
        |> assert_schema("SelectableChecksResponse", api_spec)

      assert length(selectable_checks) == 10
      refute Enum.any?(selectable_checks, & &1.customized)
    end

    test "should return checks selection with customized values",
         %{conn: conn, api_spec: api_spec} do
      customized_check_id = "mixed_values_customizability"

      scenarios = [
        %{
          group_id: Faker.UUID.v4(),
          numeric_value: 420,
          expected_customization: 420
        },
        %{
          group_id: Faker.UUID.v4(),
          numeric_value: 420.1,
          expected_customization: 420.1
        }
      ]

      for %{
            group_id: group_id,
            numeric_value: numeric_value,
            expected_customization: expected_customization
          } <- scenarios do
        insert(:check_customization,
          group_id: group_id,
          check_id: customized_check_id,
          custom_values: [
            %{
              name: "numeric_value",
              value: numeric_value
            },
            %{
              name: "customizable_string_value",
              value: "new value"
            }
          ]
        )

        env = %{
          "id" => "mixed_values_customizability"
        }

        %{items: selectable_checks} =
          conn
          |> get("/api/v1/checks/groups/#{group_id}/checks_selection", env)
          |> json_response(:ok)
          |> assert_schema("SelectableChecksResponse", api_spec)

        assert length(selectable_checks) == 10

        assert selectable_checks
               |> Enum.filter(& &1.customized)
               |> length() == 1

        assert selectable_checks
               |> Enum.filter(&(not &1.customized))
               |> length() == 9

        %{
          values: customized_check_values,
          customized: true
        } = Enum.find(selectable_checks, &(&1.id == customized_check_id))

        assert [
                 %{
                   name: "numeric_value",
                   customizable: true,
                   current_value: 5,
                   customization: ^expected_customization
                 },
                 %{
                   name: "customizable_string_value",
                   customizable: true,
                   current_value: "foo_bar",
                   customization: "new value"
                 },
                 %{
                   name: "non_customizable_string_value",
                   customizable: false
                 },
                 %{
                   name: "bool_value",
                   customizable: true,
                   current_value: true
                 },
                 %{
                   name: "list_value",
                   customizable: false
                 },
                 %{
                   name: "map_value",
                   customizable: false
                 }
               ] = customized_check_values
      end
    end
  end
end

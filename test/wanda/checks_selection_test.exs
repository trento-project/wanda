defmodule Wanda.ChecksSelectionTest do
  use Wanda.DataCase, async: true

  import Wanda.Factory

  alias Wanda.Catalog.SelectableCheck

  alias Wanda.ChecksSelection

  describe "checks selection" do
    test "should return checks selection when no values were customized" do
      selectable_checks =
        ChecksSelection.selectable_checks(Faker.UUID.v4(), %{
          "id" => "mixed_values_customizability"
        })

      assert length(selectable_checks) == 10

      selectable_checks
      |> Enum.flat_map(& &1.values)
      |> Enum.each(&assert_non_customized_value/1)
    end

    test "should return checks selection with proper custom values" do
      cutomized_check_id = "mixed_values_customizability"

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
          check_id: cutomized_check_id,
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

        expected_cutomizations = [
          %{
            name: "numeric_value",
            customizable: true,
            current_value: 5,
            customization: expected_customization
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
        ]

        selectable_checks =
          ChecksSelection.selectable_checks(group_id, %{
            "id" => "mixed_values_customizability"
          })

        assert length(selectable_checks) == 10

        Enum.each(
          selectable_checks,
          fn
            %SelectableCheck{id: ^cutomized_check_id, values: values} ->
              assert ^expected_cutomizations = values

            %SelectableCheck{values: values} ->
              Enum.each(values, &assert_non_customized_value/1)
          end
        )
      end
    end

    defp assert_non_customized_value(%{name: _, customizable: customizable} = value) do
      refute Map.has_key?(value, :customization)

      if not customizable do
        refute Map.has_key?(value, :current_value)
      end
    end
  end
end

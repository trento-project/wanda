defmodule Wanda.ChecksCustomizationsTest do
  use Wanda.DataCase, async: true

  import Wanda.Factory

  alias Wanda.Repo

  alias Wanda.Catalog.CheckCustomization

  alias Wanda.ChecksCustomizations

  describe "customizing checks" do
    test "should not allow customizing a non existent check" do
      custom_values = build_list(2, :custom_value)

      assert {:error, :check_not_found} =
               ChecksCustomizations.customize(
                 "ABC123",
                 Faker.UUID.v4(),
                 custom_values
               )
    end

    test "should not allow customizing a non customizable check" do
      custom_values = build_list(2, :custom_value)

      assert {:error, :check_not_customizable} =
               ChecksCustomizations.customize(
                 "non_customizable_check",
                 Faker.UUID.v4(),
                 custom_values
               )
    end

    test "should return an error when invalid values are provided" do
      scenarios = [[], nil, "foo", 42, true, %{}]

      for invalid_values <- scenarios do
        assert {:error, :invalid_custom_values} =
                 ChecksCustomizations.customize(
                   "mixed_values_customizability",
                   Faker.UUID.v4(),
                   invalid_values
                 )
      end
    end

    test "should return an error on invalid custom value shape" do
      assert {:error, :invalid_custom_values} =
               ChecksCustomizations.customize(
                 "mixed_values_customizability",
                 Faker.UUID.v4(),
                 [
                   %{
                     name: "numeric_value",
                     value: 50,
                     invalid_key: "foo"
                   }
                 ]
               )
    end

    test "should not allow customizing values because a mismatching name, value non customizability or type mismatch" do
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
        assert {:error, :invalid_custom_values} =
                 ChecksCustomizations.customize(
                   "mixed_values_customizability",
                   Faker.UUID.v4(),
                   values
                 )
      end
    end

    scenarios = [
      %{
        name: "customizing a numeric value",
        values: [
          %{
            name: "numeric_value",
            value: 420
          }
        ]
      },
      %{
        name: "customizing a string value",
        values: [
          %{
            name: "customizable_string_value",
            value: "new value"
          }
        ]
      },
      %{
        name: "customizing a boolean value",
        values: [
          %{
            name: "bool_value",
            value: false
          }
        ]
      },
      %{
        name: "customizing combined values",
        values: [
          %{
            name: "numeric_value",
            value: 999
          },
          %{
            name: "customizable_string_value",
            value: "another new value"
          },
          %{
            name: "bool_value",
            value: false
          }
        ]
      }
    ]

    for %{name: scenario_name} = scenario <- scenarios do
      @scenario scenario

      test "should allow customizing a check's values: #{scenario_name}" do
        check_id = "mixed_values_customizability"
        group_id = Faker.UUID.v4()

        %{values: custom_values} = @scenario

        assert {:ok,
                %CheckCustomization{
                  check_id: ^check_id,
                  group_id: ^group_id,
                  custom_values: ^custom_values
                }} = ChecksCustomizations.customize(check_id, group_id, custom_values)
      end
    end

    updating_scenarios = [
      %{
        name: "retain one/add one",
        initial_custom_values: [
          %{
            name: "numeric_value",
            value: 42
          }
        ],
        new_custom_values: [
          %{
            name: "numeric_value",
            value: 42
          },
          %{
            name: "customizable_string_value",
            value: "another new value"
          }
        ]
      },
      %{
        name: "update one/add one",
        initial_custom_values: [
          %{
            name: "numeric_value",
            value: 42
          }
        ],
        new_custom_values: [
          %{
            name: "numeric_value",
            value: 999
          },
          %{
            name: "customizable_string_value",
            value: "another new value"
          }
        ]
      },
      %{
        name: "remove one/add one",
        initial_custom_values: [
          %{
            name: "numeric_value",
            value: 42
          }
        ],
        new_custom_values: [
          %{
            name: "customizable_string_value",
            value: "another new value"
          }
        ]
      }
    ]

    for %{name: scenario_name} = scenario <- updating_scenarios do
      @scenario scenario

      test "should allow updating a check's values customizations by replacing with new provided custom values: #{scenario_name}" do
        check_id = "mixed_values_customizability"
        group_id = Faker.UUID.v4()

        %{
          initial_custom_values: initial_custom_values,
          new_custom_values: new_custom_values
        } = @scenario

        %{check_id: check_id} =
          insert(:check_customization,
            group_id: group_id,
            check_id: check_id,
            custom_values: initial_custom_values
          )

        assert {:ok,
                %CheckCustomization{
                  check_id: ^check_id,
                  group_id: ^group_id,
                  custom_values: ^new_custom_values
                } = customization} =
                 ChecksCustomizations.customize(check_id, group_id, new_custom_values)

        assert customization ==
                 group_id
                 |> get_customizations()
                 |> List.first()
      end
    end
  end

  describe "retrieving checks customizations" do
    test "should return an empty list when there are no customizations available for a group" do
      assert [] == ChecksCustomizations.get_customizations(Faker.UUID.v4())
    end

    test "should return customizations available for a group" do
      group_id = Faker.UUID.v4()

      [
        %{
          name: name1,
          value: value1
        },
        %{
          name: name2,
          value: value2
        }
      ] = custom_values1 = build_list(2, :custom_value)

      %{
        name: name3,
        value: value3
      } = custom_values2 = build(:custom_value)

      %{check_id: check_id_1} =
        insert(:check_customization,
          group_id: group_id,
          custom_values: custom_values1
        )

      %{check_id: check_id_2} =
        insert(:check_customization,
          group_id: group_id,
          custom_values: [custom_values2]
        )

      assert [
               %CheckCustomization{
                 check_id: ^check_id_1,
                 group_id: ^group_id,
                 custom_values: [
                   %{
                     name: ^name1,
                     value: ^value1
                   },
                   %{
                     name: ^name2,
                     value: ^value2
                   }
                 ]
               },
               %CheckCustomization{
                 check_id: ^check_id_2,
                 group_id: ^group_id,
                 custom_values: [
                   %{
                     name: ^name3,
                     value: ^value3
                   }
                 ]
               }
             ] = ChecksCustomizations.get_customizations(group_id)
    end
  end

  describe "resetting customization" do
    test "should return an error when attempting to reset a not existent customization" do
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
        assert {:error, :customization_not_found} =
                 ChecksCustomizations.reset_customization(
                   possibly_invalid_check_id,
                   possibly_invalid_group_id
                 )
      end

      assert CheckCustomization
             |> Repo.all()
             |> length() == 2
    end

    test "should reset customizations for a check" do
      group_id = Faker.UUID.v4()

      %{check_id: check_id_1} =
        insert(:check_customization,
          group_id: group_id
        )

      %{check_id: check_id_2} =
        insert(:check_customization,
          group_id: group_id
        )

      assert :ok = ChecksCustomizations.reset_customization(check_id_1, group_id)

      assert [
               %CheckCustomization{
                 check_id: ^check_id_2,
                 group_id: ^group_id
               }
             ] = get_customizations(group_id)
    end
  end

  defp get_customizations(group_id) do
    Repo.all(
      from c in CheckCustomization,
        where: c.group_id == ^group_id
    )
  end
end

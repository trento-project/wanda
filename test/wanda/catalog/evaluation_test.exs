defmodule Wanda.Catalog.EvaluationTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog.{Evaluation, ResolvedValue}

  alias Wanda.EvaluationEngine

  describe "value resolution" do
    test "should return empty result" do
      customizations = build_list(5, :customized_value)

      assert [] == Evaluation.resolve_values([], [], %{}, EvaluationEngine.new())
      assert [] == Evaluation.resolve_values([], [], %{})
      assert [] == Evaluation.resolve_values([], customizations, %{}, EvaluationEngine.new())
      assert [] == Evaluation.resolve_values([], customizations, %{})
    end

    test "should resolve non customized values" do
      value_name_1 = Faker.Lorem.word()
      default_value_1 = Faker.Lorem.word()

      value_name_2 = Faker.StarWars.character()
      default_value_2 = Enum.random(1..10)
      contextual_value_1 = Enum.random(11..100)

      value_name_3 = Faker.Pokemon.name()
      default_value_3 = Enum.random(1..10)

      [spec1, spec2, spec3] =
        specified_values = [
          build(:catalog_value,
            name: value_name_1,
            default: default_value_1,
            conditions: []
          ),
          build(:catalog_value,
            name: value_name_2,
            default: default_value_2,
            conditions: [
              build(:catalog_condition,
                value: contextual_value_1,
                expression: "env.some_entry > 10"
              )
            ]
          ),
          build(:catalog_value,
            name: value_name_3,
            default: default_value_3,
            conditions: [
              build(:catalog_condition,
                expression: "env.some_entry == 10"
              )
            ]
          )
        ]

      expected_resolution = [
        %ResolvedValue{
          name: value_name_1,
          spec: spec1,
          original_value: default_value_1,
          custom_value: nil,
          customized: false
        },
        %ResolvedValue{
          name: value_name_2,
          spec: spec2,
          original_value: contextual_value_1,
          custom_value: nil,
          customized: false
        },
        %ResolvedValue{
          name: value_name_3,
          spec: spec3,
          original_value: default_value_3,
          custom_value: nil,
          customized: false
        }
      ]

      scope = %{"some_entry" => 11}

      assert expected_resolution ==
               Evaluation.resolve_values(specified_values, [], scope, EvaluationEngine.new())

      assert expected_resolution == Evaluation.resolve_values(specified_values, [], scope)
    end

    test "should resolve customized values" do
      value_name_1 = Faker.Lorem.word()
      default_value_1 = Faker.Lorem.word()

      value_name_2 = Faker.StarWars.character()
      default_value_2 = Enum.random(1..10)
      contextual_value_2 = Enum.random(11..100)
      custom_value_2 = Enum.random(101..200)

      value_name_3 = Faker.Pokemon.name()
      default_value_3 = Enum.random(1..10)
      custom_value_3 = Enum.random(11..20)

      [spec1, spec2, spec3] =
        specified_values = [
          build(:catalog_value,
            name: value_name_1,
            default: default_value_1,
            conditions: []
          ),
          build(:catalog_value,
            name: value_name_2,
            default: default_value_2,
            conditions: [
              build(:catalog_condition,
                value: contextual_value_2,
                expression: "env.some_entry > 10"
              )
            ]
          ),
          build(:catalog_value,
            name: value_name_3,
            default: default_value_3,
            conditions: [
              build(:catalog_condition,
                expression: "env.some_entry == 10"
              )
            ]
          )
        ]

      customizations = [
        build(:customized_value, name: value_name_2, value: custom_value_2),
        build(:customized_value, name: value_name_3, value: custom_value_3)
      ]

      expected_resolution = [
        %ResolvedValue{
          name: value_name_1,
          spec: spec1,
          original_value: default_value_1,
          custom_value: nil,
          customized: false
        },
        %ResolvedValue{
          name: value_name_2,
          spec: spec2,
          original_value: contextual_value_2,
          custom_value: custom_value_2,
          customized: true
        },
        %ResolvedValue{
          name: value_name_3,
          spec: spec3,
          original_value: default_value_3,
          custom_value: custom_value_3,
          customized: true
        }
      ]

      scope = %{"some_entry" => 11}

      assert expected_resolution ==
               Evaluation.resolve_values(
                 specified_values,
                 customizations,
                 scope,
                 EvaluationEngine.new()
               )

      assert expected_resolution ==
               Evaluation.resolve_values(specified_values, customizations, scope)
    end
  end
end

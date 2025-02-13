defmodule Wanda.Catalog.CustomizationPolicyTest do
  use ExUnit.Case

  alias Wanda.Catalog.{CheckCustomization, CustomizationPolicy}
  alias Wanda.Users.User

  @scenarios [
    %{
      abilities: [],
      expected: false
    },
    %{
      abilities: [%{name: "foo", resource: "bar"}],
      expected: false
    },
    %{
      abilities: [%{name: "all", resource: "all"}],
      expected: true
    },
    %{
      abilities: [%{name: "all", resource: "check_customization"}],
      expected: true
    },
    %{
      abilities: [%{name: "all", resource: "all"}, %{name: "foo", resource: "bar"}],
      expected: true
    },
    %{
      abilities: [
        %{name: "all", resource: "check_customization"},
        %{name: "foo", resource: "bar"}
      ],
      expected: true
    }
  ]

  test "should allow checks customization only when required abilities are present" do
    for %{abilities: abilities, expected: is_allowed} <- @scenarios do
      assert is_allowed ==
               CustomizationPolicy.authorize(
                 :apply_custom_values,
                 %User{abilities: abilities},
                 CheckCustomization
               )
    end
  end

  test "should allow resetting checks customization only when required abilities are present" do
    for %{abilities: abilities, expected: is_allowed} <- @scenarios do
      assert is_allowed ==
               CustomizationPolicy.authorize(
                 :reset_customization,
                 %User{abilities: abilities},
                 CheckCustomization
               )
    end
  end

  test "should deny operations on invalid input" do
    abilities = [
      %{name: "all", resource: "check_customization"},
      %{name: "foo", resource: "bar"}
    ]

    user = %User{abilities: abilities}

    refute CustomizationPolicy.authorize(:foo, user, CheckCustomization)
    refute CustomizationPolicy.authorize(:apply_custom_values, 42, CheckCustomization)
    refute CustomizationPolicy.authorize(:reset_customization, user, Foo)
  end
end

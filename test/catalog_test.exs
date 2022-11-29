defmodule Wanda.CatalogTest do
  use ExUnit.Case

  alias Wanda.Catalog

  alias Wanda.Catalog.{
    Check,
    Condition,
    Expectation,
    Fact,
    Value
  }

  describe "checks catalog" do
    test "should return the whole catalog" do
      catalog_path = Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_path]

      valid_files =
        catalog_path
        |> File.ls!()
        |> Enum.sort()
        |> Enum.filter(fn file -> file != "malformed_check.yaml" end)

      catalog = Catalog.get_catalog()
      assert length(valid_files) == length(catalog)

      Enum.with_index(catalog, fn check, index ->
        file_name =
          valid_files
          |> Enum.at(index)
          |> Path.basename(".yaml")

        assert %Check{id: ^file_name} = check
      end)
    end

    test "should load a check from a yaml file properly" do
      assert {:ok,
              %Check{
                id: "expect_check",
                name: "Test check",
                group: "Test",
                description: "Just a check\n",
                remediation: "## Remediation\nRemediation text\n",
                severity: :critical,
                facts: [
                  %Fact{
                    name: "jedi",
                    gatherer: "wandalorian",
                    argument: "-o"
                  },
                  %Fact{
                    name: "other_fact",
                    gatherer: "no_args_gatherer",
                    argument: ""
                  }
                ],
                values: [
                  %Value{
                    conditions: [
                      %Condition{expression: "some_expression", value: 10},
                      %Condition{expression: "some_other_expression", value: 15}
                    ],
                    default: 5,
                    name: "expected_value"
                  },
                  %Value{
                    conditions: [
                      %Condition{expression: "some_third_expression", value: 5}
                    ],
                    default: 10,
                    name: "expected_higher_value"
                  }
                ],
                expectations: [
                  %Expectation{
                    name: "some_expectation",
                    type: :expect,
                    expression: "facts.jedi == values.expected_value"
                  },
                  %Expectation{
                    name: "some_other_expectation",
                    type: :expect,
                    expression: "facts.jedi > values.expected_higher_value"
                  }
                ]
              }} = Catalog.get_check("expect_check")
    end

    test "should load a expect_same expectation type" do
      assert {:ok,
              %Check{
                values: [],
                expectations: [
                  %Expectation{
                    name: "some_expectation",
                    type: :expect_same,
                    expression: "facts.jedi"
                  }
                ]
              }} = Catalog.get_check("expect_same_check")
    end

    test "should load a warning severity" do
      assert {:ok, %Check{severity: :warning}} = Catalog.get_check("warning_severity_check")
    end

    test "should return an error for non-existent check" do
      assert {:error, _} = Catalog.get_check("non_existent_check")
    end

    test "should return an error for malformed check" do
      assert {:error, :malformed_check} = Catalog.get_check("malformed_check")
    end

    test "should load multiple checks" do
      assert [%Check{id: "expect_check"}, %Check{id: "expect_same_check"}] =
               Catalog.get_checks(["expect_check", "non_existent_check", "expect_same_check"])
    end
  end
end

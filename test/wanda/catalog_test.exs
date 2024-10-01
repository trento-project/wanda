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

  def catalog_path do
    catalog_paths = Application.fetch_env!(:wanda, Wanda.Catalog)[:catalog_paths]
    Enum.at(catalog_paths, 1)
  end

  describe "checks catalog" do
    test "should return the whole catalog" do
      valid_files =
        catalog_path()
        |> File.ls!()
        |> Enum.sort()
        |> Enum.filter(fn file ->
          file != "malformed_check.yaml" and file != "malformed_file.yaml"
        end)

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

    test "should read the whole catalog and throw no errors with malformed files" do
      files =
        catalog_path()
        |> File.ls!()
        |> Enum.sort()

      catalog = Catalog.get_catalog()

      assert length(files) == length(catalog) + 2
    end

    test "should filter out checks if the when clause doesn't match" do
      complete_catalog = Catalog.get_catalog(%{"provider" => "azure"})
      catalog = Catalog.get_catalog(%{"provider" => "aws"})

      assert length(complete_catalog) - 1 == length(catalog)

      refute Enum.any?(catalog, fn %Check{id: id} -> id == "when_condition_check" end)
    end

    test "should filter out checks if the metadata doesn't match" do
      complete_catalog = Catalog.get_catalog(%{"some" => "kind"})
      catalog = Catalog.get_catalog(%{"some" => "wanda"})

      assert length(complete_catalog) - 1 == length(catalog)

      refute Enum.any?(catalog, fn %Check{id: id} -> id == "with_metadata" end)
    end

    test "should match metadata when value is in a list" do
      complete_catalog = Catalog.get_catalog(%{"some" => "kind"})
      catalog = Catalog.get_catalog(%{"list" => "this"})

      assert length(complete_catalog) == length(catalog)

      assert Enum.any?(catalog, fn %Check{id: id} -> id == "with_metadata" end)
    end

    test "should not filter out checks if the provided env includes just different keys" do
      complete_catalog = Catalog.get_catalog(%{"some" => "kind"})
      catalog = Catalog.get_catalog(%{"wow" => "carbonara"})

      assert length(complete_catalog) == length(catalog)

      assert Enum.any?(catalog, fn %Check{id: id} -> id == "with_metadata" end)
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
                    expression: "facts.jedi == values.expected_value",
                    failure_message: "some failure message ${facts.jedi}"
                  },
                  %Expectation{
                    name: "some_other_expectation",
                    type: :expect,
                    expression: "facts.jedi > values.expected_higher_value",
                    failure_message: nil
                  }
                ]
              }} = Catalog.get_check(catalog_path(), "expect_check")
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
              }} = Catalog.get_check(catalog_path(), "expect_same_check")
    end

    test "should load a expect_enum expectation type" do
      assert {:ok,
              %Check{
                values: [
                  %Value{
                    default: 5,
                    name: "expected_passing_value"
                  },
                  %Value{
                    default: 3,
                    name: "expected_warning_value"
                  }
                ],
                expectations: [
                  %Expectation{
                    name: "some_expectation",
                    type: :expect_enum,
                    expression: """
                    if facts.jedi == values.expected_passing_value {
                      "passing"
                    } else if facts.jedi == values.expected_warning_value {
                      "warning"
                    } else {
                      "critical"
                    }
                    """,
                    failure_message: "some failure message ${facts.jedi}",
                    warning_message: "some warning message ${facts.jedi}"
                  }
                ]
              }} = Catalog.get_check(catalog_path(), "expect_enum_check")
    end

    test "should load a warning severity" do
      assert {:ok, %Check{severity: :warning}} =
               Catalog.get_check(catalog_path(), "warning_severity_check")
    end

    test "should return an error for non-existent check" do
      assert {:error, _} = Catalog.get_check(catalog_path(), "non_existent_check")
    end

    test "should return an error for malformed check" do
      assert {:error, :malformed_check} = Catalog.get_check(catalog_path(), "malformed_check")
    end

    test "should load multiple checks" do
      assert [%Check{id: "expect_check"}, %Check{id: "expect_same_check"}] =
               Catalog.get_checks(
                 ["expect_check", "non_existent_check", "expect_same_check"],
                 %{}
               )
    end
  end
end

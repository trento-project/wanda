defmodule Wanda.Catalog.SelectedCheckTest do
  use ExUnit.Case

  import Wanda.Factory

  alias Wanda.Catalog.SelectedCheck

  describe "selected check" do
    test "should extract an empty list of specs from an empty list of selected checks" do
      assert [] == SelectedCheck.extract_specs([])
    end

    test "should extract specs from a list of selected checks" do
      [
        %SelectedCheck{
          spec: spec_1
        },
        %SelectedCheck{
          spec: spec_2
        }
      ] = selected_checks = build_list(2, :selected_check)

      assert [spec_1, spec_2] == SelectedCheck.extract_specs(selected_checks)
    end
  end
end

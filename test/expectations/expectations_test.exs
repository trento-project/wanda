defmodule Wanda.ExpectationsTest do
  use ExUnit.Case

  alias Wanda.Facts.Fact

  test "should eval the expression and return a result" do
    facts = [
      %Fact{name: "foo", value: 20000},
      %Fact{name: "bar", value: "baz"}
    ]

    result = Wanda.Expectations.execute("foo == 20000 && bar == \"baz\"", facts)

    assert {:ok, true} == result
  end
end

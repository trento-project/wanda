# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

defmodule Wanda.Executions.FakeGatheredFactsTest do
  @moduledoc false

  use ExUnit.Case

  alias Wanda.Executions.FakeGatheredFacts

  @agent_1 "0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4"
  @agent_2 "13e8c25c-3180-5a9a-95c8-51ec38e50cfc"
  @agent_3 "99cf8a3a-48d6-57a4-b302-6e4482227ab6"

  describe "fake_value/3" do
    test "returns the configured value for a known (check, agent, fact)" do
      assert FakeGatheredFacts.fake_value("CHECK1", @agent_1, "fact_name1") == 2
      assert FakeGatheredFacts.fake_value("CHECK1", @agent_2, "fact_name1") == 3
      assert FakeGatheredFacts.fake_value("CHECK1", @agent_3, "fact_name1") == nil

      assert FakeGatheredFacts.fake_value("CHECK3", @agent_1, "fact_name3") ==
               "/dev/sdb;/dev/sdc;dev/sdg"
    end

    test "returns nested structured values as configured" do
      assert FakeGatheredFacts.fake_value("CHECK2", @agent_1, "fact_name2") == %{
               "property1" => %{"some_sub_prop" => 15}
             }
    end

    @tag capture_log: true
    test "falls back to the default value when the fact is not configured" do
      # agent has no CHECK3 entry in the fixture
      assert FakeGatheredFacts.fake_value("CHECK3", @agent_2, "fact_name3") == "some fact value"
      # unknown agent / check / fact all fall back
      assert FakeGatheredFacts.fake_value("CHECK1", Faker.UUID.v4(), "fact_name1") ==
               "some fact value"

      assert FakeGatheredFacts.fake_value("UNKNOWN", @agent_1, "whatever") == "some fact value"
    end

    @tag capture_log: true
    test "falls back to the default value when the yaml config can't be read" do
      previous_facts = Application.get_env(:wanda, FakeGatheredFacts)

      Application.put_env(:wanda, FakeGatheredFacts,
        demo_facts_config: "path/to/not-existent/fake_facts.yaml"
      )

      on_exit(fn ->
        if previous_facts do
          Application.put_env(:wanda, FakeGatheredFacts, previous_facts)
        else
          Application.delete_env(:wanda, FakeGatheredFacts)
        end
      end)

      assert FakeGatheredFacts.fake_value("CHECK1", @agent_1, "fact_name1") == "some fact value"
    end
  end
end

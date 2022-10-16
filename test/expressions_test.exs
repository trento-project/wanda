defmodule ExpressionsTest do
  use ExUnit.Case

  describe "lua integration" do
    test "should support accessing facts and values" do
      state = :luerl.init()

      state =
        :luerl.set_table(
          [:facts],
          %{
            "corosync_token_timeout" => 30_000
          },
          state
        )

      state =
        :luerl.set_table(
          [:values],
          %{
            expected_token_timeout: 30_000
          },
          state
        )

      assert {:ok, [true]} =
               :luerl.eval(
                 "return facts.corosync_token_timeout == values.expected_token_timeout",
                 state
               )
    end

    test "should support a length function" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state = load_length_fn(:luerl.init(), functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: [
                2,
                4
              ]
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "return length(facts.corosync_nodes) == values.expected_corosync_nodes",
                   state
                 )
      end)
    end

    test "should support an all(list, predicate) function that returns true if predicate(item_in_list) is truthy for all elements in the list" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state = load_all_fn(:luerl.init(), functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: [
                2,
                2
              ]
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return all(facts.corosync_nodes, function(node_rings)
                     return values.expected_corosync_rings_per_node == node_rings
                   end)
                   ",
                   state
                 )
      end)
    end
  end

  describe "check 1.1.9 DA114A Corosync has at least 2 rings configured" do
    test "should support a list of numbers, where each number in the list is the number of rings on respective node" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state =
          :luerl.init()
          |> load_length_fn(functions_source)
          |> load_all_fn(functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: [
                2,
                2
              ]
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return
                     length(facts.corosync_nodes) == values.expected_corosync_nodes
                     and all(facts.corosync_nodes, function(node_rings)
                       return values.expected_corosync_rings_per_node == node_rings
                     end)
                   ",
                   state
                 )
      end)
    end

    test "should support a list of objects representing nodes, where each node has a rings property holding the value of the rings on that specific node" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state =
          :luerl.init()
          |> load_length_fn(functions_source)
          |> load_all_fn(functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: [
                %{
                  rings: 2
                },
                %{
                  rings: 2
                }
              ]
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return
                     length(facts.corosync_nodes) == values.expected_corosync_nodes
                     and all(facts.corosync_nodes, function(node)
                       return values.expected_corosync_rings_per_node == node.rings
                     end)
                   ",
                   state
                 )
      end)
    end

    test "should support a list of objects representing nodes, where each node has a rings property holding a list of rings" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state =
          :luerl.init()
          |> load_length_fn(functions_source)
          |> load_all_fn(functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: [
                %{
                  rings: ["a", "b"]
                },
                %{
                  rings: ["a", "b"]
                }
              ]
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return
                     length(facts.corosync_nodes) == values.expected_corosync_nodes
                     and all(facts.corosync_nodes, function(node)
                       return values.expected_corosync_rings_per_node == length(node.rings)
                     end)
                   ",
                   state
                 )
      end)
    end

    test "should support also more complex maps" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state =
          :luerl.init()
          |> load_length_fn(functions_source)
          |> load_all_fn(functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              corosync_nodes: %{
                node_1: %{
                  rings: ["a", "b"]
                },
                node_2: %{
                  rings: ["a", "b"]
                }
              }
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_corosync_nodes: 2,
              expected_corosync_rings_per_node: 2
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return
                     length(facts.corosync_nodes) == values.expected_corosync_nodes
                     and all(facts.corosync_nodes, function(node)
                       return values.expected_corosync_rings_per_node == length(node.rings)
                     end)
                   ",
                   state
                 )
      end)
    end
  end

  describe "check 1.2.2 373DB8 Cluster fencing timeout is configured correctly" do
    test "should support a simil ternary operator" do
      Enum.each([:elixir, :lua], fn functions_source ->
        state = load_ternary_fn(:luerl.init(), functions_source)

        state =
          :luerl.set_table(
            [:facts],
            %{
              fence_azure_arm_detected: true,
              fencing_timeout: 600
            },
            state
          )

        state =
          :luerl.set_table(
            [:values],
            %{
              expected_fencing_timeout: 600
            },
            state
          )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                   return when{
                     condition = facts.fence_azure_arm_detected,
                     matches = facts.fencing_timeout == values.expected_fencing_timeout,
                     otherwise = facts.fencing_timeout >= values.expected_fencing_timeout
                   }
                   ",
                   state
                 )

        assert {:ok, [true]} =
                 :luerl.eval(
                   "
                    if facts.fence_azure_arm_detected then
                      return facts.fencing_timeout == values.expected_fencing_timeout
                    else
                      return facts.fencing_timeout >= values.expected_fencing_timeout
                    end
                    ",
                   state
                 )
      end)
    end
  end

  defp load_length_fn(state, :elixir) do
    load_elixir_length(state)
  end

  defp load_length_fn(state, :lua) do
    load_length_chunk(state)
  end

  defp load_all_fn(state, :elixir) do
    load_elixir_all(state)
  end

  defp load_all_fn(state, :lua) do
    load_all_chunk(state)
  end

  defp load_ternary_fn(state, :elixir) do
    load_elixir_ternary(state)
  end

  defp load_ternary_fn(state, :lua) do
    load_ternary_chunk(state)
  end

  defp load_length_chunk(state) do
    {:ok, chunk, state} =
      :luerl.load(
        "
        function length(T)
          local count = 0
          for _ in pairs(T) do count = count + 1 end
          return count
        end",
        state
      )

    {_, state} = :luerl.call_chunk(chunk, [], state)
    state
  end

  defp load_all_chunk(state) do
    {:ok, chunk, state} =
      :luerl.load(
        "
        function all(T, F)
          for _, value in ipairs(T) do
            if true ~= F(value) then return false end
          end
          return true
        end",
        state
      )

    {_, state} = :luerl.call_chunk(chunk, [], state)
    state
  end

  defp load_ternary_chunk(state) do
    {:ok, chunk, state} =
      :luerl.load(
        "
        function when(context)
          if context.condition then return context.matches else return context.otherwise end
        end",
        state
      )

    {_, state} = :luerl.call_chunk(chunk, [], state)
    state
  end

  defp load_elixir_length(state) do
    :luerl.set_table(
      [:length],
      fn [val], st -> {[length(val)], st} end,
      state
    )
  end

  defp load_elixir_all(state) do
    :luerl.set_table(
      [:all],
      fn [val, predicate], st ->
        {[
           Enum.all?(val, fn {_, v} ->
             [return_value] = predicate.([v])
             return_value
           end)
         ], st}
      end,
      state
    )
  end

  defp load_elixir_ternary(state) do
    :luerl.set_table(
      [:when],
      fn [[{"condition", condition}, {"matches", matches}, {"otherwise", otherwise}]], st ->
        return_value = if condition, do: matches, else: otherwise
        {[return_value], st}
      end,
      state
    )
  end
end

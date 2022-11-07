defmodule ExpressionsTest do
  use ExUnit.Case

  # Covers
  # 1.1.1, 1.1.2, 1.1.3, 1.1.4, 1.1.5, 1.1.6, 1.1.7, 1.1.8
  # 1.1.9, 1.2.1, 1.2.2, 1.3.1, 1.3.2, 1.3.3, 1.3.4, 1.3.5

  describe "rhai integration" do
    test "should support accessing environment" do
      Enum.map(["azure", "aws"], fn provider ->
        context = %{
          "env" => %{
            "provider" => provider
          }
        }

        assert {:ok, true} =
                 Rhai.eval(~s(env.provider == "azure" || env.provider == "aws"), context)

        assert {:ok, false} = Rhai.eval("env.provider == \"gcp\"", context)
      end)
    end

    test "should support accessing facts and values" do
      context = %{
        "facts" => %{
          "corosync_token_timeout" => 30_000
        },
        "values" => %{
          "expected_token_timeout" => 30_000
        }
      }

      assert {:ok, true} =
               Rhai.eval("facts.corosync_token_timeout == values.expected_token_timeout", context)
    end

    test "should support hardcoded value" do
      context = %{
        "facts" => %{
          "corosync_max_messages" => 20,
          "corosync_transport" => "udpu"
        }
      }

      assert {:ok, true} = Rhai.eval("facts.corosync_max_messages == 20", context)

      assert {:ok, true} = Rhai.eval("facts.corosync_transport == \"udpu\"", context)
    end

    test "should support a length function" do
      context = %{
        "facts" => %{
          "corosync_nodes" => [
            2,
            4
          ]
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval("facts.corosync_nodes.len() == values.expected_corosync_nodes", context)
    end

    test "should support a list.all(predicate) function that returns true if predicate(item_in_list) is truthy for all elements in the list" do
      context = %{
        "facts" => %{
          "corosync_nodes" => [
            2,
            2
          ]
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "facts.corosync_nodes.all(|node_rings| node_rings == values.expected_corosync_rings_per_node)",
                 context
               )
    end
  end

  describe "check 1.1.9 DA114A Corosync has at least 2 rings configured" do
    test "should support a list of numbers, where each number in the list is the number of rings on respective node" do
      context = %{
        "facts" => %{
          "corosync_nodes" => [
            2,
            2
          ]
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "
                 facts.corosync_nodes.len() == values.expected_corosync_nodes &&
                 facts.corosync_nodes.all(|node_rings| node_rings == values.expected_corosync_rings_per_node)
                 ",
                 context
               )
    end

    test "should support a list of objects representing nodes with a rings property holding the value of the rings on that specific node" do
      context = %{
        "facts" => %{
          "corosync_nodes" => [
            %{
              "rings" => 2
            },
            %{
              "rings" => 2
            }
          ]
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "facts.corosync_nodes.all(|node| node.rings == values.expected_corosync_rings_per_node)",
                 context
               )
    end

    test "should support a list of objects representing nodes, where each node has a rings property holding a list of rings" do
      context = %{
        "facts" => %{
          "corosync_nodes" => [
            %{
              "rings" => ["some-ring-info", "another-ring-info"]
            },
            %{
              "rings" => ["different-ring-info", "yet-a-ring-info"]
            }
          ]
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "facts.corosync_nodes.all(|node| node.rings.len() == values.expected_corosync_rings_per_node)",
                 context
               )
    end

    test "should support also more complex maps" do
      context = %{
        "facts" => %{
          "corosync_nodes" => %{
            "node_1" => %{
              "rings" => ["some-ring-info", "another-ring-info"]
            },
            "node_2" => %{
              "rings" => ["different-ring-info", "yet-a-ring-info"]
            }
          }
        },
        "values" => %{
          "expected_corosync_nodes" => 2,
          "expected_corosync_rings_per_node" => 2
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "facts.corosync_nodes.values().all(|node| node.rings.len() == values.expected_corosync_rings_per_node)",
                 context
               )
    end
  end

  describe "check 1.2.2 373DB8 Cluster fencing timeout is configured correctly" do
    test "should support conditional expectations" do
      context = %{
        "facts" => %{
          "fence_azure_arm_detected" => false,
          "fencing_timeout" => 600
        },
        "values" => %{
          "expected_fencing_timeout" => 600
        }
      }

      assert {:ok, true} =
               Rhai.eval(
                 "
                 if facts.fence_azure_arm_detected {
                  facts.fencing_timeout == values.expected_fencing_timeout
                } else {
                  facts.fencing_timeout >= values.expected_fencing_timeout
                }
                ",
                 context
               )
    end
  end
end

import Config

config :wanda, Wanda.Policy, execution_server_impl: Wanda.Executions.FakeServer

config :wanda, WandaWeb.Endpoint,
  check_origin: :conn,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :logger, level: :debug

target1 = "0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4"
target2 = "13e8c25c-3180-5a9a-95c8-51ec38e50cfc"
target3 = "99cf8a3a-48d6-57a4-b302-6e4482227ab6"
target4 = "9cd46919-5f19-59aa-993e-cf3736c71053"
target5 = "b767b3e9-e802-587e-a442-541d093b86b9"
target6 = "e0c182db-32ff-55c6-a9eb-2b82dd21bc8b"

config :wanda,
  fake_gathered_facts: %{
    "C620DC" => %{
      "corosync_expected_votes" => %{
        target1 => 2,
        target2 => 2,
        target3 => 2,
        target4 => 2,
        target5 => 2,
        target6 => 2
      }
    },
    "845CC9" => %{
      "corosync_max_messages" => %{
        target1 => 20,
        target2 => 20,
        target3 => 20,
        target4 => 20,
        target5 => 20,
        target6 => 20
      }
    },
    "D028B9" => %{
      "compare_sles_sap_version" => %{
        target1 => 0,
        target2 => -1,
        target3 => 0,
        target4 => 0,
        target5 => -1,
        target6 => 0
      }
    },
    "A1244C" => %{
      "corosync_consensus_timeout" => %{
        target1 => 36_000,
        target2 => 36_000,
        target3 => 36_000,
        target4 => 36_000,
        target5 => 36_000,
        target6 => 36_000
      }
    },
    "DA114A" => %{
      "corosync_nodes" => %{
        target1 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ],
        target2 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ],
        target3 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ],
        target4 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ],
        target5 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ],
        target6 => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      }
    },
    "222A57" => %{
      "compare_sbd_version" => %{
        target1 => 0,
        target2 => -1,
        target3 => 0,
        target4 => -1,
        target5 => 0,
        target6 => 0
      }
    },
    "B089BE" => %{
      "dump_sbd_devices" => %{
        target1 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 15
          }
        },
        target2 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        },
        target3 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        },
        target4 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        },
        target5 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        },
        target6 => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      }
    },
    "9FAAD0" => %{
      "exclude_package_pacemaker" => %{
        target1 => 1,
        target2 => -1,
        target3 => 1,
        target4 => 1,
        target5 => -1,
        target6 => 1
      }
    },
    "790926" => %{
      "hacluster_has_default_password" => %{
        target1 => false,
        target2 => false,
        target3 => false,
        target4 => false,
        target5 => false,
        target6 => false
      }
    },
    "0B6DB2" => %{
      "sbd_pacemaker" => %{
        target1 => "yes",
        target2 => "yes",
        target3 => "yes",
        target4 => "yes",
        target5 => "yes",
        target6 => "yes"
      }
    },
    "F50AF5" => %{
      "compare_python3_version" => %{
        target1 => 0,
        target2 => -1,
        target3 => 0,
        target4 => 0,
        target5 => -1,
        target6 => 0
      }
    },
    "53D035" => %{
      "token_timeout" => %{
        target1 => 30_000,
        target2 => 30_000,
        target3 => 30_000,
        target4 => 30_000,
        target5 => 30_000,
        target6 => 30_000
      }
    },
    "21FCA6" => %{
      "corosync_token_retransmits_before_loss_const" => %{
        target1 => 10,
        target2 => 10,
        target3 => 10,
        target4 => 10,
        target5 => 10,
        target6 => 10
      }
    },
    "00081D" => %{
      "max_messages" => %{
        target1 => 20,
        target2 => 20,
        target3 => 20,
        target4 => 20,
        target5 => 20,
        target6 => 20
      }
    },
    "32CFC6" => %{
      "totem_interfaces" => %{
        target1 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ],
        target2 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ],
        target3 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ],
        target4 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ],
        target5 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ],
        target6 => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      }
    },
    "15F7A8" => %{
      "token_retransmits" => %{
        target1 => 10,
        target2 => 10,
        target3 => 10,
        target4 => 10,
        target5 => 10,
        target6 => 10
      }
    },
    "FB0E0D" => %{
      "consensus_timeout" => %{
        target1 => 36_000,
        target2 => 36_000,
        target3 => 36_000,
        target4 => 36_000,
        target5 => 36_000,
        target6 => 36_000
      }
    },
    "D78671" => %{
      "runtime_two_node" => %{
        target1 => 1,
        target2 => 1,
        target3 => 1,
        target4 => 1,
        target5 => 1,
        target6 => 1
      }
    },
    "373DB8" => %{
      "crm_config_properties" => %{
        target1 => %{"acme" => 42},
        target2 => %{"acme" => 42},
        target3 => %{"acme" => 42},
        target4 => %{"acme" => 42},
        target5 => %{"acme" => 42},
        target6 => %{"acme" => 42}
      },
      "resources_primitives" => %{
        target1 => %{"foo" => [%{"bar" => "baz"}]},
        target2 => %{"foo" => [%{"bar" => "baz"}]},
        target3 => %{"foo" => [%{"bar" => "baz"}]},
        target4 => %{"foo" => [%{"bar" => "baz"}]},
        target5 => %{"foo" => [%{"bar" => "baz"}]},
        target6 => %{"foo" => [%{"bar" => "baz"}]}
      }
    },
    "816815" => %{
      target1 => %{"sbd_service_state" => "active"},
      target2 => %{"sbd_service_state" => "active"},
      target3 => %{"sbd_service_state" => "active"},
      target4 => %{"sbd_service_state" => "active"},
      target5 => %{"sbd_service_state" => "active"},
      target6 => %{"sbd_service_state" => "active"}
    },
    "156F64" => %{
      "corosync_token_timeout" => %{
        target1 => 30_000,
        target2 => 30_000,
        target3 => 30_000,
        target4 => 30_000,
        target5 => 30_000,
        target6 => 30_000
      }
    },
    "49591F" => %{
      "sbd_startmode" => %{
        target1 => "always",
        target2 => "always",
        target3 => "always",
        target4 => "always",
        target5 => "always",
        target6 => "always"
      }
    },
    "822E47" => %{
      "runtime_join" => %{
        target1 => 60,
        target2 => 60,
        target3 => 60,
        target4 => 60,
        target5 => 60,
        target6 => 60
      }
    },
    "C3166E" => %{
      "exclude_package_sbd" => %{
        target1 => -1,
        target2 => 1,
        target3 => -1,
        target4 => -1,
        target5 => 1,
        target6 => 1
      }
    },
    "205AF7" => %{
      "crm_config_properties" => %{
        target1 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ],
        target2 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ],
        target3 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ],
        target4 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ],
        target5 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ],
        target6 => [
          %{
            "id" => "cib-bootstrap-options",
            "nvpair" => [
              %{
                "name" => "stonith-enabled",
                "value" => true
              }
            ]
          }
        ]
      }
    },
    "24ABCB" => %{
      "corosync_join_timeout" => %{
        target1 => 60,
        target2 => 60,
        target3 => 60,
        target4 => 60,
        target5 => 60,
        target6 => 60
      }
    },
    "33403D" => %{
      "corosync_transport_protocol" => %{
        target1 => "udpu",
        target2 => "udpu",
        target3 => "udpu",
        target4 => "udpu",
        target5 => "udpu",
        target6 => "udpu"
      }
    },
    "6E9B82" => %{
      "corosync_twonode" => %{
        target1 => 1,
        target2 => 1,
        target3 => 1,
        target4 => 1,
        target5 => 1,
        target6 => 1
      }
    },
    "61451E" => %{
      "sbd_multiple_sbd_device" => %{
        target1 => "/dev/sdb;/dev/sdc;dev/sdg",
        target2 => "/dev/sdb;/dev/sdc",
        target3 => "/dev/sdb;/dev/sdc;dev/sdg",
        target4 => "/dev/sdb;/dev/sdc;dev/sdg",
        target5 => "/dev/sdb;/dev/sdc",
        target6 => "/dev/sdb;/dev/sdc;dev/sdg"
      }
    },
    "68626E" => %{
      "dump_sbd_devices" => %{
        target1 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        },
        target2 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        },
        target3 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        },
        target4 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        },
        target5 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        },
        target6 => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      }
    },
    "9FEFB0" => %{
      "compare_pacemaker_version" => %{
        target1 => 0,
        target2 => -1,
        target3 => 0,
        target4 => 0,
        target5 => -1,
        target6 => 0
      }
    },
    "7E0221" => %{
      "runtime_transport" => %{
        target1 => "udpu",
        target2 => "udpu",
        target3 => "udpu",
        target4 => "udpu",
        target5 => "udpu",
        target6 => "udpu"
      }
    },
    "CAEFF1" => %{
      "os_flavor" => %{
        target1 => "SLES_SAP",
        target2 => "SLES_SAP",
        target3 => "SLES_SAP",
        target4 => "SLES_SAP",
        target5 => "SLES_SAP",
        target6 => "SLES_SAP"
      }
    },
    "DC5429" => %{
      "compare_corosync_version" => %{
        target1 => 0,
        target2 => -1,
        target3 => -1,
        target4 => 0,
        target5 => -1,
        target6 => 0
      }
    }
  }

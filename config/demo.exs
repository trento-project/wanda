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
      target1 => %{"corosync_expected_votes" => 2},
      target2 => %{"corosync_expected_votes" => 2},
      target3 => %{"corosync_expected_votes" => 2},
      target4 => %{"corosync_expected_votes" => 2},
      target5 => %{"corosync_expected_votes" => 2},
      target6 => %{"corosync_expected_votes" => 2}
    },
    "845CC9" => %{
      target1 => %{"corosync_max_messages" => 20},
      target2 => %{"corosync_max_messages" => 20},
      target3 => %{"corosync_max_messages" => 20},
      target4 => %{"corosync_max_messages" => 20},
      target5 => %{"corosync_max_messages" => 20},
      target6 => %{"corosync_max_messages" => 20}
    },
    "D028B9" => %{
      target1 => %{
        "compare_sles_sap_version" => 0
      },
      target2 => %{
        "compare_sles_sap_version" => -1
      },
      target3 => %{
        "compare_sles_sap_version" => 0
      },
      target4 => %{
        "compare_sles_sap_version" => 0
      },
      target5 => %{
        "compare_sles_sap_version" => -1
      },
      target6 => %{
        "compare_sles_sap_version" => 0
      }
    },
    "A1244C" => %{
      target1 => %{
        "corosync_consensus_timeout" => 36_000
      },
      target2 => %{
        "corosync_consensus_timeout" => 36_000
      },
      target3 => %{
        "corosync_consensus_timeout" => 36_000
      },
      target4 => %{
        "corosync_consensus_timeout" => 36_000
      },
      target5 => %{
        "corosync_consensus_timeout" => 36_000
      },
      target6 => %{
        "corosync_consensus_timeout" => 36_000
      }
    },
    "DA114A" => %{
      target1 => %{
        "corosync_nodes" => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      },
      target2 => %{
        "corosync_nodes" => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      },
      target3 => %{
        "corosync_nodes" => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      },
      target4 => %{
        "corosync_nodes" => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      },
      target5 => %{
        "corosync_nodes" => [
          %{
            "nodeid" => 1,
            "ring0_addr" => "192.168.157.10"
          },
          %{
            "nodeid" => 2,
            "ring0_addr" => "192.168.157.11"
          }
        ]
      },
      target6 => %{
        "corosync_nodes" => [
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
      target1 => %{
        "compare_sbd_version" => 0
      },
      target2 => %{
        "compare_sbd_version" => -1
      },
      target3 => %{
        "compare_sbd_version" => 0
      },
      target4 => %{
        "compare_sbd_version" => -1
      },
      target5 => %{
        "compare_sbd_version" => 0
      },
      target6 => %{
        "compare_sbd_version" => 0
      }
    },
    "B089BE" => %{
      target1 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 15
          }
        }
      },
      target2 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      },
      target3 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      },
      target4 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      },
      target5 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      },
      target6 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_watchdog" => 60
          }
        }
      }
    },
    "9FAAD0" => %{
      target1 => %{
        "exclude_package_pacemaker" => 1
      },
      target2 => %{
        "exclude_package_pacemaker" => -1
      },
      target3 => %{
        "exclude_package_pacemaker" => 1
      },
      target4 => %{
        "exclude_package_pacemaker" => 1
      },
      target5 => %{
        "exclude_package_pacemaker" => -1
      },
      target6 => %{
        "exclude_package_pacemaker" => 1
      }
    },
    "790926" => %{
      target1 => %{
        "hacluster_has_default_password" => false
      },
      target2 => %{
        "hacluster_has_default_password" => false
      },
      target3 => %{
        "hacluster_has_default_password" => false
      },
      target4 => %{
        "hacluster_has_default_password" => false
      },
      target5 => %{
        "hacluster_has_default_password" => false
      },
      target6 => %{
        "hacluster_has_default_password" => false
      }
    },
    "0B6DB2" => %{
      target1 => %{"sbd_pacemaker" => "yes"},
      target2 => %{"sbd_pacemaker" => "yes"},
      target3 => %{"sbd_pacemaker" => "yes"},
      target4 => %{"sbd_pacemaker" => "yes"},
      target5 => %{"sbd_pacemaker" => "yes"},
      target6 => %{"sbd_pacemaker" => "yes"}
    },
    "F50AF5" => %{
      target1 => %{
        "compare_python3_version" => 0
      },
      target2 => %{
        "compare_python3_version" => -1
      },
      target3 => %{
        "compare_python3_version" => 0
      },
      target4 => %{
        "compare_python3_version" => 0
      },
      target5 => %{
        "compare_python3_version" => -1
      },
      target6 => %{
        "compare_python3_version" => 0
      }
    },
    "53D035" => %{
      target1 => %{"token_timeout" => 30_000},
      target2 => %{"token_timeout" => 30_000},
      target3 => %{"token_timeout" => 30_000},
      target4 => %{"token_timeout" => 30_000},
      target5 => %{"token_timeout" => 30_000},
      target6 => %{"token_timeout" => 30_000}
    },
    "21FCA6" => %{
      target1 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      },
      target2 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      },
      target3 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      },
      target4 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      },
      target5 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      },
      target6 => %{
        "corosync_token_retransmits_before_loss_const" => 10
      }
    },
    "00081D" => %{
      target1 => %{"max_messages" => 20},
      target2 => %{"max_messages" => 20},
      target3 => %{"max_messages" => 20},
      target4 => %{"max_messages" => 20},
      target5 => %{"max_messages" => 20},
      target6 => %{"max_messages" => 20}
    },
    "32CFC6" => %{
      target1 => %{
        "totem_interfaces" => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      },
      target2 => %{
        "totem_interfaces" => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      },
      target3 => %{
        "totem_interfaces" => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      },
      target4 => %{
        "totem_interfaces" => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      },
      target5 => %{
        "totem_interfaces" => [
          %{
            "bindnetaddr" => "10.80.1.12",
            "mcastaddr" => "239.192.100.25",
            "mcastport" => 5405,
            "ttl" => 1
          }
        ]
      },
      target6 => %{
        "totem_interfaces" => [
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
      target1 => %{"token_retransmits" => 10},
      target2 => %{"token_retransmits" => 10},
      target3 => %{"token_retransmits" => 10},
      target4 => %{"token_retransmits" => 10},
      target5 => %{"token_retransmits" => 10},
      target6 => %{"token_retransmits" => 10}
    },
    "FB0E0D" => %{
      target1 => %{"consensus_timeout" => 36_000},
      target2 => %{"consensus_timeout" => 36_000},
      target3 => %{"consensus_timeout" => 36_000},
      target4 => %{"consensus_timeout" => 36_000},
      target5 => %{"consensus_timeout" => 36_000},
      target6 => %{"consensus_timeout" => 36_000}
    },
    "D78671" => %{
      target1 => %{"runtime_two_node" => 1},
      target2 => %{"runtime_two_node" => 1},
      target3 => %{"runtime_two_node" => 1},
      target4 => %{"runtime_two_node" => 1},
      target5 => %{"runtime_two_node" => 1},
      target6 => %{"runtime_two_node" => 1}
    },
    "373DB8" => %{
      target1 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
      },
      target2 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
      },
      target3 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
      },
      target4 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
      },
      target5 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
      },
      target6 => %{
        "crm_config_properties" => %{"acme" => 42},
        "resources_primitives" => %{"foo" => [%{"bar" => "baz"}]}
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
      target1 => %{
        "corosync_token_timeout" => 30_000
      },
      target2 => %{
        "corosync_token_timeout" => 30_000
      },
      target3 => %{
        "corosync_token_timeout" => 30_000
      },
      target4 => %{
        "corosync_token_timeout" => 30_000
      },
      target5 => %{
        "corosync_token_timeout" => 30_000
      },
      target6 => %{
        "corosync_token_timeout" => 30_000
      }
    },
    "49591F" => %{
      target1 => %{"sbd_startmode" => "always"},
      target2 => %{"sbd_startmode" => "always"},
      target3 => %{"sbd_startmode" => "always"},
      target4 => %{"sbd_startmode" => "always"},
      target5 => %{"sbd_startmode" => "always"},
      target6 => %{"sbd_startmode" => "always"}
    },
    "822E47" => %{
      target1 => %{"runtime_join" => 60},
      target2 => %{"runtime_join" => 60},
      target3 => %{"runtime_join" => 60},
      target4 => %{"runtime_join" => 60},
      target5 => %{"runtime_join" => 60},
      target6 => %{"runtime_join" => 60}
    },
    "C3166E" => %{
      target1 => %{
        "exclude_package_sbd" => -1
      },
      target2 => %{
        "exclude_package_sbd" => 1
      },
      target3 => %{
        "exclude_package_sbd" => -1
      },
      target4 => %{
        "exclude_package_sbd" => -1
      },
      target5 => %{
        "exclude_package_sbd" => 1
      },
      target6 => %{
        "exclude_package_sbd" => 1
      }
    },
    "205AF7" => %{
      target1 => %{
        "crm_config_properties" => [
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
      },
      target2 => %{
        "crm_config_properties" => [
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
      },
      target3 => %{
        "crm_config_properties" => [
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
      },
      target4 => %{
        "crm_config_properties" => [
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
      },
      target5 => %{
        "crm_config_properties" => [
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
      },
      target6 => %{
        "crm_config_properties" => [
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
      target1 => %{"corosync_join_timeout" => 60},
      target2 => %{"corosync_join_timeout" => 60},
      target3 => %{"corosync_join_timeout" => 60},
      target4 => %{"corosync_join_timeout" => 60},
      target5 => %{"corosync_join_timeout" => 60},
      target6 => %{"corosync_join_timeout" => 60}
    },
    "33403D" => %{
      target1 => %{
        "corosync_transport_protocol" => "udpu"
      },
      target2 => %{
        "corosync_transport_protocol" => "udpu"
      },
      target3 => %{
        "corosync_transport_protocol" => "udpu"
      },
      target4 => %{
        "corosync_transport_protocol" => "udpu"
      },
      target5 => %{
        "corosync_transport_protocol" => "udpu"
      },
      target6 => %{
        "corosync_transport_protocol" => "udpu"
      }
    },
    "6E9B82" => %{
      target1 => %{"corosync_twonode" => 1},
      target2 => %{"corosync_twonode" => 1},
      target3 => %{"corosync_twonode" => 1},
      target4 => %{"corosync_twonode" => 1},
      target5 => %{"corosync_twonode" => 1},
      target6 => %{"corosync_twonode" => 1}
    },
    "61451E" => %{
      target1 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc;dev/sdg"
      },
      target2 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc"
      },
      target3 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc;dev/sdg"
      },
      target4 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc;dev/sdg"
      },
      target5 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc"
      },
      target6 => %{
        "sbd_multiple_sbd_device" => "/dev/sdb;/dev/sdc;dev/sdg"
      }
    },
    "68626E" => %{
      target1 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      },
      target2 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      },
      target3 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      },
      target4 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      },
      target5 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      },
      target6 => %{
        "dump_sbd_devices" => %{
          "/dev/sdb" => %{
            "timeout_msgwait" => 11,
            "timeout_watchdog" => 5
          }
        }
      }
    },
    "9FEFB0" => %{
      target1 => %{
        "compare_pacemaker_version" => 0
      },
      target2 => %{
        "compare_pacemaker_version" => -1
      },
      target3 => %{
        "compare_pacemaker_version" => 0
      },
      target4 => %{
        "compare_pacemaker_version" => 0
      },
      target5 => %{
        "compare_pacemaker_version" => -1
      },
      target6 => %{
        "compare_pacemaker_version" => 0
      }
    },
    "7E0221" => %{
      target1 => %{"runtime_transport" => "udpu"},
      target2 => %{"runtime_transport" => "udpu"},
      target3 => %{"runtime_transport" => "udpu"},
      target4 => %{"runtime_transport" => "udpu"},
      target5 => %{"runtime_transport" => "udpu"},
      target6 => %{"runtime_transport" => "udpu"}
    },
    "CAEFF1" => %{
      target1 => %{"os_flavor" => "Passing"},
      target2 => %{"os_flavor" => "Passing"},
      target3 => %{"os_flavor" => "Passing"},
      target4 => %{"os_flavor" => "Passing"},
      target5 => %{"os_flavor" => "Passing"},
      target6 => %{"os_flavor" => "Passing"}
    },
    "DC5429" => %{
      target1 => %{
        "compare_corosync_version" => 0
      },
      target2 => %{
        "compare_corosync_version" => -1
      },
      target3 => %{
        "compare_corosync_version" => -1
      },
      target4 => %{
        "compare_corosync_version" => 0
      },
      target5 => %{
        "compare_corosync_version" => -1
      },
      target6 => %{
        "compare_corosync_version" => 0
      }
    }
  }

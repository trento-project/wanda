# Gatherers

## Introduction

Gatherers can be thought of as functions:

- they have a name
- they accept argument(s)
- they return a value, the gathered [Fact](./specification.md#facts)

Facts Gathering process in a nutshell

```
fact = gatherer(argument)
```

## Available Gatherers

Here's a collection of build-in gatherers, with information about how to use them.

| Name                            | Implementation                                                                                                                                                     |
|:--------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|[`cibadmin`](#cibadmin)          | [trento-project/agent/../gatherers/cibadmin.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin.go)                      |
|[`corosync.conf`](#corosyncconf) | [trento-project/agent/../gatherers/corosyncconf.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf.go)              |
|[`corosync-cmapctl`](#corosync-cmapctl) | [trento-project/agent/../gatherers/corosynccmapctl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl.go) |
|[`hosts`](#hosts-etchosts)       | [trento-project/agent/../gatherers/hostsfile.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile.go)                    |
|[`package_version`](#package_version) | [trento-project/agent/../gatherers/packageversion.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/packageversion.go)     |
|[`saphostctrl`](#saphostctrl)    | [trento-project/agent/../gatherers/saphostctrl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/saphostctrl.go)                |
|[`sbd_config`](#sbd_config)      | [trento-project/agent/../gatherers/sbd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd.go)                                |
|[`sbd_dump`](#sbd_dump)      | [trento-project/agent/../gatherers/sbddump.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbddump.go)                            |
|[`systemd`](#systemd)            | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go)                        |

### cibadmin

**Argument required**: no.

This gatherer allows accessing Pacemaker's CIB information, the output of the `cibadmin` command more precisely.
As the `cibadmin` command output is in XML format, the gatherer converts it to map/dictionary type of format, so the fields are available with the normal dot access way.
Some specific fields, such as `primitive`, `clone`, `master`, etc (find the complete list [here](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin.go#L48)) are converted to lists, in order to avoid differences when the field appears one or multiple times. 


Sample arguments:

| Name                                                       | Return value                                       | 
|:-----------------------------------------------------------|:---------------------------------------------------|
|`cib.configuration`                                         | complete cib configuration entry as a map          |
|`cib.configuration.resources.primitive.0`                   | first available primitive resource                 |
|`cib.configuration.crm_config.cluster_property_set.nvpair.1`| second nvpair value from the cluster property sets |

Specification examples:

```yaml
facts:
  - name: cib_configuration
    gatherer: cibadmin
    argument: cib.configuration

  - name: first_primitive
    gatherer: cibadmin
    argument: cib.configuration.resources.primitive.0

  - name: second_cluster_property
    gatherer: cibadmin
    argument: cib.configuration.crm_config.cluster_property_set.nvpair.1
```

For extra information refer to [trento-project/agent/../gatherers/cibadmin_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin_test.go)

### corosync.conf

**Argument required**: no.

This gatherer allows accessing information contained in `/etc/corosync/corosync.conf`

```
corosync_related_fact = corosync.conf(some.argument)
```

Sample arguments:

| Name                                | Return value                           |
|:------------------------------------| ---------------------------------------|
|`totem.token`                        | extracted value from the config        |
|`totem.join`                         | extracted value from the config        |
|`nodelist.node.<node_index>.nodeid`  | extracted value from the config        |
|`nodelist.node`                      | list of objects representing the nodes |

Specification examples:

```yaml
facts:
  - name: corosync_token_timeout
    gatherer: corosync.conf
    argument: totem.token

  - name: corosync_join
    gatherer: corosync.conf
    argument: totem.join

  - name: corosync_node1id
    gatherer: corosync.conf
    argument: nodelist.node.0.nodeid

  - name: corosync_node2id
    gatherer: corosync.conf
    argument: nodelist.node.1.nodeid

  - name: corosync_nodes
    gatherer: corosync.conf
    argument: nodelist.node
```

For extra information refer to [trento-project/agent/../gatherers/corosyncconf_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf_test.go)

### corosync-cmapctl

**Argument required**: yes.

This gatherer allows accessing the output of the `corosync-cmapctl` tool. It supports all of the keys returned by it to be queried.


Sample arguments:

| Name                                | Return value                                                 |
|:------------------------------------|:-------------------------------------------------------------|
|`totem.token`                        | extracted value from the command output e.g. `30000`         |
|`runtime.config.totem.token`         | extracted value from the command output e.g. `30000`         |
|`nodelist.node.0.ring0_addr`         | extracted value from the command output e.g. `"10.80.1.11"`  |

Specification examples:

```yaml
facts:
  - name: totem_token
    gatherer: corosync-cmapctl
    argument: totem.token

  - name: runtime_totem_token
    gatherer: corosync-cmapctl
    argument: runtime.config.totem.token

  - name: totem_transport
    gatherer: corosync-cmapctl
    argument: totem.transport

  - name: totem_max_messages
    gatherer: corosync-cmapctl
    argument: runtime.config.totem.max_messages

  - name: node0_ring0addr
    gatherer: corosync-cmapctl
    argument: nodelist.node.0.ring0_addr
```

For extra information refer to [trento-project/agent/../gatherers/corosynccmapctl_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl_test.go)

### hosts (/etc/hosts)

**Argument required**: no.

This gatherer allows accessing the hostnames that are resolvable through `/etc/hosts`. It
does **not** use domain resolution in any way but instead directly parses the file.

It allows one argument to be specified or none at all:
 - When a hostname is provided as an argument, the gatherer will return an array of IPv4 and/or IPv6 addresses.
 - When no argument is provided, the gatherer will return a map with hostname as keys and arrays with IPv4 and/or IPv6 addresses.

Sample arguments:

| Name                                | Return value                                                                                            |
|:------------------------------------|:--------------------------------------------------------------------------------------------------------|
|`localhost`                          | list of IPs resolving `localhost` e.g. `["127.0.0.1", "::1"]`                                           |
|`node1`                              | list of IPs resolving `node1` e.g. `["172.22.0.1"]`                                                     |
|`no argument provided`               | map with hostnames and IP addresses e.g. `{"localhost": ["127.0.0.1", "::1"], "node1": ["172.22.0.1"]}` |

Specification examples:
```yaml
facts:
  - name: hosts_node1
    gatherer: hosts
    argument: node1
  
  - name: hosts_node2
    gatherer: hosts
    argument: node2

  - name: hosts_all
    gatherer: hosts

```

For more information refer to [trento-project/agent/../gatherers/hostsfile_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile_test.go)

### package_version

**Argument required**: yes.

This gatherer returns the version as a string of the specified package

Sample arguments:

| Name                  | Return value                                                                         |
|:----------------------|:-------------------------------------------------------------------------------------|
|`corosync`             |a string containing the installed version for the package `package_name`, e.g "2.4.5" |

Specification examples:

```yaml
facts:
  - name: corosync_version
    gatherer: package_version
    argument: corosync

  - name: pacemaker_version
    gatherer: package_version
    argument: pacemaker

  ...
```

For extra information refer to [trento-project/agent/../gatherers/packageversion_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/packageversion_test.go)

### saphostctrl

**Argument required**: yes.

This gatherer allows access to certain webmethods that `saphostctrl` implements. An argument is required to specify
which webmethod should be called. This webmethod is passed to the `saphostctrl` command-line tool through the `-function` argument.

Supported webmethods:
  - `Ping`
  - `ListInstances`

A `Ping` call with a successful return should look like:

```
{
  "status" => "SUCCESS", 
  "elapsed" => 543341,
},
```

or as follows for a failed one:

```
{
  "status" => "FAILED",
  "elapsed" => 497,
},
```

A `ListInstances` call return should instead look like:

```
[
  {
    "changelist" => 2069355,
    "hostname" => "s41db",
    "instance" => "11",
    "patch" => 819,
    "sapkernel" => 753,
    "system" => "HS1",
  },
]
```

Specification examples:

```yaml
facts:
  - name: ping
    gatherer: saphostctrl
    argument: Ping

  - name: list_instances
    gatherer: saphostctrl
    argument: ListInstances

  ...
```

For extra information refer to [trento-project/agent/../gatherers/saphostctrl_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/saphostctrl_test.go)

### sbd_config

**Argument required**: yes.

This gatherer allows accessing information contained in `/etc/sysconfig/sbd`

Sample arguments:

| Name           | Return value                                                |
|:---------------|:------------------------------------------------------------|
|`SBD_PACEMAKER` | extracted value from the config (e.g. `yes`)                |
|`SBD_STARTMODE` | extracted value from the config (e.g. `always`)             |
|`SBD_DEVICE`    | extracted value from the config (e.g. `/dev/vdc;/dev/vdb`)  |

Specification examples:
```yaml
facts:
  - name: sbd_pacemaker
    gatherer: sbd_config
    argument: SBD_PACEMAKER

  - name: sbd_startmode
    gatherer: sbd_config
    argument: SBD_STARTMODE

  - name: sbd_device
    gatherer: sbd_config
    argument: SBD_DEVICE
```

For extra information refer to [trento-project/agent/../gatherers/sbd_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd_test.go)

### sbd_dump

**Argument required**: no.

This gatherer allows accessing the sbd dump command output data.

It executes the `sbd -d <device> dump` command in all devices configured in the `SBD_DEVICE` field on `/etc/sysconfig/sbd` and aggregates results in only one fact.

Note that:
- no arguments are required
- if any dump fails, a fact error is returned

Dumped keys (`Timeout (watchdog)`, `Timeout (msgwait)`, `Number of slots`, etc) are sanitized to simplify their access and usage in the expression language. 

```rust
{
  "/path/to/a-device" => {
    "header_version"   => 2.1,
    "number_of_slots"  => 255,
    "sector_size"      => 512,
    "timeout_allocate" => 2,
    "timeout_loop"     => 1,
    "timeout_msgwait"  => 10,
    "timeout_watchdog" => 5,
    "uuid"             => "e09c8993-0cba-438d-a4c3-78e91f58ee52",
  },
  "/path/to/another-device" => {
    "header_version"   => 2.1,
    "number_of_slots"  => 255,
    "sector_size"      => 512,
    "timeout_allocate" => 2,
    "timeout_loop"     => 1,
    "timeout_msgwait"  => 10,
    "timeout_watchdog" => 5,
    "uuid"             => "e5b7c05a-1d3c-43d0-827a-9d4dd05ca54a",
  }
}
```

Specification examples:

```yaml
facts:
  - name: sbd_devices_dump
    gatherer: sbd_dump
```

For extra information refer to [trento-project/agent/../gatherers/sbddump_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbddump_test.go)

### systemd

**Argument required**: yes.

Gather systemd daemons state. It returns an `active/inactive` string. If the daemon is disabled or does not even exist, `inactive` is returned.

Specification examples:
```yaml
facts:
  - name: sbd_state
    gatherer: systemd
    argument: sbd

  - name: corosync_state
    gatherer: systemd
    argument: corosync
```

For extra information refer to [trento-project/agent/../gatherers/systemd_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd_test.go)

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

| name                             | implementation                                                                                                                                                 |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`corosync.conf`](#corosyncconf) | [trento-project/agent/../gatherers/corosyncconf.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf.go)          |
| [`corosync-cmapctl`](#corosync-cmapctl) | [trento-project/agent/../gatherers/corosynccmapctl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl.go)          |
| [`hosts`](#hosts-etchosts)       | [trento-project/agent/../gatherers/hostsfile.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile.go)                |
| [`package_version`](#package_version) | [trento-project/agent/../gatherers/packageversion.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/packageversion.go) |
| [`sbd_config`](#sbd_config)      | [trento-project/agent/../gatherers/sbd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd.go)                            |
| [`systemd`](#systemd)            | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go)                    |

### corosync.conf

This gatherer allows accessing information contained in `/etc/corosync/corosync.conf`

```
corosync_related_fact = corosync.conf(some.argument)
```

Sample arguments
| Name                                 | Return value  
| ------------------------------------ | --------------------------------------
| `totem.token`                        | extracted value from the config
| `totem.join`                         | extracted value from the config
| `nodelist.node.<node_index>.nodeid`  | extracted value from the config
| `nodelist.node`                      | list of objects representing the nodes

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

This gatherer allows accessing information outputted by `corosync-cmapctl`. It supports all of the keys outputted by `corosync-cmapctl` to be queried here.

Sample arguments
| Name                                 | Return value  
| ------------------------------------ | --------------------------------------
| `runtime.config.totem.consensus`     | extracted value from the command output e.g. `36000`
| `runtime.votequorum.two_node`        | extracted value from the command output e.g. `1`
| `totem.transport`                    | extracted value from the command output e.g. `"udpu"`
| `runtime.config.totem.max_messages`  | extracted value from the command output e.g. `20`

Specification examples:

```yaml
facts:
  - name: totem_consensus
    gatherer: corosync-cmapctl
    argument: totem.token

  - name: votequorum_two_node
    gatherer: corosynccmapctl
    argument: totem.join

  - name: totem_transport
    gatherer: corosynccmapctl
    argument: totem.transport

  - name: totem_max_messages
    gatherer: corosynccmapctl
    argument: runtime.config.totem.max_messages

  - name: corosync_nodes
    gatherer: corosynccmapctl
    argument: nodelist.node
```

For extra information refer to [trento-project/agent/../gatherers/corosynccmapctl_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl_test.go)

### hosts (/etc/hosts)

This gatherer allows accessing the hostnames that are resolvable through `/etc/hosts`. It
does **not** use domain resolution in any way but instead directly parses the file.

It allows one argument to be specified or none at all:
 - When a hostname is provided as an argument, the gatherer will return an array of IPv4 and/or IPv6 addresses.
 - When no argument is provided, the gatherer will return a map with hostname as keys and arrays with IPv4 and/or IPv6 addresses.

Sample arguments
| name                                 | Return value          
| ------------------------------------ | --------------------------------------------------------
| `localhost`                          | list of IPs resolving `localhost` e.g. `["127.0.0.1", "::1"]`
| `node1`                              | list of IPs resolving `node1` e.g. `["172.22.0.1"]`
| `no argument provided`               | map with hostnames and IP addresses e.g. `{"localhost": ["127.0.0.1", "::1"], "node1": ["172.22.0.1"]}`

Specification examples:
```yaml
facts:
  - name: hosts_node1
    gatherer: hosts
    argument: node1
  
  - name: hosts_node2
    gatherer: hosts
    argument: node2

  - name: hsots_all
    gatherer: hosts

```

For more information refer to [trento-project/agent/../gatherers/hostsfile_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile_test.go)

### package_version

This gatherer returns the version as a string of the specified package

Sample arguments
| Name                   | Return value  
| ---------------------- | -------------------------------------------------------------------------------------
| `corosync`             | a string containing the installed version for the package `package_name`, e.g "2.4.5"

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

### sbd_config

This gatherer allows accessing information contained in `/etc/sysconfig/sbd`

Sample arguments
| Name | Return value  
| ------------------------------------ | ------------------------------------------
| `SBD_PACEMAKER` | extracted value from the config (e.g. `yes`)
| `SBD_STARTMODE` | extracted value from the config (e.g. `always`)
| `SBD_DEVICE`    | extracted value from the config (e.g. `/dev/vdc;/dev/vdb`)

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

### systemd

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

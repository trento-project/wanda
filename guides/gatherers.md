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

| name                             | implementation                                                                                                                                        |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`corosync.conf`](#corosyncconf) | [trento-project/agent/../gatherers/corosyncconf.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf.go) |
| [`hosts`](#hosts-etchosts)       | [trento-project/agent/../gatherers/hostsfile.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile.go)       |
| [`sbd_config`](#sbd_config)      | [trento-project/agent/../gatherers/sbd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd.go)                   |
| [`systemd`](#systemd)            | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go)           |

### corosync.conf

This gatherer allows accessing information contained in `/etc/corosync/corosync.conf`

```
corosync_related_fact = corosync.conf(some.argument)
```

Sample arguments
| name | Return value  
| ------------------------------------ | ------------------------------------------
| `totem.token` | extracted value from the config
| `totem.join` | extracted value from the config
| `nodelist.node.<node_index>.nodeid` | extracted value from the config
| `nodelist.node` | list of objects representing the nodes

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

### hosts (/etc/hosts)

This gatherer allows accessing the hostnames that are resolvable through `/etc/hosts`. It
does **not** use domain resolution in any way but instead directly parses the file.

It accepts only one parameter which is the hostname to attempt to resolve.

```
hosts_related_fact = hosts(example.com)
```

Sample arguments
| name                                 | Return value          
| ------------------------------------ | --------------------------------------------------------
| `localhost`                          | list of IPs resolving `localhost` e.g. ["127.0.0.1", "::1"]
| `node1`                              | list of IPs resolving `node1` e.g. ["172.22.0.1"]
| `...`                                | `...`

Specification examples:
```yaml
facts:
  - name: hosts_node1
    gatherer: hosts
    argument: node1
  
  - name: hosts_node2
    gatherer: hosts
    argument: node2

```

For more information refer to [trento-project/agent/../gatherers/hostsfile_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile_test.go)

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


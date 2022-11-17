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
| [`systemd`](#systemd) | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go) |

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

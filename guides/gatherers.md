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

Here's a collection of built-in gatherers, with information about how to use them.

| Name                                    | Implementation                                                                                                                                              |
| :-------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`cibadmin`](#cibadmin)                 | [trento-project/agent/../gatherers/cibadmin.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin.go)               |
| [`corosync.conf`](#corosyncconf)        | [trento-project/agent/../gatherers/corosyncconf.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf.go)       |
| [`corosync-cmapctl`](#corosync-cmapctl) | [trento-project/agent/../gatherers/corosynccmapctl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl.go) |
| [`hosts`](#hosts-etchosts)              | [trento-project/agent/../gatherers/hostsfile.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile.go)             |
| [`package_version`](#package_version)   | [trento-project/agent/../gatherers/packageversion.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/packageversion.go)   |
| [`saphostctrl`](#saphostctrl)           | [trento-project/agent/../gatherers/saphostctrl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/saphostctrl.go)         |
| [`sbd_config`](#sbd_config)             | [trento-project/agent/../gatherers/sbd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd.go)                         |
| [`sbd_dump`](#sbd_dump)                 | [trento-project/agent/../gatherers/sbddump.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbddump.go)                 |
| [`systemd`](#systemd)                   | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go)                 |
| [`verify_password`](#verify_password)   | [trento-project/agent/../gatherers/verifypassword.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/verifypassword.go)   |

### cibadmin

**Argument required**: no.

This gatherer allows accessing Pacemaker's CIB information, the output of the `cibadmin` command more precisely.
As the `cibadmin` command output is in XML format, the gatherer converts it to map/dictionary type format, so the fields are available with the normal dot access way.
Some specific fields, such as `primitive`, `clone`, `master`, etc (find the complete list [here](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin.go#L48)) are converted to lists, in order to avoid differences when the field appears one or multiple times.

Example arguments:

| Name                                                           | Return value                                                       |
| :------------------------------------------------------------- | :----------------------------------------------------------------- |
| `cib.configuration`                                            | complete cib configuration entry as a map                          |
| `cib.configuration.resources.primitive.0`                      | first available primitive resource                                 |
| `cib.configuration.crm_config.cluster_property_set.0.nvpair.1` | second nvpair value from the first element of cluster_property_set |

Example specification:

```yaml
facts:
  - name: cib_configuration
    gatherer: cibadmin
    argument: cib.configuration

  - name: first_primitive
    gatherer: cibadmin
    argument: cib.configuration.resources.primitive.0

  - name: first_cluster_property_set_second_nvpair
    gatherer: cibadmin
    argument: cib.configuration.crm_config.cluster_property_set.0.nvpair.1
```

Example output (in Rhai):

```ts
// first_primitive
#{
    class: "stonith",
    id: "stonith-sbd",
    instance_attributes: #{
        id: "stonith-sbd-instance_attributes",
        nvpair: [#{
            id: "stonith-sbd-instance_attributes-pcmk_delay_max",
            name: "pcmk_delay_max",
            value: "30s"
        }]
    },
    type: "external/sbd"
};

// first_cluster_property_set_second_nvpair
#{
    id: "cib-bootstrap-options-dc-version",
    name: "dc-version",
    value: "2.0.4+20200616.2deceaa3a-3.12.1-2.0.4+20200616.2deceaa3a"
};
```

### corosync.conf

**Argument required**: no.

This gatherer allows accessing the information contained in `/etc/corosync/corosync.conf`

Example arguments:

| Name                                | Return value                           |
| :---------------------------------- | -------------------------------------- |
| `totem.token`                       | extracted value from the config        |
| `totem.join`                        | extracted value from the config        |
| `nodelist.node.<node_index>.nodeid` | extracted value from the config        |
| `nodelist.node`                     | list of objects representing the nodes |

Example specification:

```yaml
facts:
  - name: corosync_token_timeout
    gatherer: corosync.conf
    argument: totem.token

  - name: corosync_join
    gatherer: corosync.conf
    argument: totem.join

  - name: corosync_node_id_0
    gatherer: corosync.conf
    argument: nodelist.node.0.nodeid

  - name: corosync_node_id_1
    gatherer: corosync.conf
    argument: nodelist.node.1.nodeid

  - name: corosync_nodes
    gatherer: corosync.conf
    argument: nodelist.node
```

Example output (in Rhai):

```ts
// corosync_token_timeout
30000;

// corosync_join
60;

// corosync_node_id_0
1;

// corosync_node_id_1
2;

// corosync_nodes
[#{nodeid: 1, ring0_addr: "192.168.157.10"}, #{nodeid: 2, ring0_addr: "192.168.157.11"}];
```

For extra information refer to [trento-project/agent/../gatherers/corosyncconf_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf_test.go)

### corosync-cmapctl

**Argument required**: yes.

This gatherer allows accessing the output of the `corosync-cmapctl` tool. It supports all of the keys returned by it to be queried.

Example arguments:

| Name                         | Return value                     |
| :--------------------------- | :------------------------------- |
| `totem.token`                | extracted value from the command |
| `runtime.config.totem.token` | extracted value from the command |
| `totem.transport`            | extracted value from the command |
| `totem.transport`            | extracted value from the command |
| `nodelist.node.0.ring0_addr` | extracted value from the command |
| `nodelist.node`              | extracted value from the command |
| `nodelist.node.1`            | extracted value from the command |

Example specification:

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

  - name: node_0_ring0addr
    gatherer: corosync-cmapctl
    argument: nodelist.node.0.ring0_addr

  - name: node_list
    gatherer: corosync-cmapctl
    argument: nodelist.node

  - name: second_node
    gatherer: corosync-cmapctl
    argument: nodelist.node.1
```

Example output (in Rhai):

```ts
// totem_token
30000;

// runtime_totem_token
30000;

// totem_transport
("udpu");

// totem_max_messages
20;

// node_0_ring0addr
20;

// node_list
#{
  "0": #{ "nodeid": 1, "ring0_addr": "10.80.1.11" },
  "1": #{ "nodeid": 2, "ring0_addr": "10.80.1.12" }
}

// second_node
#{ "nodeid": 2, "ring0_addr": "10.80.1.12" }
```

### hosts (/etc/hosts)

**Argument required**: no.

This gatherer allows accessing the hostnames that are resolvable through `/etc/hosts`. It
does **not** use domain resolution in any way but instead directly parses the file.

It allows one argument to be specified or none at all:

- When a hostname is provided as an argument, the gatherer will return an array of IPv4 and/or IPv6 addresses.
- When no argument is provided, the gatherer will return a map with hostname as keys and arrays with IPv4 and/or IPv6 addresses.

Example arguments:

| Name                   | Return value                        |
| :--------------------- | :---------------------------------- |
| `localhost`            | list of IPs resolving               |
| `node1`                | list of IPs resolving               |
| `no argument provided` | map with hostnames and IP addresses |

Example specification:

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

Example output (in Rhai):

```ts
// hosts_node1
["127.0.0.1", "::1"];

// hosts_node2
["192.168.157.11"];

// hosts_all
#{
  "localhost": ["127.0.0.1", "::1"],
  "node1": ["192.168.157.10"],
  "node2": ["192.168.157.11"],
  ...
};
```

### package_version

**Argument required**: yes.

This gatherer supports two usecases:
 - get the version as a string of the specified package (useful to check if the installed version of a package is the same across multiple nodes)
 - compare a given version string against the installed version string of a given package.

While for the first usecase, a simple string containing the version is returned, for the second usecase, the return value is as follows (see additional details [here](https://fedoraproject.org/wiki/Archive:Tools/RPM/VersionComparison#The_rpmvercmp_algorithm)):
 - A value of `0` if the provided version string matches the installed package version for the requested package.
 - A value of `-1` if the provided version string is older that what's currently installed.
 - A value of `1` if the provided version string is newer than what's currently installed.

Naming the facts / expectations accordingly is specially important here to avoid confusion.
 - We suggest using a `compare_` prefix for package version comparisons and `package_` to retrieve
   a package version

Additionally, when using the version comparison, it increases readability to explicitly mention
the values to compare against:

```yaml
facts:
  - name: compare_package_corosync
    gatherer: package_version
    argument: corosync,2.4.5

values:
  - name: greater_than_installed
    default: 1
  - name: lesser_than_installed
    default: -1
  - name: same_as_installed
    default: 0

expectations:
  - name: compare_package_corosync
    expect: facts.compare_package_corosync == values.greater_than_installed
```

Example arguments:

| Name                 | Return value                                                 |
| :------------------- | :----------------------------------------------------------- |
| `package_name`       | a string containing the installed version of the rpm package |
| `package_name,2.4.5` | an integer with a value of `-1`, `0` or `-1` (see above)     |

Example specification:

```yaml
facts:
  - name: package_corosync
    gatherer: package_version
    argument: corosync

  - name: package_pacemaker
    gatherer: package_version
    argument: pacemaker

  - name: compare_package_corosync
    gatherer: package_version
    argument: corosync,2.4.5

  ...
```

Example output (in Rhai):

```ts
// package_corosync
"2.4.5";

// package_pacemaker
"2.0.4+20200616.2deceaa3a";

// compare_package_corosync
0
```

### saphostctrl

**Argument required**: yes.

This gatherer allows access to certain webmethods that `saphostctrl` implements. An argument is required to specify
which webmethod should be called. This webmethod is passed to the `saphostctrl` command-line tool through the `-function` argument.

Supported webmethods:

- `Ping`
- `ListInstances`

A `Ping` call with a successful return should look like this:

Example specification:

```yaml
facts:
  - name: ping
    gatherer: saphostctrl
    argument: Ping

  - name: list_instances
    gatherer: saphostctrl
    argument: ListInstances
```

Example output (in Rhai):

```ts
// ping
#{elapsed: 579770.0, status: "SUCCESS"}

// list_instances
[
    #{
        "changelist": 1908545,
        "hostname": "vmhana01",
        "instance": "00",
        "patch": 410,
        "sapkernel": 753,
        "system": "PRD"
    }
];
```

### sbd_config

**Argument required**: yes.

This gatherer allows accessing the information contained in `/etc/sysconfig/sbd`

Example arguments:

| Name            | Return value                    |
| :-------------- | :------------------------------ |
| `SBD_PACEMAKER` | extracted value from the config |
| `SBD_STARTMODE` | extracted value from the config |
| `SBD_DEVICE`    | extracted value from the config |

Example specification:

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

Example output (in Rhai):

```ts
// sbd_pacemaker
"yes";

// sbd_startmode
"always";

// sbd_device
"/dev/vdc;/dev/vdb";
```

### sbd_dump

**Argument required**: no.

This gatherer allows accessing the sbd dump command output data.

It executes the `sbd -d <device> dump` command in all devices configured in the `SBD_DEVICE` field on `/etc/sysconfig/sbd` and aggregates results in only one fact.

Note that:

- no arguments are required
- if any of the dumps fail, a fact error is returned

Dumped keys (`Timeout (watchdog)`, `Timeout (msgwait)`, `Number of slots`, etc) are sanitized to simplify their access and usage in the expression language.

Example specification:

```yaml
facts:
  - name: sbd_devices_dump
    gatherer: sbd_dump
```

Example output (in Rhai):

```ts
// sbd_devices_dump
#{
    "/dev/vdc": #{
        header_version: 2.1,
        number_of_slots: 255,
        sector_size: 512,
        timeout_allocate: 2,
        timeout_loop: 1,
        timeout_msgwait: 10,
        timeout_watchdog: 5,
        uuid: "69048391-c647-4b34-a03a-f704f5cc2258"
    }
};
```

For extra information refer to [trento-project/agent/../gatherers/sbddump_test.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbddump_test.go)

### systemd

**Argument required**: yes.

Gather systemd units state. It returns an `active/inactive` string.
If the service is disabled or it does not exist, `inactive` is returned.

Example arguments:

| Name           | Return value              |
| :------------- | :------------------------ |
| `trento-agent` | state of the systemd unit |

```yaml
facts:
  - name: sbd_state
    gatherer: systemd
    argument: sbd

  - name: corosync_state
    gatherer: systemd
    argument: corosync
```

Example output (in Rhai):

```ts
// sbd_state
"active";

// corosync_state
"inactive";
```

### verify_password

**Argument required**: yes.

This gatherer determines whether a given user has its password still set to an unsafe password.
It returns `true` if the password matches a password in the list of unsafe passwords, `false` otherwise.

Specification examples:

```yaml
facts:
  - name: hacluster_has_default_password
    gatherer: verify_password
    argument: hacluster
```

For the argument, only whitelisted users are allowed. Currently whitelisted usernames:

- `hacluster`

List of unsafe passwords:

- `linux`

Example output (in Rhai):

```ts
// hacluster_has_default_password
true;
```

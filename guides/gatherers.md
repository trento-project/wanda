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

## Gatherers versioning

The gatherers implementation supports a versioning mechanism in order to enable non-backwards compatibility changes in any of them. When an update to
the trento-agent includes a non-backwards compatible change in a gatherer (e.g., changes to the Rhai output format), its version is
bumped by incrementing the @vN suffix that follows the gatherer's name, where 'N' represents the new version of that gatherer.
Example:

- `systemd@v1` -> Represents the first version of the systemd gatherer
- `systemd@v2` -> Represents the second version of the systemd gatherer

Note that when writing a check, if no tag is specified (e.g. `systemd`), the latest version is used. It is **strongly** recommended to always pin your
checks to a specific version of a gatherer.

Not all changes in a released gatherer get a new version tag. A new version tag is released only for breaking changes, while non-breaking changes such
as additional fields in the Rhai output reuse the latest existing tag. To use a check that relies on a newer field introduced after an update, upgrade
the agent to the latest version to ensure that the required gatherers are also up-to-date.

## Available Gatherers

Here's a collection of built-in gatherers, with information about how to use them.

| Name                                                                   | Implementation                                                                                                                                                                      |
| :--------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`ascsers_cluster@v1`](#ascsers_clusterv1)                             | [trento-project/agent/../gatherers/ascsers_cluster.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/ascsers_cluster.go)                         |
| [`cibadmin@v1`](#cibadminv1)                                           | [trento-project/agent/../gatherers/cibadmin.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/cibadmin.go)                                       |
| [`corosync-cmapctl@v1`](#corosync-cmapctlv1)                           | [trento-project/agent/../gatherers/corosynccmapctl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosynccmapctl.go)                         |
| [`corosync.conf@v1`](#corosyncconfv1)                                  | [trento-project/agent/../gatherers/corosyncconf.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/corosyncconf.go)                               |
| [`dir_scan@v1`](#dir_scanv1)                                           | [trento-project/agent/../gatherers/dir_scan.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/dir_scan.go)                                       |
| [`disp+work@v1`](#dispworkv1)                                          | [trento-project/agent/../gatherers/dispwork.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/dispwork.go)                                       |
| [`fstab@v1`](#fstabv1)                                                 | [trento-project/agent/../gatherers/fstab.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/fstab.go)                                             |
| [`groups@v1`](#groupsv1)                                               | [trento-project/agent/../gatherers/groups.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/groups.go)                                           |
| [`hosts@v1`](#hostsv1)                                                 | [trento-project/agent/../gatherers/hostsfile.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/hostsfile.go)                                     |
| [`ini_files@v1`](#ini_filesv1)                                         | [trento-project/agent/../gatherers/ini_files.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/ini_files.go)                                     |
| [`mount_info@v1`](#mount_infov1)                                       | [trento-project/agent/../gatherers/mountinfo.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/mountinfo.go)                                     |
| [`os-release@v1`](#os-releasev1)                                       | [trento-project/agent/../gatherers/osrelease.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/osrelease.go)                                     |
| [`package_version@v1`](#package_versionv1)                             | [trento-project/agent/../gatherers/packageversion.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/packageversion.go)                           |
| [`passwd@v1`](#passwdv1)                                               | [trento-project/agent/../gatherers/passwd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/passwd.go)                                           |
| [`products@v1`](#productsv1)                                           | [trento-project/agent/../gatherers/products.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/products.go)                                       |
| [`sap_profiles@v1`](#sap_profilesv1)                                   | [trento-project/agent/../gatherers/sapprofiles.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sapprofiles.go)                                 |
| [`sapcontrol@v1`](#sapcontrolv1)                                       | [trento-project/agent/../gatherers/sapcontrol.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sapcontrol.go)                                   |
| [`saphostctrl@v1`](#saphostctrlv1)                                     | [trento-project/agent/../gatherers/saphostctrl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/saphostctrl.go)                                 |
| [`sapinstance_hostname_resolver@v1`](#sapinstance_hostname_resolverv1) | [trento-project/agent/../gatherers/sapinstancehostnameresolver.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sapinstancehostnameresolver.go) |
| [`sapservices@v1`](#sapservicesv1)                                     | [trento-project/agent/../gatherers/sapservices.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sapservices.go)                                 |
| [`saptune@v1`](#saptunev1)                                             | [trento-project/agent/../gatherers/saptune.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/saptune.go)                                         |
| [`sbd_config@v1`](#sbd_configv1)                                       | [trento-project/agent/../gatherers/sbd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbd.go)                                                 |
| [`sbd_dump@v1`](#sbd_dumpv1)                                           | [trento-project/agent/../gatherers/sbddump.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sbddump.go)                                         |
| [`sudoers@v1`](#sudoersv1)                                             | [trento-project/agent/../gatherers/sudoers.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sudoers.go)                                         |
| [`sysctl@v1`](#sysctlv1)                                               | [trento-project/agent/../gatherers/sysctl.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/sysctl.go)                                           |
| [`systemd@v1`](#systemdv1)                                             | [trento-project/agent/../gatherers/systemd.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd.go)                                         |
| [`systemd@v2`](#systemdv2)                                             | [trento-project/agent/../gatherers/systemd_v2.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/systemd_v2.go)                                   |
| [`verify_password@v1`](#verify_passwordv1)                             | [trento-project/agent/../gatherers/verifypassword.go](https://github.com/trento-project/agent/blob/main/internal/factsengine/gatherers/verifypassword.go)                           |

<span id="ascsers_clusterv1"></span>

### ascsers_cluster@v1

**Argument required**: no.

This gatherer allows accessing ASCS/ERS clusters managed systems most relevant information, such as the ensa version and the installed instances.
It is really useful to check multi SID environments.
It doesn't replace the need to use the `cibadmin` gatherer, as this gatherer aims to facilitate complex data manipulations using data from that gatherer.
The ensa version is obtained running the `GetProcessList` sapcontrol webcommand and parsing the `name` output in each of the installed instances.

Example specification:

```yaml
facts:
  - name: ascsers
    gatherer: ascsers_cluster@v1
```

Example output (in Rhai):

```ts
#{
    "PRD": #{
      "ensa_version": "ensa1", // available values: ensa1/ensa2/unknown
      "instances": [
        #{
          "resource_group": "grp_PRD_ASCS00",
          "resource_instance": "rsc_sap_PRD_ASCS00",
          "name": "ASCS00",
          "instance_number": "00",
          "virtual_hostname": "sapascs00",
          "filesystem_based": true, // if the instance resource group has a FileSystem resource
          "local": true // if the instance is running locally in this host (sapcontrol returns a positive response for GetProcessList)
        },
        #{
          "resource_group": "grp_PRD_ERS10",
          "resource_instance": "rsc_sap_PRD_ERS10",
          "name": "ERS10",
          ...
        }
      ]
    },
    "QAS": #{
      "ensa_version": "ensa2",
      ...
    }
};
```

<span id="cibadminv1"></span>

### cibadmin@v1

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
    gatherer: cibadmin@v1
    argument: cib.configuration

  - name: first_primitive
    gatherer: cibadmin@v1
    argument: cib.configuration.resources.primitive.0

  - name: first_cluster_property_set_second_nvpair
    gatherer: cibadmin@v1
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

<span id="corosync-cmapctlv1"></span>

### corosync-cmapctl@v1

**Argument required**: yes.

This gatherer allows accessing the output of the `corosync-cmapctl` tool. It supports all of the keys returned by it to be queried.

Example arguments:

| Name                                | Return value                     |
| :---------------------------------- | :------------------------------- |
| `totem.token`                       | extracted value from the command |
| `runtime.config.totem.token`        | extracted value from the command |
| `totem.transport`                   | extracted value from the command |
| `runtime.config.totem.max_messages` | extracted value from the command |
| `nodelist.node.0.ring0_addr`        | extracted value from the command |
| `nodelist.node`                     | extracted value from the command |
| `nodelist.node.1`                   | extracted value from the command |

Example specification:

```yaml
facts:
  - name: totem_token
    gatherer: corosync-cmapctl@v1
    argument: totem.token

  - name: runtime_totem_token
    gatherer: corosync-cmapctl@v1
    argument: runtime.config.totem.token

  - name: totem_transport
    gatherer: corosync-cmapctl@v1
    argument: totem.transport

  - name: totem_max_messages
    gatherer: corosync-cmapctl@v1
    argument: runtime.config.totem.max_messages

  - name: node_0_ring0addr
    gatherer: corosync-cmapctl@v1
    argument: nodelist.node.0.ring0_addr

  - name: node_list
    gatherer: corosync-cmapctl@v1
    argument: nodelist.node

  - name: second_node
    gatherer: corosync-cmapctl@v1
    argument: nodelist.node.1
```

Example output (in Rhai):

```ts
// totem_token
30000;

// runtime_totem_token
30000;

// totem_transport
"udpu";

// totem_max_messages
20;

// node_0_ring0addr
"10.80.1.11";

// node_list
#{
  "0": #{
    nodeid: 1,
    ring0_addr: "10.80.1.11"
  },
  "1": #{
    nodeid: 2,
    ring0_addr: "10.80.1.12"
  }
};

// second_node
#{ nodeid: 2, ring0_addr: "10.80.1.12" };
```

<span id="corosyncconfv1"></span>

### corosync.conf@v1

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
    gatherer: corosync.conf@v1
    argument: totem.token

  - name: corosync_join
    gatherer: corosync.conf@v1
    argument: totem.join

  - name: corosync_node_id_0
    gatherer: corosync.conf@v1
    argument: nodelist.node.0.nodeid

  - name: corosync_node_id_1
    gatherer: corosync.conf@v1
    argument: nodelist.node.1.nodeid

  - name: corosync_nodes
    gatherer: corosync.conf@v1
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

<span id="dir_scanv1"></span>

### dir_scan@v1

**Argument required**: Yes

This gatherer allows to scan directories with a glob pattern provided as argument.
The gatherer returns a list of files matched by the pattern with group/user information associated to each file.

Example argument:

- `/usr/sap/[A-Z][A-Z0-9][A-Z0-9]/ERS[0-9][0-9]`
- `/etc/polkit-1/rules.d/[0-9][0-9]-SAP[A-Z][A-Z0-9][A-Z0-9]-[0-9][0-9].rules`

Example specification:

```yaml
facts:
  - name: dir_scan
    gatherer: dir_scan@v1
    argument: "/usr/sap/[A-Z][A-Z0-9][A-Z0-9]/ERS[0-9][0-9]"
```

Example output (in Rhai):

```ts
  [
    #{
      "name": "/usr/sap/PRD/ERS01",
      "owner": "trento",
      "group": "trento"
    },
     #{
      "name": "/usr/sap/QAS/ERS02",
      "owner": "trento",
      "group": "trento"
    },
  ]
```

<span id="dispworkv1"></span>

### disp+work@v1

**Argument required**: No

This gatherer allows access to the `disp+work` command output and returns some fields available there.
The command is executed for all installed SAP systems, accessing it with the `<sid>adm` user. The fields for
each system are returned in a map using the SAP sid as key.

If the `disp+work` command execution fails, the fields are returned with an empty string value.

The available fields are `compilation_mode`, `kernel_release` and `patch_number`.

Example specification:

```yaml
facts:
  - name: dispwork
    gatherer: disp+work@v1
```

Example output (in Rhai):

```ts
#{
  "NWP": #{
    "compilation_mode": "UNICODE",
    "kernel_release": "753",
    "patch_number": "900"
  },
  // failed execution
  "NWQ": #{
    "compilation_mode": "",
    "kernel_release": "",
    "patch_number": ""
  },
  "NWD": #{
    "compilation_mode": "UNICODE",
    "kernel_release": "753",
    "patch_number": "910"
  }
}
```

<span id="fstabv1"></span>

### fstab@v1

**Argument required**: no.

This gatherer allows access to the /etc/fstab file, returning all entries available at the file.

Example specification:

```yaml
facts:
  - name: fstab
    gatherer: fstab@v1
```

Example output (in Rhai):

```ts
[
    #{
        "device": "/dev/system/root",
        "mount_point": "/",
        "file_system_type": "btrfs",
        "options": [],
        "backup": 0,
        "check_order": 1,
    },
    #{
        "device": "/dev/system/root",
        "mount_point": "/home",
        "file_system_type": "ext4",
        "options": ["defaults"],
        "backup": 0,
        "check_order": 1,
    },
  ...
];
```

<span id="groupsv1"></span>

### groups@v1

**Argument required**: no.

This gatherer allows access to the /etc/group file, returning all entries available at the file.

Example specification:

```yaml
facts:
  - name: groups
    gatherer: groups@v1
```

Example output (in Rhai):

```ts
[
    #{
        "name": "root",
        "gid": 0,
        "users": [],
    },
    #{
        "name": "adm",
        "gid": 1,
        "users": ["trento"],
    }
  ...
];
```

<span id="hostsv1"></span>

### hosts@v1

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
    gatherer: hosts@v1
    argument: node1

  - name: hosts_node2
    gatherer: hosts@v1
    argument: node2

  - name: hosts_all
    gatherer: hosts@v1
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

<span id="ini_filesv1"></span>

### ini_files@v1

**Argument required**: yes.

This gatherer fetches the content from a configuration file in INI format. The configuration file is specified as argument, chosen from a list of allowed files.
Currently whitelisted files are:

- `global.ini`

Each fact request can return one or more item, one for each found file; multiple files can occur when the host has configured more than one SAP system. Each item then has a `sid` field with the system id and a `value` field with the actual content of the file.

Example arguments:

| Name         | Return value                                                                         |
| :----------- | :----------------------------------------------------------------------------------- |
| `global.ini` | Retrieved the content from `/usr/sap/<sid>>/SYS/global/hdb/custom/config/global.ini` |

```yaml
facts:
  - name: global_configuration
    gatherer: ini_files@v1
    argument: global.ini
```

Example output (in Rhai):

```ts
[
  #{
    "sid": "S01",
    "value": #{
      "communication": #{
        "internal_network": "10.23.1.128/26",
        "listeninterface": ".internal"
      },
      "internal_hostname_resolution": #{
        "10.23.1.132": "hana-s1-db1",
        "10.23.1.133": "hana-s1-db2",
        "10.23.1.134": "hana-s1-db3"
      }
    }
  }
]
```

<span id="mount_infov1"></span>

### mount_info@v1

**Argument required**: yes.

This gatherer allows accessing the OS file system mount points. It returns information about the mount point of a given path.
Besides of the mount information, if the mount is done in a local block device, it returns the UUID of the block (coming from the `blkid` command).
If the given path is not mounted, all the fields are returned with empty strings.

Example specification:

```yaml
facts:
  - name: not_mounted
    gatherer: mount_info@v1
    argument: /usr/sap

  - name: shared_nfs
    gatherer: mount_info@v1
    argument: /sapmnt

  - name: mounted_locally
    gatherer: mount_info@v1
    argument: /hana/data
```

Example output (in Rhai):

```ts
// not_mounted
#{
  "block_uuid": "",
  "fs_type": "",
  "mount_point": "",
  "options": "",
  "source": ""
}

// shared_nfs
#{
  "block_uuid": "",
  "fs_type": "nfs4",
  "mount_point": "/sapmnt",
  "options": "rw,relatime",
  "source": "10.1.1.10://sapmnt"
}

// mounted_locally
#{
  "block_uuid": "f45cf408-efgh-abcd-88ec-2f9269a12f07",
  "fs_type": "xfs",
  "mount_point": "/hana/data",
  "options": "rw,relatime",
  "source": "/dev/mapper/vg_hana-lv_hana_data"
}
```

<span id="os-releasev1"></span>

### os-release@v1

**Argument required**: no.

This gatherer allows access to the distribution details in `/etc/os-release`. This file contains operating system identification data, such as the
vendor of the distribution, the name of the distribution, the version and the ID of the distribution, as well as many other details.

Example specification:

```yaml
facts:
  - name: os_release
    gatherer: os-release@v1
```

Example output (in Rhai):

```ts
// output from openSUSE Leap 15.2
#{
  "ANSI_COLOR": "0;32",
  "BUG_REPORT_URL": "https://bugs.opensuse.org",
  "CPE_NAME": "cpe:/o:opensuse:leap:15.2",
  "HOME_URL": "https://www.opensuse.org/",
  "ID": "opensuse-leap",
  "ID_LIKE": "suse opensuse",
  "NAME": "openSUSE Leap",
  "PRETTY_NAME": "openSUSE Leap 15.2",
  "VERSION": "15.2",
  "VERSION_ID": "15.2"
}
```

<span id="package_versionv1"></span>

### package_version@v1

**Argument required**: yes.

This gatherer supports two usecases:

- get information about the installed versions of the specified package.
- compare a given version string against the latest installed version of a given package.

In the first usecase a list of objects is returned, where each object carries relevant information about an installed version of a package.

> Note:
>
> - a list of one element is often expected since usually the installed version would be only one
> - detected installed versions list is ordered by descending installation time: **latest installed versions come first**
> - operating on the latest installed version requires accessing the first element in the list via `package_fact_name[0]` or `package_fact_name.first()`

In the second usecase, the return value is as follows (see additional details [here](https://fedoraproject.org/wiki/Archive:Tools/RPM/VersionComparison#The_rpmvercmp_algorithm)):

- A value of `0` if the provided version string matches the installed package version for the requested package.
- A value of `-1` if the provided version string is older that what's currently installed.
- A value of `1` if the provided version string is newer than what's currently installed.

> The latest detected installed version is used for comparison

Naming the facts / expectations accordingly is specially important here to avoid confusion.

- We suggest using a `compare_` prefix for package version comparisons and `package_` to retrieve
  a package version

Additionally, when using the version comparison, it increases readability to explicitly mention
the values to compare against:

```yaml
facts:
  - name: compare_package_corosync
    gatherer: package_version@v1
    argument: corosync,2.4.5

  - name: package_corosync
    gatherer: package_version@v1
    argument: corosync

  - name: package_sbd
    gatherer: package_version@v1
    argument: sbd

values:
  - name: greater_than_installed
    default: 1
  - name: lesser_than_installed
    default: -1
  - name: same_as_installed
    default: 0
  - name: expected_corosync_version
    default: "2.4.5"

expectations:
  - name: compare_package_corosync
    expect: facts.compare_package_corosync == values.greater_than_installed

  - name: package_corosync_is_the_expected_one
    expect: facts.package_corosync.first().version == values.expected_corosync_version

  - name: sbd_version_same_on_all_hosts
    expect_same: facts.package_sbd.first().version
```

Example arguments:

| Name                 | Return value                                                                  |
| :------------------- | :---------------------------------------------------------------------------- |
| `package_name`       | a list containing information about the installed versions of the rpm package |
| `package_name,2.4.5` | an integer with a value of `-1`, `0` or `1` (see above)                       |

Example specification:

```yaml
facts:
  - name: package_corosync
    gatherer: package_version@v1
    argument: corosync

  - name: package_pacemaker
    gatherer: package_version@v1
    argument: pacemaker

  - name: multiple_sbd_versions_installed
    gatherer: package_version@v1
    argument: sbd

  - name: compare_package_corosync
    gatherer: package_version@v1
    argument: corosync,2.4.5

  ...
```

Example output (in Rhai):

```ts
// package_corosync
[
  #{
    "version": "2.4.5"
  }
]

// package_pacemaker
[
  #{
    "version": "2.0.4+20200616.2deceaa3a"
  }
]

// multiple_sbd_versions_installed
[
  #{
    "version": "1.5.1" // latest installed version, not necessarily the newest one
  },
  #{
    "version": "1.5.2"
  }
]

// compare_package_corosync
0
```

<span id="passwdv1"></span>

### passwd@v1

**Argument required**: no.

This gatherer allows access to the /etc/passwd file, returning all entries available at the file.

Example specification:

```yaml
facts:
  - name: passwd
    gatherer: passwd@v1
```

Example output (in Rhai):

```ts
[
    #{
        "description": "bin",
        "gid": 1,
        "home": "/bin",
        "shell": "/sbin/nologin",
        "uid": 1,
        "user": "bin"
    },
    #{
        "description": "Chrony Daemon",
        "gid": 475,
        "home": "/var/lib/chrony",
        "shell": "/bin/false",
        "uid": 474,
        "user": "chrony"
    },
    #{
        "description": "Daemon",
        "gid": 2,
        "home": "/sbin",
        "shell": "/sbin/nologin",
        "uid": 2,
        "user": "daemon"
    },
  ...
];
```

<span id="productsv1"></span>

### products@v1

**Argument required**: no.

This gatherer allows access to the /etc/products.d/ folder files content. It returns the file contents mapped using the file name.
The XML content is returned as-is, just converted to a rhai object.

Example specification:

```yaml
facts:
  - name: products
    gatherer: products@v1
```

Example output (in Rhai):

```ts
#{
  "Leap.prod": #{
    "product": #{
      "arch": "x86_64",
      ...
      "codestream": #{
        "endoflife": "2024-11-30",
        "name": "openSUSE Leap 15"
      },
      ...
      "name": "Leap",
      "productline": "Leap",
      ...
      "vendor": "openSUSE",
      "version": "15.3"
    }
  },
  "baseproduct": #{
    "product": #{
      "arch": "x86_64",
      ...
      "codestream": #{
        "endoflife": "2024-11-30",
        "name": "openSUSE Leap 15"
      },
     ...
      "name": "Leap",
      "productline": "Leap",
      ...
      "vendor": "openSUSE",
      "version": "15.3"
    }
  }
}
```

<span id="sap_profilesv1"></span>

### sap_profiles@v1

**Argument required**: no.

This gatherer allows access to the latest SAP profile files content stored in `/sapmnt/<SID>/profile`.
The "latest" profile means that backed up files like `DEFAULT.1.PFL` or `some_profile.1` are excluded.
It returns the profile files and content grouped by SID in a key\value way.

Example specification:

```yaml
facts:
  - name: sap_profiles
    gatherer: sap_profiles@v1
```

Example output (in Rhai):

```ts
#{
  "NWP": #{
    "profiles": [
      #{
        "content": #{
          "SAPDBHOST": "10.80.1.13",
          "SAPGLOBALHOST": "sapnwpas",
          "SAPSYSTEMNAME": "NWP",
          ...
        },
        "name": "DEFAULT.PFL",
        "path": "/sapmnt/NWP/profile/DEFAULT.PFL"
      },
      #{
        "content": #{
          "DIR_CT_RUN": "$(DIR_EXE_ROOT)$(DIR_SEP)$(OS_UNICODE)$(DIR_SEP)linuxx86_64",
          "DIR_EXECUTABLE": "$(DIR_INSTANCE)/exe",
          "DIR_PROFILE": "$(DIR_INSTALL)$(DIR_SEP)profile",
          ...
        },
        "name": "NWP_ASCS00_sapnwpas",
        "path": "/sapmnt/NWP/profile/NWP_ASCS00_sapnwpas"
      },
      ...
    ]
  },
  "NWD": #{
    "profiles": [
      #{
        "content": #{
          "SAPDBHOST": "10.85.1.13",
          "SAPGLOBALHOST": "sapnwdas",
          "SAPSYSTEMNAME": "NWD",
          ...
        },
        "name": "DEFAULT.PFL",
        "path": "/sapmnt/NWD/profile/DEFAULT.PFL"
      },
      ...
    ]
  }
}
```

<span id="sapservicesv1"></span>

### sapservices@v1

**Argument required**: no.

This gatherer allows access to the SAP services file content stored in `/usr/sap/sapservices`.
Each entry in the file is returned as a map, containing the SID, the instance number, the raw line content of the entry and
the kind of system used for startup, `systemctl` or `sapstartsrv`.

Example specification:

```yaml
facts:
  - name: sapservices
    gatherer: sapservices@v1
```

Example output (in Rhai):

```ts
[
  #{
    "sid": "HS1",
    "kind": "sapstartsrv",
    "content": "LD_LIBRARY_PATH=/usr/sap/HS1/HDB11/exe:$LD_LIBRARY_PATH;export LD_LIBRARY_PATH;/usr/sap/HS1/HDB11/exe/sapstartsrv pf=/usr/sap/HS1/SYS/profile/HS1_HDB11_s41db -D -u hs1adm",
    "instance_nr": "11"
  },
  #{
    "sid": "S41",
    "kind": "systemctl",
    "content": "systemctl --no-ask-password start SAPS41_40",
    "instance_nr": "40"
  },
]
```

<span id="sapcontrolv1"></span>

### sapcontrol@v1

**Argument required**: yes.

This gatherer allows access to certain webmethods that `sapcontrol` implements. An argument is required to specify which webmethod should be called. The communication with `sapcontrol` is created opening a unix socket connection using the file `/tmp/.sapstream5xx13`. The [Sapcontrol Web Service Interface](https://www.sap.com/documents/2016/09/0a40e60d-8b7c-0010-82c7-eda71af511fa.html) documents the SOAP API interface, including all the possible values each of the fields could have, specifically helpful for enumerators like `dispstatus` in `GetProcessList` and `state/category` in `HACheckConfig` webmethod.

The return value is grouped by discovered SIDs, which include the list of command outputs for each instance in this system.

Supported webmethods:

- `GetProcessList`
- `GetSystemInstanceList`
- `GetVersionInfo`
- `HACheckConfig`
- `HAGetFailoverConfig`

Example specification:

```yaml
facts:
  - name: processes
    gatherer: sapcontrol@v1
    argument: GetProcessList

  - name: instances
    gatherer: sapcontrol@v1
    argument: GetSystemInstanceList
```

Example output (in Rhai):

```ts
// GetProcessList
#{
  "NWP": [
    #{
      "instance_nr": "10",
      "name": "ERS10",
      "output": [
        #{
          "description": "EnqueueReplicator",
          "dispstatus": "SAPControl-GREEN",
          "elapsedtime": "266:08:15",
          "name": "enrepserver",
          "pid": 7221,
          "starttime": "2023 09 29 09:41:41",
          "textstatus": "Running"
        }
      ]
    }
  ]
}

// GetSystemInstanceList
#{
  "NWP": [
    #{
      "instance_nr": "10",
      "name": "ERS10",
      "output": [
        #{
          "dispstatus": "SAPControl-GREEN",
          "features": "MESSAGESERVER|ENQUE",
          "hostname": "sapnwpas",
          "http_port": 50013,
          "https_port": 50014,
          "instance_nr": 0,
          "start_priority": "1"
        },
        #{
          "dispstatus": "SAPControl-GREEN",
          "features": "ENQREP",
          "hostname": "sapnwper",
          "http_port": 51013,
          "https_port": 51014,
          "instance_nr": 10,
          "start_priority": "0.5"
        },
        ...
      ]
    }
  ]
}

// GetVersionInfo
#{
  "NWP": [
    #{
      "instance_nr": "10",
      "name": "ERS10",
      "output": [
        #{
          "architecture": "linuxx86_64",
          "build": "optU (Oct 16 2021, 00:03:15)",
          "changelist": "2094654",
          "filename": "/usr/sap/NWP/ERS10/exe/sapstartsrv",
          "patch": "900",
          "rks_compatibility_level": "1",
          "sap_kernel": "753",
          "time": "2021 10 15 22:14:31"
        },
        #{
          "architecture": "linuxx86_64",
          "build": "optU (Oct 16 2021, 00:03:15)",
          "changelist": "2094654",
          "filename": "/usr/sap/NWP/ERS10/exe/gwrd",
          "patch": "900",
          "rks_compatibility_level": "1",
          "sap_kernel": "753",
          "time": "2021 10 15 22:04:14"
        },
        ...
      ]
    }
  ]
}

// HACheckConfig
#{
  "NWP": [
    #{
      "instance_nr": "10",
      "name": "ERS10",
      "output": [
        #{
          "category": "SAPControl-SAP-CONFIGURATION",
          "comment": "2 ABAP instances detected",
          "description": "Redundant ABAP instance configuration",
          "state": "SAPControl-HA-SUCCESS"
        },
        #{
          "category": "SAPControl-SAP-CONFIGURATION",
          "comment": "0 Java instances detected",
          "description": "Redundant Java instance configuration",
          "state": "SAPControl-HA-SUCCESS"
        },
        ...
      ]
    }
  ]
}

//HAGetFailoverConfig
#{
  "NWP": [
    #{
      "instance_nr": "10",
      "name": "ERS10",
      "output": #{
        "ha_active": false,
        "ha_active_nodes": "",
        "ha_documentation": "",
        "ha_nodes": [],
        "ha_product_version": "",
        "ha_sap_interface_version": ""
      }
    }
  ]
}

```

<span id="saphostctrlv1"></span>

### saphostctrl@v1

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
    gatherer: saphostctrl@v1
    argument: Ping

  - name: list_instances
    gatherer: saphostctrl@v1
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

<span id="sapinstance_hostname_resolverv1"></span>

### sapinstance_hostname_resolver@v1

**Argument required**: no.

This gatherer uses the filesystem to search for SAP systems using the discovered profile file names to get the virtual hostnames associated to each
instance of the sap system. It then attempts to resolve those hostnames to confirm that they are resolvable and afterwards a ping is attempted
to those hostnames. Keep in mind that ping could be disallowed through firewall rules so it should only be used for networks in which we know this is
not true.

Example specification:

```yaml
facts:
  - name: resolvability_check
    gatherer: sapinstance_hostname_resolver@v1
```

Example output (in Rhai):

```ts
// 2 resolvable & 1 non-resolvable hosts
#{
  "NWP": [
    #{
      "addresses": [
        "2.1.1.82"
      ],
      "hostname": "sapnwpas",
      "instance_name": "ASCS00",
      "reachability": true
    }
  ],
  "QAS": [
    #{
      "addresses": [
        "1.1.1.82"
      ],
      "hostname": "sapqasas",
      "instance_name": "ASCS00",
      "reachability": true
    },
    #{
      "addresses": (),
      "hostname": "sapwaser",
      "instance_name": "ERS00",
      "reachability": false
    }
  ]
}
```

<span id="saptunev1"></span>

### saptune@v1

**Argument required**: yes.

This gatherer allows access to certain commands that `saptune` implements. An argument is required to specify
which argument should be used when calling `saptune`.

> Note: the gatherer will return the same JSON objects returned by saptune. The only transformation it applies is the snake casing of the keys.

Supported arguments:

- `status` (maps to `saptune --format json status --non-compliance-check`)
- `solution-verify` (maps to `saptune --format json solution verify`)
- `solution-list` (maps to `saptune --format json solution list`)
- `note-verify` (maps to `saptune --format json note verify`)
- `note-list` (maps to `saptune --format json note list`)

A `status` call with a successful return should look like this:

Example specification:

```yaml
facts:
  - name: status
    gatherer: saptune@v1
    argument: status
```

Example output (in Rhai):

```ts
// status
#{
  "$schema": "file:///usr/share/saptune/schemas/1.0/saptune_status.schema.json",
  "argv": "saptune --format json status",
  "command": "status",
  "exit_code": 1,
  "messages": [
    #{
      "message": "actions.go:85: ATTENTION: You are running a test version",
      "priority": "NOTICE"
    }
  ],
  "pid": 6593,
  "publish_time": "2023-09-15 15:15:14.599",
  "result": #{
    "configured_version": "3",
    "notes_applied": [
      "1410736"
    ],
    "notes_applied_by_solution": [],
    "notes_enabled": [
      "1410736"
    ],
    "notes_enabled_additionally": [
      "1410736"
    ],
    "notes_enabled_by_solution": [],
    "package_version": "3.1.0",
    "remember_message": "This is a reminder",
    "services": #{
      "sapconf": [],
      "saptune": [
        "disabled",
        "inactive"
      ],
      "tuned": []
    },
    "solution_applied": [],
    "solution_enabled": [],
    "staging": #{
      "notes_staged": [],
      "solutions_staged": [],
      "staging_enabled": false
    },
    "systemd_system_state": "degraded",
    "tuning_state": "compliant",
    "virtualization": "kvm"
  }
}
```

<span id="sbd_configv1"></span>

### sbd_config@v1

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
    gatherer: sbd_config@v1
    argument: SBD_PACEMAKER

  - name: sbd_startmode
    gatherer: sbd_config@v1
    argument: SBD_STARTMODE

  - name: sbd_device
    gatherer: sbd_config@v1
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

<span id="sbd_dumpv1"></span>

### sbd_dump@v1

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
    gatherer: sbd_dump@v1
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

<span id="sudoersv1"></span>

### sudoers@v1

**Argument required**: no.

This gatherer fetches the sudoer information about a user. The output is a list of objects representing the sudoer rules with the following fields:

- `user`: The name of the user to whom the rule applies;
- `command`: The command a sudoer rule has been specified for;
- `run_as_user`: The user privileges under which the command will be executed;
- `run_as_group`: The group privileges under which the command will be executed.;
- `no_password`: Whether the `NOPASSWD` tag is set for the rule.

The gatherer operates in two modes:

- _user discovery mode_: no argument is specified, thus the gatherer fetches results for all the configured users for the SAP systems on the host;
- _explicit user mode_: the target user is specified as the gatherer argument, regardless if it's a SAP-configured user.

Example arguments:

| Name     | Return value                                                                        |
| :------- | :---------------------------------------------------------------------------------- |
| _empty_  | All sudoer rules for all users configured for the installed SAP systems on the host |
| `prdadm` | All sudoer rules for the `prdadm` user                                              |

Example output (in Rhai):

```ts
[
  #{
    "command": "ALL",
    "no_password": false,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  },
  #{
    "command": "/usr/sbin/crm_attribute -n hana_prd_site_srHook_Site1 -v SOK -t crm_config -s SAPHanaSR",
    "no_password": true,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  },
  #{
    "command": "/usr/sbin/crm_attribute -n hana_prd_site_srHook_Site1 -v SFAIL -t crm_config -s SAPHanaSR",
    "no_password": true,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  },
  #{
    "command": "/usr/sbin/crm_attribute -n hana_prd_site_srHook_Site2 -v SOK -t crm_config -s SAPHanaSR",
    "no_password": true,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  },
  #{
    "command": "/usr/sbin/crm_attribute -n hana_prd_site_srHook_Site2 -v SFAIL -t crm_config -s SAPHanaSR",
    "no_password": true,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  },
  #{
    "command": "/usr/sbin/SAPHanaSR-hookHelper --case checkTakeover --sid\\=prd",
    "no_password": true,
    "run_as_group": "",
    "run_as_user": "ALL",
    "user": "prdadm"
  }
]
```

<span id="sysctlv1"></span>

### sysctl@v1

**Argument required**: yes.

Gather sysctl output. It takes a sysctl key as argument and it returns the value of the requested key or a map if a partial key is provided.

Example arguments:

| Name            | Return value                                          |
| :-------------- | :---------------------------------------------------- |
| `vm.swappiness` | corresponding value returned by sysctl                |
| `debug`         | a map containing all the keys starting with `debug.`` |

```yaml
facts:
  - name: vm_swappiness
    gatherer: sysctl@v1
    argument: vm.swappiness

  - name: debug
    gatherer: sysctl
    argument: debug
```

Example output (in Rhai):

```ts
// vm_swapiness
60;

// debug
#{
  "exception-trace": 1,
  "kprobes-optimization": 1
};
```

<span id="systemdv1"></span>

### systemd@v1

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
    gatherer: systemd@v1
    argument: sbd

  - name: corosync_state
    gatherer: systemd@v1
    argument: corosync
```

Example output (in Rhai):

```ts
// sbd_state
"active";

// corosync_state
"inactive";
```

<span id="systemdv2"></span>

### systemd@v2

**Argument required**: yes.

Gather systemd units information. It returns an object with multiple fields about the systemd unit.

The provided unit name must include the extension, such as `.service` or `.mount`.

Only a subset of properties are returned. Additional information about these is available in
the [systemd](https://www.man7.org/linux/man-pages/man5/org.freedesktop.systemd1.5.html#UNIT_OBJECTS) man pages,
with some detailed description in the `Properties` sub-chapter.

Example arguments:

| Name                   | Return value             |
| :--------------------- | :----------------------- |
| `trento-agent.service` | systemd unit information |

```yaml
facts:
  - name: corosync
    gatherer: systemd@v2
    argument: corosync.service

  - name: not_found
    gatherer: systemd@v2
    argument: unknown.service
```

Example output (in Rhai):

```ts
// corosync
#{
  "active_state": "inactive",
  "description": "Corosync Cluster Engine",
  "id": "corosync.service",
  "load_state": "loaded",
  "need_daemon_reload": false,
  "unit_file_preset": "disabled",
  "unit_file_state": "disabled"
}

// not_found
#{
  "active_state": "inactive",
  "description": "unknown.service",
  "id": "unknown.service",
  "load_state": "not-found",
  "need_daemon_reload": false,
  "unit_file_preset": "",
  "unit_file_state": ""
}

```

<span id="verify_passwordv1"></span>

### verify_password@v1

**Argument required**: yes.

This gatherer determines whether a given user has its password still set to an unsafe password.
It returns `true` if the password matches a password in the list of unsafe passwords, `false` otherwise.

Specification examples:

```yaml
facts:
  - name: hacluster_has_default_password
    gatherer: verify_password@v1
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

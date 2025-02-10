# Checks Specification

A language allowing to declare best practices to be adhered on target SAP Infrastructures.

## Introduction

The need this Specification aims to fulfill is to provide users a simple way to declare what we (the Trento Team) often refer to as "Checks".

Checks are, in Trento's domain, the crystallization of SUSE's best practices when it comes to SAP workloads in a form that both a user ([Spec](#anatomy-of-a-check)) and a machine ([Execution](#checks-execution)) can read.

[^1]: The Trento Team from now on.

## Checks Execution

_Checks Execution_ is the process that determines whether the best practices defined in the [Checks Specifications](#anatomy-of-a-check) are being followed on a target infrastructure.

> [Requesting an Execution](#requesting-an-execution) -> [Facts Gathering](#facts-gathering) -> [Expectation Evaluation](#expectation-evaluation)

### Requesting an Execution

An Execution can be requested to start by providing Wanda the following information:

- an execution identifier
- an execution Group identifier
- the Checks Selection for the targets (a list of checks to be executed on the targets)

When the Execution starts running, its current state is stored in the Database and the targets are notified - via the message broker - about Facts to be gathered.

Then the _Execution_ waits for the [Facts Gathering](#facts-gathering) to complete.

### Facts Gathering

After an _Execution Request_ the targets are notified about the facts they need to [gather](./gatherers.md).

Whenever a target has gathered all the needed facts for an _Execution_, it notifies Wanda - via the message broker - about the _Gathered Facts_.

### Expectation Evaluation

_Expectation Evaluation_ is the process of [evaluating](#expression-language) the [Expectations](#expectations)
using the received _Gathered Facts_ to obtain the result of a check.

This will only happen once _Gathered Facts_ are received **from all the targets**.

After the result has been determined, the currently `running` Execution transitions to `completed` and its new state is tracked on the Database.

At this point the Execution is considered **Completed** and interested parties are notified about the Execution Completion.

### Checks Results

Once an execution is completed, a checks result should give feedback on what aspects of a target infrastructure adhere to the best practices and which don't.

Possible results:

- `passing`, everything ok
- `warning`, best practice not followed, should fix
- `critical`, best practice not followed, must fix

See also [Check Severity](#severity).

## Anatomy of a Check

A Check declaration comes in the form of a `yaml` file and all the Checks together build up the **Checks Catalog**

Here's an example:

```yaml
id: "156F64"
name: Corosync `token` timeout
group: Corosync
description: Corosync `token` timeout is set to the correct value
remediation: |
  ## Abstract
  The value of the Corosync `token` timeout is not set as recommended.
  ## Remediation
  Adjust the corosync `token` timeout as recommended...

severity: warning

metadata:
  target_type: cluster
  cluster_type: hana_scale_up
  hana_scenario: performance_optimized
  provider: [azure, nutanix, kvm, vmware]

facts:
  - name: corosync_token_timeout
    gatherer: corosync.conf
    argument: totem.token

customization_disabled: true

values:
  - name: expected_token_timeout
    customization_disabled: true
    default: 5000
    conditions:
      - value: 30000
        when: env.provider == "azure" || env.provider == "aws"
      - value: 20000
        when: env.provider == "gcp"

expectations:
  - name: token_timeout
    expect: facts.corosync_token_timeout == values.expected_token_timeout
```

### Filename Convention

**Note** that a Check's filename **MUST** be in the form `<check_id>.yaml` (ie: `156F64.yaml`)

### Structure

Following are listed the top level properties of a Check definition yaml.

| Key                      | Required/Not Required | Details                            |
| ------------------------ | --------------------- | ---------------------------------- |
| `id`                     | required              | [see more](#id)                    |
| `name`                   | required              | [see more](#name)                  |
| `group`                  | required              | [see more](#group)                 |
| `description`            | required              | [see more](#description)           |
| `remediation`            | required              | [see more](#remediation)           |
| `severity`               | not required          | [see more](#severity)              |
| `metadata`               | not required          | [see more](#metadata)              |
| `facts`                  | required              | [see more](#facts)                 |
| `customization_disabled` | not required          | [see more](#disable-customization) |
| `values`                 | not required          | [see more](#values)                |
| `expectations`           | required              | [see more](#expectations)          |

---

#### id

Uniquely identifies a Check in the Catalog. The value must be a hexadecimal number formatted as string using quotes.

ie:

```yaml
id: "156F64"
id: "845CC9"
id: "B089BE"
```

#### name

A, preferably one-line, string representing the name for the Check being declared.

ie:

```yaml
name: Corosync `token` timeout
name: Corosync `consensus` timeout
name: SBD Startmode
```

#### group

A, preferably one-line, string representing the group where the Check being declared belongs.

Example:

```yaml
group: Corosync
group: Pacemaker
group: SBD
```

#### description

A text providing a description for the Check being declared.

can be a one-liner

```yaml
description: Some plain description
```

can be a multiline text

```yaml
description: |
  Some plain multiline
  description that carries a lot
  of information
```

format is **markdown**

```yaml
description: |
  A `description` is a **markdown**
```

#### remediation

A text providing an comprehensive description about the remediation to apply for the Check being declared.

It has the same properties of the `description`

- can be a one-liner (it usually is not)
- can be a multiline (it usually is)
- format is **markdown**

Example:

```yaml
remediation: |
  ## Abstract
  The value of the Corosync `token` timeout is not set as recommended.
  ## Remediation
  Adjust the corosync `token` timeout as recommended on the best 
  ...
  2. Reload the corosync configuration:
  ...
```

#### severity

A string determining the severity of the Check being declared, in case the check is not passing, so that the appropriate result is reported.

Allowed values: `warning`, `critical`

**Default:** if no severity is provided, the system would default to `critical`

Example:

Reports a `warning` When the Check expectations do not pass

```yaml
severity: warning
```

Reports a `critical` When the Check expectations do not pass

```yaml
severity: critical
```

#### metadata

A key-value map that enriches the Check being declared by providing extra information about when to consider it as applicable given a specific [env](#env)

- keys must be non empty strings (`foo`, `bar`, `foo_bar`, `qux1`)
- values can be any of the following types `string`, `number`, `boolean`, `string[]` (list of strings)
- `target_type` is a **required** key of the `metadata` map. It's value is  a `string`.

Example:

```yaml
metadata:
  target_type: example_target
  foo: bar
  bar: 42
  baz: true
  qux: [foo, bar, baz]
```

Metadata is used when:
- querying checks from the catalog
- loading relevant checks for an execution (when requesting an execution to start either via the rest API or via a message through the message broker)

#### How does the matching work?

For each of the metadata key-value the system checks whether a matching key is present in the current context (catalog or execution env) and if so, whether the value matches the one declared in the check.

For a check to be considered applicable all the metadata key-value pairs should match something in the env.

Any extra key in the env not having a corresponding one in the check metadata is ignored.

Notes:
- a string in the env (ie `env.qux` being `baz`) can match either a plain string as in `qux: baz` and a string contained in a list as in `qux: [foo, bar, baz]`
- an empty env always matches any metadata
- an empty metadata always matches any env

**Matching example**
```ts
let env = #{
  foo: "bar",
  qux: "baz"
}
```

```yaml
metadata:
  foo: bar
  bar: 42
  baz: true
  qux: baz
```

**Not matching example**

```ts
let env = #{
  foo: "bar",
  qux: "baz",
  baz: false
}
```

```yaml
metadata:
  foo: bar
  bar: 42
  baz: true
  qux: [foo, bar, baz]
```

#### Facts, Values, Expectations

See main sections [Facts](#facts), [Values](#values), [Expectations](#expectations)

## Facts

Facts are the core data on which the engine evaluates the state of the target infrastructure.
Examples include (but are not limited to) installed packages, cluster state, and configuration files content.

The process of determining the value of a declared fact during Check execution is referred to as _Facts Gathering_ and it is the responsibility of the [_Gatherers_](./gatherers.md).
Gatherers could be seen as functions that have a name and accept argument(s).

That said, a fact declaration contains:

- the fact name
- the gatherer used to retrieve the fact
- the argument(s) to be provided to the gatherer

**Note:**

- many facts can be declared
- all the declared facts would be registered in the [`facts`](#facts-1) namespaced evaluation scope.

```yaml
facts:
  - name: <fact_name>
    gatherer: <gatherer_name>
    argument: <gatherer_argument>

  - name: <another_fact_name>
    gatherer: <another_gatherer_name>
    argument: <another_gatherer_argument>
```

The following example declares a **fact** named `corosync_token_timeout`, retrievable via the built-in `corosync.conf` **gatherer** to which will be provided the **argument** `totem.token`

```yaml
facts:
  - name: corosync_token_timeout
    gatherer: corosync.conf
    argument: totem.token

  # other facts maybe
```

Finally, gathered facts, are used in Check's [Expectations](#expectations) to determine whether expected conditions are met for the best practice to be adhered.

## Disable Customization

Users can modify a check's [expected values](#values) to accommodate specific system and environmental configurations.

By default, built-in checks are **customizable**. The `customization_disabled` flag provides a way to **disable** customizability when needed.  

To disable customization for a check the following bit of specification is required:

```yaml
customization_disabled: true
```

Opting out from customizability at the root of a check's specification makes all the values of the given check not customizable.

### Notes:  
- Setting `customization_disabled: false` has no real effect as by default a check is customizable
- The `customization_disabled` flag can be also applied to [specific values](#customizable-values)

## Values

Values are named variables that may evaluate differently based on the execution context and are used with Facts for _Contextual_ [Expectations](#expectations) Evaluation.

> When contextual expectations is not needed, there's the following options available:
>
> - use [**hardcoded**](#hardcoded-values) values
> - define `values` as [**constants**](#constant-values)
>
> Scenario:
>
> No matter what the context is, the fact `awesome_fact` MUST always be `wanda`

### Hardcoded Values

Direct usage of a simple hardcoded value

```yaml
expectations:
  - name: awesome_expectation
    expect: facts.awesome_fact == "wanda"
```

### Constant Values

Define a Value with only the `default` specified (**omitting** `conditions`) for **constants** regardless of the context.

```yaml
values:
  - name: awesome_constant_value
    default: "wanda"

expectations:
  - name: awesome_expectation
    expect: facts.awesome_fact == values.awesome_constant_value
```

### Contextual Values

This is needed because the same check might expect facts to be treated differently based on the context.

> Let's clarify with an example:
>
> A Check might define a fact named `awesome_fact` which is expected to be different given the _color_ of the execution.
>
> - it has to be `cat` when the `color` in the execution context is `red`
> - it has to be `dog` when the `color` in the execution context is `blue`
> - it has to be `rabbit` in all other cases, regardless of the execution context
>
> so we define a named variable `awesome_expectation` that resolves to `cat|dog|rabbit` when proper conditions are met
>
> allowing us to have an expectation like this
>
> `expect: facts.awesome_fact == values.awesome_expectation`

A Value declaration contains:

- the value name
- the default value
- a list of conditions that determine the value given the context (optional, see [constant values](#constant-values))

```yaml
values:
  - name: <value_name>
    default: <default_value>
    conditions:
      - value: <value_on_condition_a>
        when: <expression_a>
      - value: <value_on_condition_b>
        when: <expression_b>
```

It could read as:

the value named `<value_name>` resolves to

- `<value_on_condition_a>` when `<expression_a>` is true
- `<value_on_condition_b>` when `<expression_b>` is true
- `<default_value>` in all other cases

Example:

> Check `156F64 Corosync token timeout is set to expected value` defines a fact `corosync_token_timeout` which is expected to be different given the platform (aws/azure/gcp), so we define a named variable `expected_token_timeout` resolving to the appropriate value.
>
> `expected_token_timeout` resolves to:
>
> - `30000` when `azure`/`aws` are detected
> - `20000` on `gcp`
> - `5000` in all other cases (ie: bare metal, VMs...)

```yaml
values:
  - name: expected_token_timeout
    default: 5000
    conditions:
      - value: 30000
        when: env.provider == "azure" || env.provider == "aws"
      - value: 20000
        when: env.provider == "gcp"

expectations:
  - name: corosync_token_timeout_is_correct
    expect: facts.corosync_token_timeout == values.expected_token_timeout
```

Note that `conditions` is a cascading chain of contextual inspection to determine which is the resolved value.

- there may be many conditions
- first condition that passes determines the value, following are not evaluated
- `when` entry [Expression](#expression-language) has [access](#evaluation-scope) to gathered [facts](#facts-1) and [env](#env) evaluation scopes

All the _resolved_ declared values would be registered in the [`values`](#values-1) namespaced evaluation scope.

### Customizable Values

A check's [expected values](#values) are customizable by default, and to provide finer control to the global-level [customizability opt-out](#disable-customization) it is possible to opt-out customizability on a per-value basis.

```yaml
values:
  - name: non_customizable_check_value
    customization_disabled: true
    default: 5000
```

Setting **customization_disabled**: `false` for a specific value prevents the modification of the default value.

## Expectations

Expectations are assertions on the state of a target infrastructure for a given scenario. By using fact and values they are able to determine if a check passes or not.

An Expectation declaration contains:

- the expectation name
- the expectation expression itself with [access](#evaluation-scope) to gathered [facts](#facts-1) and [resolved values](#values-1)
- an optional [failure message](#failure_message)
- an optional [warning message](#warning_message), only available in [expect_enum](#expect_enum) expectations

```yaml
expectations:
  - name: <expectation_name>
    expect: <expectation_expression>

  - name: <another_expectation_name>
    expect: <another_expectation_expression>
    failure_message: <something_went_wrong>

  - name: <yet_another_expectation_name>
    expect_same: <yet_another_expectation_expression>
```

Extra considerations:

- there can be many expectations for a single Check
- an expectation can be one of three types: [`expect`](#expect), [`expect_same`](#expect_same) or [`expect_enum`](#expect_enum)
- a Check passes when all the expectations are satisfied

Example

```yaml
expectations:
  - name: token_timeout
    expect: facts.corosync_token_timeout == values.expected_token_timeout

  - name: awesome_expectation
    expect: facts.awesome_fact == values.awesome_expected_value
```

In the previous example a Checks passes (is successful) if all expectations are met, meaning that

```
facts.corosync_token_timeout == values.expected_token_timeout
AND
facts.awesome_fact == values.awesome_expected_value
```

### expect

This type of expectation is satisfied when, after facts gathering, the expression is `true` for all the targets involved in the current execution.

> Execution Scenario:
>
> - 2 targets [`A`, `B`]
> - selected Checks [`corosync_check`]
> - some environment (context)
>
> ```yaml
> facts:
>   - name: corosync_token_timeout
>     gatherer: corosync.conf
>     argument: totem.token
>
> values: ...
>
> expectations:
>   - name: corosync_token_timeout_is_correct
>     expect: facts.corosync_token_timeout == values.expected_token_timeout
> ```

Considering the previous scenario what happens is that:

- the fact `corosync_token_timeout` is gathered on all targets (`A` and `B` in this case)
- the expectation expression gets executed against the `corosync_token_timeout` fact gathered on every targets.
  - `targetA.corosync_token_timeout == values.expected_token_timeout`
  - `targetB.corosync_token_timeout == values.expected_token_timeout`
- every evaluation has to be `true`

### expect_same

This type of expectation is satisfied when, after facts gathering, the expression's return value is the same for all the targets involved in the current execution, regardless of the value itself.

> Execution Scenario:
>
> - 2 targets [`A`, `B`, `C`]
> - selected Checks [`some_check`]
> - some environment (context)
>
> ```yaml
> expectations:
>   - name: awesome_expectation
>     expect_same: facts.awesome_fact
> ```

Considering the previous scenario what happens is that:

- the fact `awesome_fact` is gathered on all targets (`A`, `B` and `C` in this case)
- the expectation expression gets executed for every target involved.
  - `targetA.facts.awesome_fact`
  - `targetB.facts.awesome_fact`
  - `targetC.facts.awesome_fact`
- the expressions results has to be the same for every target
  - `targetA.facts.awesome_fact == targetB.facts.awesome_fact == targetC.facts.awesome_fact`

> Example:
>
> RPM version must be the same on all the targets, regardless of what version it is
>
> ```yaml
> facts:
>   - name: installed_rpm_version
>     gatherer: package_version
>     argument: rpm
>
> expectations:
>   - name: installed_rpm_version_must_be_the_same_on_all_targets
>     expect_same: facts.installed_rpm_version
> ```

### expect_enum

This type of expectation is satisfied when, after facts gathering, the expression returns `passing`, `warning` or `critical`.
If no value is returned, the result defaults to `critical`.
The final result of this expectation is the aggretation of all the expectation evaluations gathered in all the involved targets.

The aggregation returns:
- `passing` if all the targets evaluation is `passing`
- `warning` if any of the evaluations is `warning` and there is not any `critical` result
- `critical` if any of the evaluations is `critical`

In this expectation type the [severity](#severity) field of the check is ignored.

> Execution Scenario:
>
> - 2 targets [`A`, `B`]
> - selected Checks [`sbd_check`]
> - some environment (context)
>
> ```yaml
> facts:
>   - name: sbd_devices
>     gatherer: sbd_config@v1
>     argument: SBD_DEVICE
>
> values: ...
>
> expectations:
>   - name: multiple_sbd_devices_configured
>     expect_enum: |
>       if facts.sbd_devices > values.passing_sbd_devices_count {
>        "passing"
>       } else if facts.sbd_devices == values.warning_sbd_devices_count {
>        "warning"
>       } else {
>        "critical"
>       }
>
>   - name: multiple_sbd_devices_configured_simple
>     expect_enum: |
>       if facts.sbd_devices > values.passing_sbd_devices_count {
>        "passing"
>       } else if facts.sbd_devices == values.warning_sbd_devices_count {
>        "warning"
>       }
>
> ```

Considering the previous scenario what happens is that:

- the fact `sbd_devices` is gathered on all targets (`A` and `B` in this case)
- the expectation expression gets executed against the `sbd_devices` fact gathered on every targets.
- the evaluated value is exactly what the expression returns. If there is not any returned value, `critical` is returned, as in the 2nd expectation example.
- the evaluation result of all the targets is aggregated to compose the final expectation result.

### failure_message

An optional failure message can be declared for every expectation.

In case of an `expect` one, the failure message can interpolate `facts` and `values` present in the check definition to provide more meaningful insights:

```yaml
expectations:
  - name: awesome_expectation
    expect: values.awesome_constant_value == facts.awesome_fact
    failure_message: The expectation did not match ${values.awesome_constant_value}
```

The outcome of the interpolation is available in `ExpectationEvaluation` inside the API response.

In case of an `expect_same` one, the failure message has to be a plain string:

```yaml
expectations:
  - name: awesome_expectation
    expect_same: facts.awesome_fact
    failure_message: Boom!
```

This plain string is available in `ExpectationResult` inside the API response.

### warning_message

An optional warning message that works exactly as the previous [failure message](#failure_message).
This field is only available for [expect_enum](#expect_enum) expectations, and it is interpolated when the expectation outcome is `warning`.

```yaml
expectations:
  - name: awesome_expectation
    expect_enum: |
      if values.passing_value == facts.awesome_fact {
        "passing"
      } else if values.warning_value == facts.awesome_fact {
        "warning"
      }
    failure_message: Critical!
    warning_message: Warning!
```

The outcome of the interpolation is available in `ExpectationEvaluation` inside the API response, in the `failure_message` field.

## Expression Language

Different parts of the Check declaration are places where an evaluation is needed.

> Determine to what a [value](#values) resolves during execution
>
> `when: <expression>` part of a Value's condition

```yaml
values:
  - name: expected_token_timeout
    default: 5000
    conditions:
      - value: 30000
        when: env.provider == "azure" || env.provider == "aws"
      - value: 20000
        when: env.provider == "gcp"
```

> Defining the [Expectation](#expectations) of a Check
>
> `expect|expect_same: <expression>`

```yaml
expectations:
  - name: token_timeout
    expect: facts.corosync_token_timeout == values.expected_token_timeout
```

See [reference for the Expression Language](./expression_language.md).

### Evaluation Scope

Every expression has access to an evaluation scope, allowing to access relevant piece of information to run the expression.

Scopes are namespaced and access to items in the scope is name based.

#### **env**

`env` is a map of information about the context of the running execution, it is set by the system on each execution/check compilation.

Examples of entries in the scope. What is actually available during the execution depends on the scenario. Find the updated values in the reference column link.

| name                    | Type                                                              | Reference                                                                                                                 | Applicable                                                 |
| ----------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `env.target_type`       | one of `cluster`, `host`                                          | No enum available                                                                                                         | All                                                        |
| `env.provider`          | one of `azure`, `aws`, `gcp`,`kvm`,`nutanix`, `vmware`, `unknown` | [Providers](https://github.com/trento-project/web/blob/main/lib/trento/enums/provider.ex)                                 | All                                                        |
| `env.cluster_type`      | one of `hana_scale_up`, `hana_scale_out`, `ascs_ers`, `unknown`   | [Cluster types](https://github.com/trento-project/web/blob/main/lib/trento/clusters/enums/cluster_type.ex)                | `target_type` is `cluster`                                 |
| `env.hana_scenario`     | one of `performance_optimized`, `cost_optimized`, `unknown`       | [Hana Scale Up Scenario](https://github.com/trento-project/web/blob/main/lib/trento/clusters/enums/hana_scenario.ex)      | `cluster_type` is `hana_scale_up`                          |
| `env.architecture_type` | one of `classic`, `angi`                                          | [Architecture types](https://github.com/trento-project/web/blob/main/lib/trento/clusters/enums/hana_architecture_type.ex) | `cluster_type` is one of `hana_scale_up`, `hana_scale_out` |
| `env.ensa_version`      | one of `ensa1`, `ensa2`, `mixed_versions`                         | [ENSA version](https://github.com/trento-project/web/blob/main/lib/trento/clusters/enums/cluster_ensa_version.ex)         | `cluster_type` is `ascs_ers`                               |
| `env.filesystem_type`   | one of `resource_managed`, `simple_mount`, `mixed_fs_types`       | [Filesystem type](https://github.com/trento-project/web/blob/main/lib/trento/clusters/enums/filesystem_type.ex)           | `cluster_type` is `ascs_ers`                               |

#### **facts**

`facts` is the map of the gathered facts, thus the scope varies based on which facts have been declared in the [relative section](#facts), and are accessible in other sections by fact name.

```yaml
facts:
  - name: an_interesting_fact
    gatherer: <some_gatherer>
    argument: <some_argument>

  - name: another_interesting_fact
    gatherer: <another_gatherer_name>
    argument: <another_gatherer_argument>
```

Available entries in scope, the value is what has been gathered on the targets
| name  
| -----------------------------
| `facts.an_interesting_fact`  
| `facts.another_interesting_fact`

#### **values**

`values` is the map of resolved variable names defined in the [relative section](#values)

```yaml
values:
  - name: expected_token_timeout
    default: 5000
    conditions:
      - value: 30000
        when: env.provider == "azure" || env.provider == "aws"
      - value: 20000
        when: env.provider == "gcp"

  - name: another_variable_value
    default: "blue"
    conditions:
      - value: "red"
        when: env.should_be_red == true
```

Available entries in scope
| name                            | Resolved to                                      |
| ------------------------------- | ------------------------------------------------ |
| `values.expected_token_timeout` | `5000`, `30000`, `20000` based on the conditions |
| `values.another_variable_value` | `blue`, `red` based on the conditions            |

## Best practices and conventions

To have a standardized format for writing checks, follow the next best practices and conventions as much as possible:

- The `id` field must be wrapped in double quotes to avoid any type of ambiguity, as this field must be of string format.
- The remaining `name`, `description`, `group`, and `remediation` fields must not be wrapped in quotes, as they are text-based values always.
- Take advantage of markdown tags in the `name`, `description`, and `remediation` fields to make the text easy and compelling to read.
- The `name` field of `facts`, `values`, and `expectations` must follow `camel_case` format.  
  For example:
  ```
  facts:
    - name: some_fact
  ...
  values:
    - name: expected_some_fact
  ...
  expectations:
    - name: some_expectation
  ...
  ```
- Use 2 spaces to indent multiline expectation expressions.
- Naming hardcoded values in the `values` section with the `default` field is encouraged instead of putting hardcoded values in the expectation expression itself. This gives some meaning to the expected value and improves potential interaction with the Wanda API.  
  So this:

  ```
  expectations:
    - name: some_expectation
      expect: facts.foo == 30
  ```

  would be:

  ```
  values:
    - name: expected_foo
      default: 30

  expectations:
    - name: some_expectation
      expect: facts.foo == values.expected_foo
  ```

- If the gathered fact is compared to a value, using `value` and `expected_value` names for facts and values respectively is recommended, as it improves the meaning of the comparison.  
  For example:
  ```
  facts:
    - name: some_fact
  ...
  values:
    - name: expected_some_fact
  ...
  ```
- Avoid adding prefixes such as `facts` or `values` to the entries of these sections, as they already use this as a namespace.
  For example, the next example should be avoided, as the `facts` prefix would be redundant in the expectation expression:
  ```
  facts:
    - name: facts_some_fact
  ```
- If the implemented expectation expression contains any kind of `&&` to combine multiple operations, consider adding them as individual expectations, as the final result is the combination of all of them.  
  So this:
  ```
  expectations:
    - name: some_expectation
      expect: facts.foo == values.expected_foo && facts.bar == values.expected_bar
  ```
  would be:
  ```
  expectations:
    - name: foo_expectation
      expect: facts.foo == values.expected_foo
    - name: bar_expectation
      expect: facts.bar == values.expected_bar
  ```
- Pipe the expression language functions vertically in order to provide a better visual output of the code.  
  So this:
  ```
  expectations:
    - name: some_expectation
      expect: facts.foo.find(|item| item.id == "super").properties.find(|prop| prop.name == "good").value
  ```
  would be:
  ```
  expectations:
    - name: some_expectation
      expect: |
        facts.foo
        .find(|item| item.id == "super").properties
        .find(|prop| prop.name == "good").value
  ```
  > Note: Keep in mind that some functions such as `sort` and `drain` run in-place modifications, so they cannot be piped.

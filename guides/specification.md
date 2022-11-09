# Trento Checks DSL Specification

A language allowing to declare best practices to be adhered on target SAP Infrastructures.

# Table of contents

- [Introduction](#introduction)
- [Anatomy of a Check](#anatomy-of-a-check)
    - [Structure](#structure)
    - [Metadata](#metadata)
      - [id](#id)
      - [name](#name)
      - [group](#group)
      - [description](#description)
      - [remediation](#remediation)
      - [severity](#severity)
    - [Filename Convention](#filename-convention)
- [Values](#values)
- [Facts](#facts)
- [Expectations](#expectations)
- [Expression Language](#expression-language)
    - [Evaluation Scope](#evaluation-scope)

## Introduction

The need this DSL aims to fulfill is to provide users a simple way to declare what we (the Trento Core Team) often refer to as "Checks". 

Checks are, in Trento's domain, the crystallization of SUSE's best practices when it comes to SAP workloads in a form that both a man and a machine can read.

We get several benefits from this approach:

- Humans can formalize best practices with no space for ambiguity;
- Machines can assert systems' state, automatically, with no space for ambiguity;
- The development of new best practices gets streamlined through a common definition that allows to firestart shared efforts.

## Anatomy of a Check

A Check declaration comes in the form of a `yaml` file and all the Checks together build up the **Checks Catalog**

Here's an example:
```yaml
id: 156F64
name: Corosync `token` timeout
group: Corosync
description: |
  Corosync `token` timeout is set to `{{ values.expected_token_timeout }}`
remediation: |
  ## Abstract
  The value of the Corosync `token` timeout is not set as recommended.
  ## Remediation
  Adjust the corosync `token` timeout as recommended...

facts:
  - name: corosync_token_timeout
    gatherer: corosync.conf
    argument: totem.token

values:
  - name: expected_token_timeout
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

| Key                           | Required/Not Required | Details          
| ----------------------------- | --------------------- | ------------------------------------------
| `id`                          | required              | Check's id [see more](#id)
| `name`                        | required              | Check's name [see more](#name)
| `group`                       | required              | Check's group [see more](#group)
| `description`                 | required              | Check's description [see more](#description)
| `remediation`                 | required              | Check's remediation [see more](#remediation)
| `severity`                    | not required          | Check's severity [see more](#severity)
| `facts`                       | required              | Check's facts [see more](#facts)
| `values`                      | not required          | Check's values [see more](#values)
| `expectations`                | required              | Check's expectations [see more](#expectations)

---

## Metadata

Consider as Metadata the subset of basic information that build up a Check, not strictly involved in the actual execution (except for the **id**).

### id

Uniquely identifies a Check in the Catalog

ie: 
```yaml
id: 156F64
id: 845CC9
id: B089BE
```

### name

A, preferably one-line, string representing the name for the Check being declared.

ie: 
```yaml
name: Corosync `token` timeout
name: Corosync `consensus` timeout
name: SBD Startmode
```

**NOTES:** 
- in the current ansible implementation the name is set to something like `1.1.1`, `1.1.2`, ...
- in the current wanda implementation we are not really using this
- put into discussion, is it useful?
- should it be considered a markdown content?
- will it be displayed somewhere in the dashboard?

### group

A, preferably one-line, string representing the group where the Check being declared belongs.

Example: 
```yaml
group: Corosync
group: Pacemaker
group: SBD
```

### description

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

has access to [`env`](#env) and [`values`](#values-1) evaluation scopes (not yet true, and not yet defined if needed)

Note: if we want to have access to resolved `values` we would also need `env` (and `facts` maybe, but we could consider a scenario where we do not have facts?)

```yaml
description: |
  `values.some_value` is `{{ values.some_value }}`
  `env.some_env` is `{{ env.some_env }}`

description: |
  Corosync `token` timeout is set to `{{ values.expected_token_timeout }}`
```

### remediation

A text providing an comprehensive description about the remediation to apply for the Check being declared.

It has the same properties of the `description`
- can be a one-liner (it usually is not)
- can be a multiline (it usually is)
- format is **markdown**
- has access to [`env`](#env) and [`values`](#values-1) evaluation scopes (not yet true, and not yet defined if needed)

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

### Severity

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

## Facts

Facts are various types of information that the engine can discover on the target infrastructure.
Examples include (but are not limited to) installed packages, open ports, and configuration files' content.

The process of determining the value of a declared fact during Check execution is refered to as _Facts Gathering_ and it is the job of the [_Gatherers_](./gatherers.md).
Think of gatherers as being functions that have a name and accept argument(s).

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

Finally, gathered facts, will be used in Check's [Expectations](#expectations) to determine whether expected conditions are met for the best practice to be adhered.

## Values

Values are basically named variables that may evaluate differently based on the execution context and are used with Facts in [Expectations](#expectations) Evaluation.

This is needed because the same check might expect facts to be treated differently based on the context.

> Let's clarify with an example:
>
> A Check might define a fact named `awesome_fact` which is expected to be different given the _color_ of the execution.
> - it has to be `cat` when the `color` in the execution context is `red`
> - it has to be `dog` when the `color` in the execution context is `blue`
> - it has to be `rabbit` in all other cases, regardless of the execution context
> 
> so we define a named variable `awesome_expectation` that resolves to `cat|dog|rabbit` when proper conditions are met
>
> allowing us to have an expectation like this 
>
> `expect: facts.awesome_fact == values.expected_token_timeout`

In a nutshell, Values provide a way to decouple concepts, usually expeced values for facts, from their actual concretization during execution in certain scenarios.

A Value declaration contains:
- the value name
- the default value
- a list of conditions that determine the value given the context

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

- there may be 0 [(Empty)](#empty-conditions) to N conditions
- first condition that passes determines the value, following are not evaluated
- `when` entry [Expression](#expression-language) has [access](#evaluation-scope) to gathered [facts](#facts-1) and [env](#env) evaluation scopes

All the _resolved_ declared values would be registered in the [`values`](#values-1) namespaced evaluation scope.

### Empty conditions

Providing an empty list of conditions or omitting it completely should work, yet if some or all of the values end up in being only defaults, consider [omitting the value](#omitting-values)

```yaml
values:
  - name: expected_corosync_max_messages
    default: 20
    # conditions: []

expectations:
  - name: corosync_max_messages_is_correct
    expect: facts.corosync_max_messages == values.expected_corosync_max_messages
```

### Omitting Values

Values provide a powerful way to deal with contextual expectations, yet in some cases this contextuality might not be needed at all.

In that case it is suggested to use hardcoded constant values.

the `value` can be omitted and even the whole `values` section in the Check Definition can be mitted.

example:
> No matter what the context is, the fact `awesome_fact` MUST always be `wanda`
>
> expectation simply looks like this 
>
> `expect: facts.awesome_fact == "wanda"`

## Expectations

Expectations section is where the assumptions about the state of a target infra for a given scenario are formalized in expressions determining whether a check passes or not.

An Expectation declaration contains:
- the expectation name
- the expectation expression itself with [access](#evaluation-scope) to gathered [facts](#facts-1), [resolved values](#values-1) and the [environment](#env)

```yaml
expectations:
  - name: <expectation_name>
    expect: <expectation_expression>

  - name: <another_expectation_name>
    expect: <another_expectation_expression>

  - name: <yet_another_expectation_name>
    expect_same: <yet_another_expectation_expression>
```

Extra considerations:
- there can be many expectations for a single Check
- an expectation can be one of two types [`expect`](#expect) or [`expect_same`](#expect-same)
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
### Expect

This type of expectation is satisfied when, after facts gathering, the expression is true for all the targets involved in the current execution.

> Execution Scenario:
> 
> - 2 targets [`A`, `B`]
> - selected Checks [`corosync_check`]
> - some environment (context)
> 
> ```yaml
> expectations:
>   - name: token_timeout
>     expect: facts.corosync_token_timeout == values.expected_token_timeout
> ```

Considering the previous scenario what happens is that:
- the fact `corosync_token_timeout` is gathered on all targets (`A` and `B` in this case)
- the expectation expression gets executed against the `corosync_token_timeout` fact gathered on every targets.
  - `targetA.corosync_token_timeout == values.expected_token_timeout`
  - `targetB.corosync_token_timeout == values.expected_token_timeout`
- every evaluation has to be `true`

### Expect Same

This type of expectation is satisfied when, after facts gathering, the expression's return value is the same for all the targets involved in the current execution.

> Execution Scenario:
> 
> - 2 targets [`A`, `B`]
> - selected Checks [`some_check`]
> - some environment (context)
> 
> ```yaml
> expectations:
>   - name: awesome_expectation
>     expect_same: facts.awesome_fact
> ```

Considering the previous scenario what happens is that:
- the fact `awesome_fact` is gathered on all targets (`A` and `B` in this case)
- the expectation expression gets executed for every target involved.
  - `targetA.facts.awesome_fact`
  - `targetB.facts.awesome_fact`
- the expressions results has to be the same for every target
  - `targetA.facts.awesome_fact == targetB.facts.awesome_fact`

## Expression Language

Different parts of the Check declaration are places where a computation is needed in order to do the right thing.

> Provide a contextual [Description](#description)/[Remediation](#remediation) text, based on the execution context
> 
> interpolation of `{{ <expression> }}`
```yaml
description: |
  Corosync `token` timeout is set to `{{ values.expected_token_timeout }}`
``` 

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

All Expressions are based on an embedded scripting language and evaluation engine, [Rhai](https://rhai.rs/book/ref/index.html).

### Evaluation Scope

Every expression has access to an evaluation scope, allowing to access relevant piece of information to run the expression.

Scopes are namespaced and access to items in the scope is name based.

#### **env**

`env` is a map of information about the context of the running execution, it is set by the system on each execution/check compilation.

Available entries in scope
| name                          | Type                                                              
| ----------------------------- | ------------------------------------------------------- 
| `env.provider`                | one of `azure`, `aws`, `gcp`,`kvm`,`nutanix`, `unknown`  

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
| name                            | Resolved to                                                              
| ------------------------------- | ------------------------------------------------------- 
| `values.expected_token_timeout` | `5000`, `30000`, `20000` based on the conditions
| `values.another_variable_value` | `blue`, `red` based on the conditions

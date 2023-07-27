# Wanda Demo

## Introduction

Wanda's demo mode provides a simulated environment where targets' gathered facts are faked via a configuration yaml file. This empowers showcasing Trento's capabilities, and eases the development of the platform. The user is able to run check executions from the web, and wanda's fake server returns faked gathered facts.

## How to setup Wanda in demo mode?

First set up the [local environment](./hack_on_wanda.md) and run the following command to start Wanda in demo mode, instead of the usual `iex -S mix phx.server`

```bash
$ DATABASE_URL=ecto://postgres:postgres@localhost:5434/wanda_dev \
  AMQP_URL=amqp://wanda:wanda@localhost:5674 \
  SECRET_KEY_BASE=Tbp26GilFTZOXafb7FNVqt4dFQdeb7FAJ++am7ItYx2sMzYaPSB9SwUczdJu6AhQ \
  CORS_ORIGIN=http://localhost:4000 \
  ACCESS_TOKEN_ENC_SECRET=s2ZdE+3+ke1USHEJ5O45KT364KiXPYaB9cJPdH3p60t8yT0nkLexLBNw8TFSzC7k \
  PORT=4001 \
  MIX_ENV=demo \
  iex -S mix phx.server
```

### Explanation of environment variables:

- DATABASE_URL: The URL to connect to the Postgres database running in the Docker container.
- AMQP_URL: The URL for RabbitMQ, used for message exchange.
- SECRET_KEY_BASE: The secret key for Wanda.
- CORS_ORIGIN: The origin URL from where API requests are allowed (pointing to web).
- ACCESS_TOKEN_ENC_SECRET: Secret key for encrypting access tokens.
- PORT: The port on which Wanda will run (4001 in this case).
- MIX_ENV: The environment in which Wanda will run (set to "demo" for the demo environment).

## Modify demo facts configuration

In the Wanda demo environment, configure fake facts by editing the [fake_facts configuration](https://github.com/trento-project/wanda/blob/main/priv/demo/fake_facts.yaml). Define or modify custom facts for different targets and checks.

### YAML Structure

The Configuration is saved in [fake_facts.yaml](https://github.com/trento-project/wanda/blob/main/priv/demo/fake_facts.yaml) file, which follows a specific structure with two main sections: `targets` and `facts`.

Example:

```yaml
targets:
  target1: 0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4
  target2: 13e8c25c-3180-5a9a-95c8-51ec38e50cfc
facts:
  check_1:
    fact_name1:
      target1: 2
      target2: 3
```

### Targets

The targets section allows defining handles for targets' UUIDs, providing a reference that can be used through the configuration.

Format:

```yaml
targets:
  <target_reference>: <target_id>
```

`<target_reference>`: A user-defined handle or reference for a target.

`<target_id>`: The UUID or identifier of the target.

Add as many new target entries as required:

```yaml
targets:
  target1: 0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4
  target2: 13e8c25c-3180-5a9a-95c8-51ec38e50cfc
  <target_reference>: <new_target_id>
```

### Facts:

The facts section allows specifying what fact value a target should return for a specific check.

The format for the facts section is as follows:

```yaml
facts:
  <check_id>:
    <fact_name>:
      <target_reference>: <fact value>
      <target_reference2>: <fact value>
```

- There can be as many <check_id> as needed.
- Each <check_id> there can be as many <fact_name> configured as needed.
- Each <fact_name> can be instrumented to have a specific <fact value> on a <target_reference>.

Example:

```yaml
targets:
  target1: 0a055c90-4cb6-54ce-ac9c-ae3fedaf40d4
  target2: 13e8c25c-3180-5a9a-95c8-51ec38e50cfc
  target3: 3f16cb32-57fb-46cc-9bf1-cd8d72d7eb9a

facts:
.......existing facts..........
  new_check_id:
    new_fact_name:
      target1: <fact value>
      target2: <fact value>
      target3: <fact value>
```

## FAQ

### What happens with unmapped targets, facts or checks?

Wanda will still evaluate and return a default fallback fact value "some fact value" for a check's execution. This means when a new check is added to wanda, changing the the configuration is optional.

### How to know what's the correct return value of a fact?

Every Fact Gatherer has specific return values. To get an overview of all gatherers, refer to [Wanda's gatherers guide](../gatherers.md).
Determining the correct return value of a fact requires inspecting the specific check itself.
Visit the [Checks Catalog](https://github.com/trento-project/wanda/blob/main/priv/catalog) to find out which gatherer is used for the specific check and which values are expected.

# Wanda

[![CI](https://github.com/trento-project/wanda/actions/workflows/ci.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/main.yaml)
[![Coverage Status](https://coveralls.io/repos/github/trento-project/wanda/badge.svg?branch=main)](https://coveralls.io/github/trento-project/wanda?branch=main)
[![Documentation](https://img.shields.io/badge/documentation-grey.svg)](https://trento-project.io/wanda/)

A service responsible to orchestrate Checks executions on a target infrastructure.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `wanda` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wanda, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/wanda>.

## Developing Checks

Wanda architecture aims to simplify [testing Checks Executions](#testing-executions) and [adding new ones](#adding-new-checks).

### Infrastructure

A docker-compose setup is provided to enable seamless experience with the system.

#### Starting a local environment

Start the required infrastructure (see [docker-compose.checks.yaml](./docker-compose.checks.yaml))

```bash
$ docker-compose -f docker-compose.checks.yaml up -d
```

Wanda is exposed on port `4000` and the API documentation is available at http://localhost:4000/swaggerui

**Note** that the [message broker](https://www.rabbitmq.com/) **must** be reachable by wanda and all the targets.

### Testing Executions

With a runnig setup it is possible to easily test Checks and their Execution by:

- consulting the catalog
- starting a Checks Execution
- checking up the state of the started execution

#### **Consulting the catalog**

Available Checks are part of the **Catalog**, and they can be retrieved by accessing the dedicated API

```bash
curl -X 'GET' \
  'http://localhost:4000/api/checks/catalog' \
  -H 'accept: application/json'
```

#### **Starting a Checks Execution**

A Checks Execution can be started by calling the Start Execution endpoint, as follows

```bash
curl --request POST 'http://localhost:4000/api/checks/executions/start' \
--header 'accept: application/json' \
--header 'Content-Type: application/json' \
--data-raw '{
  "env": {
    "provider": "azure"
  },
  "execution_id": "205e326d-0c25-4f4b-9976-43f9ba1c86d3",
  "group_id": "3dff9d03-4adf-453e-9513-8533e221bb12",
  "targets": [
    {
      "agent_id": "a644919a-d953-43d4-bd57-7e0bb96ee894",
      "checks": [
        "156F64"
      ]
    },
    {
      "agent_id": "02d99b2f-0efd-443c-ac9c-32710323f620",
      "checks": [
        "OTH3R1"
      ]
    }
  ]
}'
```

> **execution_id** must be new and unique for every new execution. If an already used **execution_id** is provided, starting the execution fails.

In order to get the detailed information for an execution see [Getting Execution details](#getting-execution-details).

> Please note that execution is _eventually started_, meaning that a successful response to the previous API call does not guarantee that the execution is running, but that it has been accepted by the system to start.

#### **Getting Execution details**

To get detailed information about the execution, the following API can be used.

```bash
curl --request GET 'http://localhost:4000/api/checks/executions/205e326d-0c25-4f4b-9976-43f9ba1c86d3' \
--header 'accept: application/json' \
--header 'Content-Type: application/json'
```

> **Note** that calling the execution detail API right after [starting an execution](#starting-a-checks-execution) might result in a `404 not found`, because the execution, as mentioned, is _eventually started_.
>
> In this case retry getting the detail of the execution.

Refer to the [API doc](http://localhost:4000/swaggerui) for more information about requests and responses.

### Adding new Checks

Built-in Checks can be found in the Catalog directory at `./priv/catalog/`

In order to implement new checks and test them:

- write a new [Check Specification](./guides/specification.md) file
- locate the newly created Check in the Catalog directory `./priv/catalog/`
- test the execution as [previously described](#testing-executions)

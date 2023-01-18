# Wanda

[![CI](https://github.com/trento-project/wanda/actions/workflows/ci.yaml/badge.svg)](https://github.com/trento-project/wanda/actions/workflows/ci.yaml)
[![Coverage Status](https://coveralls.io/repos/github/trento-project/wanda/badge.svg?branch=main)](https://coveralls.io/github/trento-project/wanda?branch=main)
[![Documentation](https://img.shields.io/badge/documentation-grey.svg)](https://trento-project.io/wanda/)

A service responsible to orchestrate Checks executions on a target infrastructure.

# Documentation

The documentation is available at [trento-project.io/wanda](https://trento-project.io/wanda/).

Swagger UI is available at [trento-project.io/wanda/swaggerui](https://trento-project.io/wanda/swaggerui).

## Developing Checks

Wanda architecture aims to simplify [testing Checks Executions](#testing-executions) and [adding new ones](#adding-new-checks).

### Infrastructure

For development purposes, a [docker-compose file](https://github.com/trento-project/wanda/blob/main/docker-compose.yaml) is provided.
The [docker-compose.checks.yaml](https://github.com/trento-project/wanda/blob/main/docker-compose.checks.yaml) provides additional configuration to start an environment for Checks development.

#### Starting a local environment

Start the environment with:

```bash
$ docker-compose -f docker-compose.checks.yaml up -d
```

Wanda is exposed on port `4000` and the API documentation is available at http://localhost:4000/swaggerui

**Note** that the [message broker](https://www.rabbitmq.com/) **must** be reachable by Wanda and all the targets.

### Testing Executions

With a running setup, it is possible to easily test Checks and their Execution by:

- starting the targets
- consulting the catalog
- starting a Checks Execution
- checking the state of an execution
- debugging the gathered facts

#### **Starting the targets**

The [trento-agent](https://github.com/trento-project/agent) must be up and running on the targets to run a correct execution, otherwise a timeout error is raised.

Here an example on how to start it:

```
./trento-agent start --api-key <api-key> --facts-service-url amqp://wanda:wanda@localhost:5674
```

> Note: `api-key` value is not used if the unique goal is to run checks, so setting it as `--api-key 0` does the work.

Keep in mind that the `agent_id` of the targets must match with values provided in the `targets` field of the execution request.

The ID can be obtained running:

```
./trento-agent id
```

If the execution is run in a development/testing environment, [faking the agent id](https://github.com/trento-project/agent#fake-agent-id) might come handy. 

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

In order to get detailed information for an execution, see [Getting Execution details](#getting-execution-details).

> Please note that execution is _eventually started_, meaning that a successful response to the previous API call does not guarantee that the execution is running, but that it has been accepted by the system to start.

#### Execution Targets

An execution target is a target host where the checks are executed. This requires to have the `trento-agent` executable running in the host. In order to specify an execution order, its `agent_id` and a list of checks to be executed are provided. Once the execution is started, a facts gathering request is sent to these targets, facts are gathered and sent back to Wanda, where the checks result is evaluated using the gathered facts.

The `agent_id` can be obtained just issuing `trento-agent id` command in the target host.

Each target _must_ specify a list of checks, that can be empty. These are the selected checks for each agent, that are executed.

Given two different targets, the same checks can be selected:

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
        "156F64",
        "45B653"
      ]
    },
    {
      "agent_id": "02d99b2f-0efd-443c-ac9c-32710323f620",
      "checks": [
        "156F64",
        "45B653"
      ]
    }
  ]
}'
```

Or completely different ones:

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
        "156F64",
        "45B653"
      ]
    },
    {
      "agent_id": "02d99b2f-0efd-443c-ac9c-32710323f620",
      "checks": [
        "OTH3R1",
        "OTH3R2"
      ]
    }
  ]
}'
```

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

#### **Debugging gathered facts**

Often times knowing the returned value of the gathered facts is not a trivial thing, more during the implementation of new checks.

To better debug the fact gathering process and the returned values the `facts` subcommand of `trento-agent` is a really useful tool. This command helps to see in the target itself what the gathered fact looks like. This is specially interesting when the returned value is a complex object or the target under test is modified and the check developer wants to see how this affects to the gathered fact.

The command can be used as:

```
./trento-agent facts gather --gatherer corosync.conf --argument totem.token
# To see the currently available gatherers and their names
# ./trento-agent facts list
```

Which would return the next where the `Value` is the available value in the written check:

```
{
  "Name": "totem.token",
  "CheckID": "",
  "Value": {
    "Value": 30000
  },
  "Error": null
} 
```

### Adding new Checks

Built-in Checks can be found in the Catalog directory at `./priv/catalog/`

To implement new checks and test them:

- write a new [Check Specification](./guides/specification.md) file
- locate the newly created Check in the Catalog directory `./priv/catalog/`
- test the execution as [previously described](#testing-executions)

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

# License

Copyright 2021-2022 SUSE LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
any of the source code in this project except in compliance with the License. You may obtain a copy of the
License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

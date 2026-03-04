# Trento Wanda Container Image

## Description

Trento Wanda is the service responsible for orchestrating Checks executions on a target infrastructure.

## Usage

To run Trento Wanda using the container image:

```console
docker run -d \
  --name trento-wanda \
  -p 4000:4000 \
  -v /path/to/checks:/usr/share/trento/checks \
  registry.suse.com/trento/trento-wanda
```

Wanda exposes its HTTP API on port `4000`.

### API examples

Consult the checks catalog:

```console
curl -X GET \
  'http://localhost:4000/api/v1/checks/catalog' \
  -H 'accept: application/json'
```

Start a checks execution:

```console
curl --request POST 'http://localhost:4000/api/v1/checks/executions/start' \
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
        "checks": ["156F64"]
      }
    ]
  }'
```

Get execution details:

```console
curl --request GET \
  'http://localhost:4000/api/v1/checks/executions/205e326d-0c25-4f4b-9976-43f9ba1c86d3' \
  --header 'accept: application/json'
```

Refer to the [official SUSE documentation](https://documentation.suse.com/sles-sap/trento/html/SLES-SAP-trento/index.html) for detailed instructions.

## Licensing

`SPDX-License-Identifier: Apache-2.0`

This project is licensed under the Apache License 2.0. See the [LICENSE](https://github.com/trento-project/wanda/blob/main/LICENSE) file for details.

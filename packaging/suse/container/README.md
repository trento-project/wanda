# Trento Wanda Container Image

## Description

Trento Wanda is the service responsible for orchestrating Checks executions on a target infrastructure.

## Usage

The officially supported ways to run Trento are described at the [SUSE documentation website](https://documentation.suse.com/sles-sap/trento/html/SLES-SAP-trento/id-installation.html#). It covers the RPM and the Kubernetes-based deployments.

If you want to run Trento using containers, please refer to the Helm chart available at the [Trento Helm Charts](https://github.com/trento-project/helm-charts) repository. It is the supported way to run Trento using containers in a Kubernetes environment, as it takes care of all the necessary dependencies and configurations for you.

You can install the Trento Helm Chart using the following command:

```bash
helm upgrade \
   --install trento-server oci://registry.suse.com/trento/trento-server \
   --create-namespace \
   --namespace trento \
   --set global.trentoWeb.origin=YOUR_TRENTO_SERVER_HOSTNAME \
   --set trento-web.adminUser.password=YOUR_ADMIN_PASSWORD
```

### Using the container image directly

Running the container image directly is not the recommended way to run Trento and it is not supported by SUSE. It requires manual configuration of all dependencies and environment variables, including PostgreSQL and RabbitMQ.

If you still want to run Trento from the container image without Kubernetes, please refer to the [project documentation](https://www.trento-project.io/docs/developer/internal-notes/trento-container-install.html).

As a quick example, you can run the container image using the following command:

```bash
# Create a volume for the checks and run the container
docker volume create trento-checks \
  && docker run \
  --name trento-checks-installer \
  -v trento-checks:/usr/share/trento/checks \
  registry.suse.com/trento/trento-checks
```

```bash
# Set the proper environment variables, see https://github.com/trento-project/wanda/blob/main/packaging/suse/rpm/systemd/trento-wanda.example
docker run -d --name wanda -p 4001:4000 -v trento-checks:/usr/share/trento/checks:ro registry.suse.com/trento/trento-wanda start
```

## Licensing

`SPDX-License-Identifier: Apache-2.0`

This project is licensed under the Apache License 2.0. See the [LICENSE](https://github.com/trento-project/wanda/blob/main/LICENSE) file for details.

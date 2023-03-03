# Hack on Wanda

## Requirements

In order to run Wanda, the following software must be installed:

1. [Elixir](https://elixir-lang.org/)
2. [Erlang OTP](https://www.erlang.org/)
3. [Rust](https://www.rust-lang.org/tools/install)
4. [Docker](https://docs.docker.com/get-docker/)
5. [Docker Compose](https://docs.docker.com/compose/install/)

### Ensure Compatibility with asdf

[asdf](https://asdf-vm.com/guide/introduction.html) allows using specific versions of programming language tools that are known to be compatible with the project, rather than relying on the version that's installed globally on the host system.

In order to use asdf, follow the official [asdf getting started guide](https://asdf-vm.com/guide/getting-started.html).

Install all required asdf plugins from [.tool-versions](/.tool-versions) inside the web repository.

```
cut -d' ' -f1 .tool-versions|xargs -i asdf plugin add  {}
```

Set up the asdf environment

```
asdf install
```

## Development environment

A `docker-compose` environment is provided for easy local development. To start the environment, run the following command:

```
docker-compose up -d
```

This command starts a **Postgres** database and a **RabbitMq** instance, which is used for storage and communication.

## Setup Wanda

Before starting Wanda, some initial setup tasks are required. This can be achieved by running the following command:

```
mix setup
```

This command performs necessary tasks such as installing dependencies, creating the database schema and running migrations.

### Hint about Project setup

Gain a deeper understanding of how Wanda is configured, reading the [mix.exs](https://github.com/trento-project/wanda/blob/main/mix.exs) file located in the root directory of the project. This file contains information on dependencies, configuration settings, and tasks that can be run using the Mix build tool, providing a complete picture of the project's setup.

## Start Wanda in the REPL

To start Wanda, you need to run the following command:

```
iex -S mix phx.server
```

## Access Wanda Swaggerui

Congratulations, Wanda is now running locally on your machine! You can access its API documentation by visiting the following URL:
[localhost:4001/swaggerui](http://localhost:4001/swaggerui).

The Swagger UI provides a user-friendly interface for exploring and testing the various API endpoints of Wanda.

Happy Hacking!

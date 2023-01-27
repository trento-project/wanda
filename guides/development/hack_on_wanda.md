# Hack on Wanda

In order to run Wanda, the following is needed

1. [Elixir](https://elixir-lang.org/), a programming language used to build scalable and maintainable applications.
2. [Docker](https://docs.docker.com/get-docker/), a platform for developing, shipping, and running applications in containers.
3. [Docker Compose](https://docs.docker.com/compose/install/), a tool for defining and running multi-container applications.

## Development environment

A `docker-compose` environment is provided for easy local development. To start the environment, run the following command:

```
docker-compose up -d
```

This command starts a **Postgres** database and a **RabbitMq** instance, which is used for storage and communication respectively.

## Setup Wanda

Before starting Wanda, some initial setup tasks are required. This can be achieved by running the following command:

```
mix setup
```

This command performs necessary tasks such as installing dependencies, creating the database schema and running migrations.

### Hint about Project setup

Gain a deeper understanding of how Wanda is configured, reading the [mix.exs](/mix.exs) file located in the root directory of the project. This file contains information on dependencies, configuration settings, and tasks that can be run using the Mix build tool, providing a complete picture of the project's setup.

## Start Wanda in the REPL

To start Wanda, you need to run the following command:

```
iex -S mix phx.server
```

This command starts the Wanda server and opens an interactive Elixir shell (REPL) for you to interact with the running application.

## Access Wanda Swaggerui

Congratulations, Wanda is now running locally on your machine! You can access its API documentation by visiting the following URL: [localhost:4001/swaggerui](http://localhost:4001/swaggerui).

The Swagger UI provides a user-friendly interface for exploring and testing the various API endpoints of Wanda.

Happy Hacking!

# Hack on Wanda

In order to run Wanda, you will need

1. [Elixir](https://elixir-lang.org/), a programming language used to build scalable and maintainable applications.
2. [Docker](https://docs.docker.com/get-docker/), a platform for developing, shipping, and running applications in containers.
3. [Docker Compose](https://docs.docker.com/compose/install/), a tool for defining and running multi-container applications.

## Development environment

A `docker-compose` development environment is provided for easy setup and management of dependencies. To start the development environment, simply run the following command:

```
docker-compose up -d
```

This command will start a **Postgres** database and a **RabbitMq** instance, which will be used for storage and communication respectively.

## Install dependencies

Before you can start hacking on Wanda, you will need to install its dependencies. You can do this by running the following command:

```
mix deps.get
```

This command will install all the required libraries and dependencies for the application.

## Setup Wanda

After installing the dependencies, you will need to perform some initial setup tasks before you can start Wanda. You can do this by running the following command:

```
mix setup
```

This command will perform necessary tasks such as creating the database schema and running migrations.

## Start Wanda in the REPL

To start Wanda, you will need to run the following command:

```
iex -S mix phx.server
```

This command starts the Wanda server and opens an interactive Elixir shell (REPL) for you to interact with the running application.

## Access Wanda Swaggerui

Congratulations, Wanda is now running locally on your machine! You can access its API documentation by visiting the following URL:
[localhost:4001/swaggerui](http://localhost:4001/swaggerui)
The Swagger UI provides a user-friendly interface for exploring and testing the various API endpoints of Wanda.

Happy Hacking!

# Hack on wanda

- [Requirements](#requirements)
- [Install dependencies](#install-dependencies)
- [Development environment](#development-environment)
- [Setup wanda](#setup-wanda)
- [Start wanda in the repl](#start-wanda-in-the-repl)

In order to run the wanda, you will need

1. [Elixir](https://elixir-lang.org/)
2. [Docker](https://docs.docker.com/get-docker/)
3. [Docker Compose](https://docs.docker.com/compose/install/)

## Development environment

A `docker-compose` development environment is provided.

```
docker-compose up -d
```

It will start a **postgres** database and a **rabbitmq** instance, for storage and communication.

## Install dependencies

```
mix deps.get
```

## Setup wanda

```
mix setup
```

## Start wanda in the repl

```
iex -S mix phx.server
```

## Access wanda swaggerui

Congratulations, wanda is running locally now.
You can access now Swaggerui: [localhost:4001/swaggerui](http://localhost:4001/swaggerui)

Happy Hacking!

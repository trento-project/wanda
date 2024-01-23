FROM opensuse/tumbleweed AS elixir-build
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN zypper -n in git-core elixir elixir-hex erlang-rebar3 rust cargo
COPY . /build
WORKDIR /build
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
RUN mix deps.get

FROM elixir-build AS release
COPY --from=elixir-build /build /build
WORKDIR /build
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
RUN mix phx.digest
RUN mix release

FROM registry.suse.com/bci/bci-base:15.4 AS wanda
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /app
COPY --from=release /build/_build/$MIX_ENV/rel/wanda .
EXPOSE 4000/tcp
ENTRYPOINT ["/app/bin/wanda"]
FROM registry.suse.com/bci/rust:1.81 AS elixir-build
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN zypper ar https://download.opensuse.org/repositories/devel:sap:trento:builddeps/15.6 buildeps
RUN zypper -n --gpg-auto-import-keys ref
RUN zypper -n in git-core elixir==1.15 elixir-hex erlang==26 erlang-rebar3
COPY . /build
WORKDIR /build
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
RUN mix deps.get

FROM elixir-build AS release
COPY --from=elixir-build /build /build
WORKDIR /build
ARG MIX_ENV=prod
ARG VERSION
ENV MIX_ENV=$MIX_ENV
ENV MIX_HOME=/usr/bin
ENV MIX_REBAR3=/usr/bin/rebar3
ENV MIX_PATH=/usr/lib/elixir/lib/hex/ebin
ENV VERSION=$VERSION
RUN mix phx.digest
RUN mix release

FROM registry.suse.com/bci/bci-base:15.6
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
# Erlang runtime dependencies
RUN zypper -n in libsystemd0 libopenssl1_1
WORKDIR /app
COPY --from=release /build/_build/$MIX_ENV/rel/wanda .
VOLUME /usr/share/trento/checks
EXPOSE 4000/tcp
ENTRYPOINT ["/app/bin/wanda"]

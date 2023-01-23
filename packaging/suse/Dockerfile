# SPDX-License-Identifier: Apache-2.0
#!BuildTag: trento/trento-wanda:latest
#!BuildTag: trento/trento-wanda:%%VERSION%%
#!BuildTag: trento/trento-wanda:%%VERSION%%-build%RELEASE%
#!UseOBSRepositories

FROM bci/rust:1.66 AS release
ADD wanda.tar.gz /build/
# Workaround for https://github.com/openSUSE/obs-build/issues/487
RUN zypper --non-interactive in sles-release
RUN zypper -n in elixir elixir-hex erlang-rebar3
WORKDIR /build/wanda/
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MIX_ENV=prod
ENV MIX_HOME=/usr/bin
ENV VERSION=%%VERSION%%
RUN mix phx.digest
RUN mix release

FROM bci/rust:1.66 AS wanda
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /app
COPY --from=release /build/wanda/_build/prod/rel/wanda .
EXPOSE 4000/tcp
ENTRYPOINT ["/app/bin/wanda"]

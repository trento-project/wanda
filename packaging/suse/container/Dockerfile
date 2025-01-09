# SPDX-License-Identifier: Apache-2.0
#!BuildTag: trento/trento-wanda:latest
#!BuildTag: trento/trento-wanda:%%VERSION%%
#!BuildTag: trento/trento-wanda:%%VERSION%%-build%RELEASE%
#!UseOBSRepositories
#!ExclusiveArch: x86_64

FROM registry.suse.com/bci/rust:1.66 AS release
ADD wanda.tar.gz /build/
RUN zypper -n in git-core elixir==1.15 elixir-hex erlang==26 erlang-rebar3
WORKDIR /build/wanda/
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV=prod
ENV MIX_HOME=/usr/bin
ENV MIX_REBAR3=/usr/bin/rebar3
ENV MIX_PATH=/usr/lib/elixir/lib/hex/ebin
ENV VERSION=%%VERSION%%
RUN mix phx.digest
RUN mix release

FROM registry.suse.com/bci/rust:1.66
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
WORKDIR /app
COPY --from=release /build/wanda/_build/prod/rel/wanda .
VOLUME /usr/share/trento/checks
EXPOSE 4000/tcp
ENTRYPOINT ["/app/bin/wanda"]

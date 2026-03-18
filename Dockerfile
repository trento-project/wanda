ARG OS_VER=15.7
FROM registry.suse.com/bci/rust:1.92 AS elixir-build
ARG OS_VER
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN zypper ar https://download.opensuse.org/repositories/devel:sap:trento:builddeps/${OS_VER} builddeps
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
FROM registry.suse.com/bci/bci-base:${OS_VER}
ARG OS_VER
ARG VERSION
ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento
LABEL org.opencontainers.image.authors="https://github.com/trento-project/wanda/graphs/contributors"
LABEL org.opencontainers.image.title="Trento Wanda"
LABEL org.opencontainers.image.description="Service responsible to orchestrate Checks executions on a target infrastructure"
LABEL org.opencontainers.image.documentation="https://www.trento-project.io/docs/wanda/README.html"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.url="https://github.com/trento-project/wanda"
# LABEL org.opencontainers.image.created="" # Set by GHA, no need to set here
LABEL org.opencontainers.image.vendor="SUSE LLC"
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
LABEL org.opencontainers.image.ref.name="${OS_VER}-${VERSION}"
LABEL org.opensuse.reference="registry.suse.com/bci/bci-micro:${OS_VER}"
LABEL org.openbuildservice.disturl="https://github.com/trento-project/wanda/pkgs/container/trento-wanda"
# endlabelprefix
LABEL org.opencontainers.image.base.name="registry.suse.com/bci/bci-micro:${OS_VER}"
LABEL org.opencontainers.image.base.digest="latest"
LABEL io.artifacthub.package.logo-url="https://www.trento-project.io/images/trento-icon.svg"
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/trento-project/wanda/refs/heads/main/packaging/suse/container/README.md"
# Erlang runtime dependencies
RUN zypper -n in libsystemd0 libopenssl3
WORKDIR /app
COPY --from=release /build/_build/$MIX_ENV/rel/wanda .
VOLUME /usr/share/trento/checks
EXPOSE 4000/tcp
ENTRYPOINT ["/app/bin/wanda"]

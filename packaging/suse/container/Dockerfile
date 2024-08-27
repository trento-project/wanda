# SPDX-License-Identifier: Apache-2.0
#!BuildTag: trento/trento-wanda:latest
#!BuildTag: trento/trento-wanda:%%VERSION%%
#!BuildTag: trento/trento-wanda:%%VERSION%%-build%RELEASE%
#!UseOBSRepositories
#!ExclusiveArch: x86_64

FROM bci/bci-base:15.6

# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento.wanda
LABEL org.opencontainers.image.title="Trento Wanda"
LABEL org.opencontainers.image.description="Container image for Trento Wanda server component"
LABEL org.opencontainers.image.url="https://www.trento-project.io"
LABEL org.opencontainers.image.source="https://github.com/trento-project/wanda"
LABEL org.opencontainers.image.version="%%VERSION%%-build%RELEASE%"
# endlabelprefix

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN zypper -n in trento-wanda

EXPOSE 4000/tcp
WORKDIR /usr/lib/wanda/
ENTRYPOINT ["/usr/lib/wanda/bin/wanda"]

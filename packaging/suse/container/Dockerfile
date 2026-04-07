# SPDX-License-Identifier: Apache-2.0
#!BuildTag: trento/trento-wanda:latest
#!BuildTag: trento/trento-wanda:%%VERSION%%
#!BuildTag: trento/trento-wanda:%%VERSION%%-build%RELEASE%
#!BuildName: trento-wanda
#!BuildVersion: %%VERSION%%
#!UseOBSRepositories
#!ExclusiveArch: x86_64

FROM registry.suse.com/bci/bci-base:15.7
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=com.suse.trento
LABEL org.opencontainers.image.authors="https://github.com/trento-project/wanda/graphs/contributors"
LABEL org.opencontainers.image.title="Trento Wanda"
LABEL org.opencontainers.image.description="Service responsible to orchestrate Checks executions on a target infrastructure"
LABEL org.opencontainers.image.documentation="https://documentation.suse.com/sles-sap/trento"
LABEL org.opencontainers.image.version="%%VERSION%%"
LABEL org.opencontainers.image.url="https://github.com/trento-project/wanda"
LABEL org.opencontainers.image.created="%BUILDTIME%"
LABEL org.opencontainers.image.vendor="SUSE LLC"
LABEL org.opencontainers.image.source="%SOURCEURL%"
LABEL org.opencontainers.image.ref.name="%%VERSION%%-build%RELEASE%"
LABEL org.opensuse.reference="registry.suse.com/trento/trento-wanda:%%VERSION%%-build%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL com.suse.supportlevel="l3"
LABEL com.suse.supportlevel.until=""
LABEL com.suse.eula="sle-eula"
LABEL com.suse.lifecycle-url="https://www.suse.com/lifecycle#suse-linux-enterprise-server-for-sap-applications-15"
LABEL com.suse.release-stage="released"
# endlabelprefix
LABEL org.opencontainers.image.base.name="%BASE_REFNAME%"
LABEL org.opencontainers.image.base.digest="%BASE_DIGEST%"
LABEL io.artifacthub.package.logo-url="https://www.trento-project.io/images/trento-icon.svg"
LABEL io.artifacthub.package.readme-url="%SOURCEURL_WITH(README.md)%"

RUN set -euo pipefail; \
    zypper -n install --no-recommends trento-wanda

# cleanup logs and temporary files
RUN set -euo pipefail; zypper -n clean -a; \
    rm -rf {/target,}/var/log/{alternatives.log,lastlog,tallylog,zypper.log,zypp/history,YaST2}; \
    rm -rf {/target,}/run/*; \
    rm -f {/target,}/etc/{shadow-,group-,passwd-,.pwd.lock}; \
    rm -f {/target,}/usr/lib/sysimage/rpm/.rpm.lock; \
    rm -f {/target,}/var/lib/zypp/AnonymousUniqueId; \
    rm -f {/target,}/var/lib/zypp/AutoInstalled; \
    rm -f {/target,}/var/cache/ldconfig/aux-cache

# set the day of last password change to empty
RUN set -euo pipefail; sed -i 's/^\([^:]*:[^:]*:\)[^:]*\(:.*\)$/\1\2/' /etc/shadow

VOLUME /usr/share/trento/checks
EXPOSE 4000/tcp
ENTRYPOINT ["/usr/lib/wanda/bin/wanda"]

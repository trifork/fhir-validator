FROM openjdk:23-jdk-slim-bookworm
LABEL maintainer="Henning C. Nielsen"

LABEL org.opencontainers.image.description="FHIR validator cli"
LABEL org.opencontainers.image.vendor="Trifork"

ARG user=validator
ARG group=validator
ARG uid=1000
ARG gid=1000
# GitHub workflows hardcodes the HOME dir to /github/home
ARG HOME=/github/home

ARG IG_PUB_VERSION # Is set by the pipeline

# https://github.com/codacy/codacy-hadolint/blob/master/docs/description/DL4006.md
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://github.com/nodesource/distributions?tab=readme-ov-file#debian-versions
# hadolint ignore=DL3008,DL3028,DL3016
RUN sed -i 's/^Components: main$/& contrib/' /etc/apt/sources.list.d/debian.sources \
  && apt-get update \
  && apt-get install --yes --no-install-recommends \
       curl \
  && curl -fsSL https://github.com/hapifhir/org.hl7.fhir.core/releases/download/${IG_PUB_VERSION}/validator_cli.jar -o validator_cli.jar \
  \
  && apt-get autoremove --yes curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  \
  && groupadd -g ${gid} ${group} \
  && useradd -l -u ${uid} -g ${group} -m ${user} -d $HOME \
  && mkdir -p $HOME/fhir-package-cache \
  && chown -R ${uid} $HOME

# Do not run the entrypoint as root. That is a security risk.
# .. but unfortunately GitHub workflows do not support running as non-root
# https://github.com/actions/checkout/issues/1575
# USER ${uid}:${gid}
WORKDIR $HOME

ENTRYPOINT [ "java", "-jar", "/validator_cli.jar"]

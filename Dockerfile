FROM openjdk:23-jdk-slim-bookworm

LABEL maintainer="Jens Kristian Villadsen" \
      org.opencontainers.image.vendor="Trifork" \
      org.opencontainers.image.description="FHIR Validator CLI"

ARG user=validator
ARG group=validator
ARG uid=1000
ARG gid=1000
ARG HOME=/github/home
ARG IG_PUB_VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# --- Fix broken keyrings first (temporarily allow insecure repos) ---
RUN apt-get -o Acquire::AllowInsecureRepositories=true update || true \
  && apt-get -o Acquire::AllowInsecureRepositories=true install --yes --no-install-recommends \
       ca-certificates \
       debian-archive-keyring \
  && rm -rf /var/lib/apt/lists/*

# --- Now repositories are signed again ---
RUN apt-get update \
  && apt-get install --yes --no-install-recommends curl \
  && curl -fsSL "https://github.com/hapifhir/org.hl7.fhir.core/releases/download/${IG_PUB_VERSION}/validator_cli.jar" \
       -o validator_cli.jar \
  && apt-get purge --yes curl \
  && apt-get autoremove --yes \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  \
  && groupadd -g "${gid}" "${group}" \
  && useradd -l -u "${uid}" -g "${group}" -m "${user}" -d "${HOME}" \
  && mkdir -p "${HOME}/fhir-package-cache" \
  && chown -R "${uid}:${gid}" "${HOME}"

RUN mv validator_cli.jar /github/home/validator_cli.jar

WORKDIR ${HOME}

# USER ${uid}:${gid}

ENTRYPOINT ["java", "-jar", "/github/home/validator_cli.jar"]

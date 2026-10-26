ARG BASE_IMAGE=kali-last-release
FROM docker.io/kalilinux/${BASE_IMAGE} AS base

# Discard community CDNs
RUN sed -i 's|^URIs:.*|URIs: http://kali.download/kali|' /etc/apt/sources.list.d/kali.sources

RUN <<EOT
set -eux
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates curl git ripgrep jq \
  chromium-headless-shell \
  bash-completion less tealdeer
tldr --update
rm -rf /var/lib/apt/lists/*
EOT

ARG OPENCODE_VERSION=latest
RUN <<EOT
set -eux
if [ "$OPENCODE_VERSION" = "latest" ]; then
  OPENCODE_VERSION="$(curl -fsSL --compressed -H 'Accept: application/json' https://api.github.com/repos/anomalyco/opencode/releases/latest | jq -r '.tag_name | sub("^v"; "")')"
fi
curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" | tar -xz --no-same-owner -C /usr/local/bin -f -
opencode --version
EOT

ENTRYPOINT ["opencode"]

FROM base AS toolbox
RUN <<EOT
set -eux
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  kali-linux-headless
rm -rf /var/lib/apt/lists/*
EOT

FROM base AS slim

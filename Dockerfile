ARG BUILD_FROM=databasus/databasus:latest
FROM ${BUILD_FROM}

# Injected at build time (see docker_build.sh: --build-arg BUILD_VERSION=${VERSION})
ARG BUILD_VERSION=0.0.0
LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    io.hass.arch="amd64|aarch64"

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD wget -q --spider http://127.0.0.1:4005/ || exit 1

ENTRYPOINT []
CMD ["/run.sh"]

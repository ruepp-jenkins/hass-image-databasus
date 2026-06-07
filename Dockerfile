ARG BUILD_FROM=databasus/databasus:latest
FROM ${BUILD_FROM}

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD wget -q --spider http://127.0.0.1:4005/ || exit 1

ENTRYPOINT []
CMD ["/run.sh"]

# syntax=docker/dockerfile:1
# Multi-stage build: compile guacenc from Apache Guacamole source,
# then ship a minimal image with guacenc + ffmpeg + the extract entrypoint.

ARG GUAC_VERSION=1.5.5

FROM debian:bookworm-slim AS builder
ARG GUAC_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        autoconf automake libtool pkg-config \
        ca-certificates wget \
        libcairo2-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libswscale-dev \
        uuid-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN set -eux; \
    for base in https://dlcdn.apache.org https://archive.apache.org/dist; do \
        if wget -q "$base/guacamole/${GUAC_VERSION}/source/guacamole-server-${GUAC_VERSION}.tar.gz" -O guac.tar.gz; then \
            break; \
        fi; \
    done; \
    tar xf guac.tar.gz; \
    cd "guacamole-server-${GUAC_VERSION}"; \
    ./configure --disable-guacd; \
    make -j"$(nproc)"; \
    make install

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        libcairo2 \
        libjpeg62-turbo \
        libpng16-16 \
        libwebp7 \
        libavcodec59 \
        libavformat59 \
        libavutil57 \
        libswscale6 \
        libuuid1 \
        ffmpeg \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/guacenc /usr/local/bin/guacenc
COPY --from=builder /usr/local/lib/libguac*.so* /usr/local/lib/
RUN ldconfig

COPY extract.sh /usr/local/bin/extract
RUN chmod +x /usr/local/bin/extract

WORKDIR /work
ENTRYPOINT ["/usr/local/bin/extract"]
CMD ["--help"]

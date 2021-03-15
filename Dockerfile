ARG ALPINE_VERSION=3.12.4

FROM alpine:${ALPINE_VERSION}

LABEL maintainer="LT <lemonthundr@pm.me>"

RUN apk add --no-cache \
  curl \
  git \
  openssh-client \
  rsync

ENV HUGO_VERSION 0.64.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /usr/local/src

RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_checksums.txt \
  && grep "$(sha256sum hugo_${HUGO_VERSION}_Linux-64bit.tar.gz)" hugo_${HUGO_VERSION}_checksums.txt \
  && tar -xf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && mv hugo /usr/local/bin/hugo \
  && rm hugo_${HUGO_VERSION}_checksums.txt \
  && rm hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

RUN addgroup -Sg 1000 hugo \
  && adduser -SG hugo -u 1000 -D --shell /bin/false -h /src hugo

WORKDIR /src

EXPOSE 1313

HEALTHCHECK --timeout=10s --interval=10s --start-period=15s \
  CMD hugo env || exit 1

FROM alpine:3.12.4

LABEL maintainer="LT <lemonthundr@pm.me>"

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

RUN addgroup -S hugo \
  && adduser -S -D -H --shell /bin/false -G hugo hugo

USER hugo

HEALTHCHECK --timeout=5s CMD hugo env || exit 1

WORKDIR /src

EXPOSE 1313

FROM cloudron/base:5.0.0@sha256:04fd70dbd8ad6149c19de39e35718e024417c3e01dc9c6637eaf4a41ec4e596c

# renovate: datasource=custom depName=foundryvtt versioning=semver registryUrl=https://foundryvtt.com/releases/ extractVersion=href="/releases/(?<version>13\.[0-9A-Za-z.-]+)"
ENV VERSION=14.359

WORKDIR /app/code

# Copy Paste from https://git.cloudron.io/platform/docker-base-image/-/blob/master/Dockerfile
## node . we don't use the nodejs/npm package because the npm deb brings in each npm module as deb package!
ARG NODE_VERSION=24.14.1
RUN mkdir -p /usr/local/node-$NODE_VERSION && \
    curl -L https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz | tar zxf - --strip-components 1 -C /usr/local/node-$NODE_VERSION
ENV PATH=/usr/local/node-$NODE_VERSION/bin:$PATH


COPY docker /

RUN unzip FoundryVTT-Node-$VERSION.zip && rm -rf FoundryVTT-Node-$VERSION.zip

CMD ["/app/code/start.sh"]

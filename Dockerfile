FROM cloudron/base:5.0.0@sha256:04fd70dbd8ad6149c19de39e35718e024417c3e01dc9c6637eaf4a41ec4e596c

# renovate: datasource=custom depName=foundryvtt versioning=semver registryUrl=https://foundryvtt.com/releases/ extractVersion=href="/releases/(?<version>13\.[0-9A-Za-z.-]+)"
ENV VERSION=13.350

WORKDIR /app/code

COPY docker /

RUN unzip FoundryVTT-Node-$VERSION.zip && rm -rf FoundryVTT-Node-$VERSION.zip

CMD ["/app/code/start.sh"]

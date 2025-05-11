FROM cloudron/base:5.0.0@sha256:04fd70dbd8ad6149c19de39e35718e024417c3e01dc9c6637eaf4a41ec4e596c

ENV VERSION=13.342

WORKDIR /app/code

COPY docker /

RUN unzip FoundryVTT-$VERSION.zip && rm -rf FoundryVTT-$VERSION.zip

CMD ["/app/code/start.sh"]

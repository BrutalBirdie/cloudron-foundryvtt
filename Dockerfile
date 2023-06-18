FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

ENV VERSION=11.302

WORKDIR /app/code

COPY docker /

RUN unzip FoundryVTT-$VERSION.zip && rm -rf FoundryVTT-$VERSION.zip

CMD ["/app/code/start.sh"]

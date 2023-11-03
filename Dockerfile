FROM cloudron/base:4.2.0@sha256:46da2fffb36353ef714f97ae8e962bd2c212ca091108d768ba473078319a47f4

ENV VERSION=11.314

WORKDIR /app/code

COPY docker /

RUN unzip FoundryVTT-$VERSION.zip && rm -rf FoundryVTT-$VERSION.zip

CMD ["/app/code/start.sh"]

FROM alpine:3.10

RUN apk update && \
    apk add --no-cache ruby ruby-json && \
    gem install --no-rdoc --no-ri mdl && \
    mkdir /data

WORKDIR /data

FROM alpine:latest

LABEL maintainer="hello@blazesnow.com"

RUN apk --no-cache add crontab \
    jq \
    bash

COPY ./crane /usr/local/bin/crane

RUN mkdir -p /app

WORKDIR /app

COPY imageporter.sh /app/imageporter.sh

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
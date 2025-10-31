FROM alpine:latest

LABEL maintainer="hello@blazesnow.com"

ENV TZ=UTC \
    CRON="0 0 * * *" \
    SOURCE_REGISTRY="" \
    SOURCE_USERNAME="" \
    SOURCE_PASSWORD="" \
    TARGET_REGISTRY="" \
    TARGET_USERNAME="" \
    TARGET_PASSWORD=""

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
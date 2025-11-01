FROM alpine:latest

LABEL maintainer="hello@blazesnow.com"

ENV TZ="" \
    CRON="" \
    DISABLE_FIRSTRUN="" \
    DEFAULT_PLATFORM="" \
    SOURCE_REGISTRY="" \
    SOURCE_USERNAME="" \
    SOURCE_PASSWORD="" \
    TARGET_REGISTRY="" \
    TARGET_USERNAME="" \
    TARGET_PASSWORD=""

RUN apk --no-cache add jq tzdata

RUN mkdir -p /app

WORKDIR /app

COPY ./crane /usr/local/bin/crane

COPY ./supercronic /usr/local/bin/supercronic

COPY imageporter.sh /app/imageporter.sh

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /usr/local/bin/crane \
    && chmod +x /usr/local/bin/supercronic \
    && chmod +x /app/imageporter.sh \
    && chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
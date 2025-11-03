FROM alpine:latest

LABEL maintainer="hello@blazesnow.com"
LABEL repository="https://github.com/blazesnow/ImagePorter"
LABEL description="A simple container to port container images between registries using Crane."
LABEL license="MIT"
LABEL version="2025.11.1.1"

ENV TZ="" \
    CRON="" \
    RUN_ONCE="" \
    ENABLE_FIRSTRUN="" \
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

COPY crane /usr/local/bin/crane

COPY supercronic /usr/local/bin/supercronic

COPY imageporter.sh /app/imageporter.sh

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /usr/local/bin/crane \
    && chmod +x /usr/local/bin/supercronic \
    && chmod +x /app/imageporter.sh \
    && chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
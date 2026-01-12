# 构建镜像
FROM golang:alpine AS builder

# 构建crane工具
# https://github.com/google/go-containerregistry/releases
RUN go install github.com/google/go-containerregistry/cmd/crane@v0.20.7

# 构建supercronic工具
# https://github.com/aptible/supercronic/releases
RUN go install github.com/aptible/supercronic@v0.2.41

# 运行镜像
FROM alpine:latest

# 开发信息
LABEL repository="https://github.com/imageporter/ImagePorter"
LABEL license="MIT"

# 环境变量
ENV TZ="Asia/Shanghai" \
    CRON="0 0 * * *" \
    RUN_ONCE="false" \
    DRY_RUN="false" \
    SLEEP_TIME="5" \
    RETRY_DELAY_TIME="5"

# 安装依赖
RUN apk --no-cache add jq tzdata

# 工作目录
RUN mkdir -p /app
WORKDIR /app

# 可执行文件
COPY --from=builder /go/bin/crane /usr/local/bin/crane
COPY --from=builder /go/bin/supercronic /usr/local/bin/supercronic

# 脚本文件
COPY entrypoint.sh /app/entrypoint.sh
COPY log.sh /app/log.sh
COPY checkenv.sh /app/checkenv.sh
COPY checkfile.sh /app/checkfile.sh
COPY login.sh /app/login.sh
COPY imageporter.sh /app/imageporter.sh
COPY crane.sh /app/crane.sh

# 赋予执行权限
RUN chmod +x /usr/local/bin/crane \
    && chmod +x /usr/local/bin/supercronic \
    && chmod +x /app/entrypoint.sh \
    && chmod +x /app/log.sh \
    && chmod +x /app/checkenv.sh \
    && chmod +x /app/checkfile.sh \
    && chmod +x /app/login.sh \
    && chmod +x /app/imageporter.sh \
    && chmod +x /app/crane.sh

# 验证工具
RUN crane version && supercronic -version

# 启动命令
ENTRYPOINT ["/app/entrypoint.sh"]
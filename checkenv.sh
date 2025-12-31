#!/bin/bash

set -e

source /app/log.sh

# 检查时区设置
if [ -z "$TZ" ]; then
	log WARNING "TZ未设置，默认：Asia/Shanghai"
	export TZ="Asia/Shanghai"
fi
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ >/etc/timezone

# 检查定时任务设置
if [ -z "$CRON" ]; then
	log WARNING "CRON未设置，默认：0 0 * * *"
	export CRON="0 0 * * *"
fi
touch /var/log/imageporter.log
echo "$CRON cd /app && ./imageporter.sh >> /var/log/imageporter.log 2>&1" >/app/imageporter.cron

# 检查启动时运行设置
if [ -z "$RUN_ONCE" ]; then
	log WARNING "RUN_ONCE未设置，默认：false"
	export RUN_ONCE="false"
fi

# 检查模拟运行设置
if [ -z "$DRY_RUN" ]; then
	log WARNING "DRY_RUN未设置，默认：false"
	export DRY_RUN="false"
fi

# 检查循环等待时间设置
if [ -z "$SLEEP_TIME" ]; then
	log WARNING "SLEEP_TIME未设置，默认：5"
	export SLEEP_TIME="5"
fi

log SUCCESS "环境变量检查完成"

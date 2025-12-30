#!/bin/sh

set -e

# 检查时区设置
if [ -z "$TZ" ]; then
	echo "⚠️ 警告：TZ未设置，默认：Asia/Shanghai"
	export TZ="Asia/Shanghai"
fi
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ >/etc/timezone

# 检查定时任务设置
if [ -z "$CRON" ]; then
	echo "⚠️ 警告：CRON未设置，默认：0 0 * * *"
	export CRON="0 0 * * *"
fi
touch /var/log/imageporter.log
echo "$CRON cd /app && ./imageporter.sh >> /var/log/imageporter.log 2>&1" >/app/imageporter.cron

# 检查启动时运行设置
if [ -z "$RUN_ONCE" ]; then
	echo "⚠️ 警告：RUN_ONCE未设置，默认：false"
	export RUN_ONCE="false"
fi

# 检查模拟运行设置
if [ -z "$DRY_RUN" ]; then
	echo "⚠️ 警告：DRY_RUN未设置，默认：false"
	export DRY_RUN="false"
fi

echo "✅ 环境变量检查完成"

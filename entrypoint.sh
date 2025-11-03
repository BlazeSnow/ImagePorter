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

# 检查目标仓库
if [ -z "$TARGET_REGISTRY" ]; then
	echo "❌ 错误：TARGET_REGISTRY未设置"
	exit 1
fi

# 检查目标仓库用户名与密码
if [ -z "$TARGET_USERNAME" ] || [ -z "$TARGET_PASSWORD" ]; then
	echo "❌ 错误：TARGET_USERNAME或TARGET_PASSWORD未设置，无法登录目标仓库"
	exit 1
fi

# 检查源仓库
if [ -z "$SOURCE_REGISTRY" ]; then
	echo "⚠️ 警告：SOURCE_REGISTRY未设置，默认：空"
	export SOURCE_REGISTRY=""
fi

# 检查源仓库用户名与密码
if [ -z "$SOURCE_USERNAME" ] || [ -z "$SOURCE_PASSWORD" ]; then
	echo "⚠️ 警告：SOURCE_USERNAME或SOURCE_PASSWORD未设置，将无法访问私有源仓库"
fi

# 开始运行
echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S')"

if [ "$RUN_ONCE" == "true" ]; then
	echo "⚠️ 已设置仅运行一次，正在运行镜像同步任务"
	/app/imageporter.sh
	echo "----------------------------------------"
	echo "$(date '+%Y-%m-%d %H:%M:%S')"
	echo "✅ 已完成一次镜像同步任务"
	echo "⚠️ 已设置仅运行一次，正在退出"
	exit 0
fi

echo "⚠️ 已禁用仅运行一次"
echo "🚀 正在启动supercronic服务"
supercronic --quiet /app/imageporter.cron &
echo "✅ 成功启动supercronic服务"
echo "🚀 正在监听log文件"
tail -f /var/log/imageporter.log

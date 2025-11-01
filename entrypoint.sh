#!/bin/sh

set -e

# 检查images.json文件
if [ ! -f images.json ]; then
	echo "❌ 错误：images.json不存在"
	exit 1
fi

# 检查images.json文件中的target有无重复
duplicate_targets=$(jq -r '.[].target' images.json | sort | uniq -d)
if [ -n "$duplicate_targets" ]; then
	echo "❌ 错误：target存在重复"
	echo "$duplicate_targets"
	exit 1
fi

# 检查时区设置
if [ -z "$TZ" ]; then
	echo "⚠️ 警告：TZ未设置，默认使用UTC"
	export TZ="UTC"
fi
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ >/etc/timezone

# 检查定时任务设置
if [ -z "$CRON" ]; then
	echo "⚠️ 警告：CRON未设置，默认每日0时执行一次"
	export CRON="0 0 * * *"
fi
echo 'MAILTO=""' >/app/imageporter.cron
echo "PATH=/usr/local/bin:/usr/bin:/bin" >>/app/imageporter.cron
echo "$CRON cd /app && ./imageporter.sh >> /var/log/imageporter.log 2>&1" >>/app/imageporter.cron
mkdir -p /root/.cache
touch /var/log/imageporter.log
crontab /app/imageporter.cron
rm /app/imageporter.cron

# 检查启动时运行设置
if [ -z "$DISABLE_FIRSTRUN" ]; then
	echo "⚠️ 警告：DISABLE_FIRSTRUN未设置，默认不在启动时运行"
	export DISABLE_FIRSTRUN="false"
fi

# 检查默认平台设置
if [ -z "$DEFAULT_PLATFORM" ]; then
	echo "⚠️ 警告：DEFAULT_PLATFORM未设置，默认使用linux/amd64"
	export DEFAULT_PLATFORM="linux/amd64"
fi

# 检查目标仓库
if [ -z "$TARGET_REGISTRY" ]; then
	echo "⚠️ 警告：TARGET_REGISTRY未设置，默认留空"
fi

# 检查目标仓库用户名与密码
if [ -z "$TARGET_USERNAME" ] || [ -z "$TARGET_PASSWORD" ]; then
	echo "❌ 错误：TARGET_USERNAME或TARGET_PASSWORD未设置，无法登录目标仓库"
	exit 1
fi

# 检查源仓库
if [ -z "$SOURCE_REGISTRY" ]; then
	echo "⚠️ 警告：SOURCE_REGISTRY未设置，默认为docker.io"
	export SOURCE_REGISTRY="docker.io"
fi

# 检查源仓库用户名与密码
if [ -z "$SOURCE_USERNAME" ] || [ -z "$SOURCE_PASSWORD" ]; then
	echo "⚠️ 警告：SOURCE_USERNAME或SOURCE_PASSWORD未设置，将无法访问私有源仓库"
fi

# 开始运行
echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S')"

if [ "$DISABLE_FIRSTRUN" != "true" ]; then
	echo "🚀 已允许启动时运行，正在运行镜像同步任务"
	/app/imageporter.sh
	echo "----------------------------------------"
fi

echo "🚀 正在启动cron服务"
crond
echo "✅ 成功启动cron服务"
echo "🚀 正在监听log文件"
tail -f /var/log/imageporter.log

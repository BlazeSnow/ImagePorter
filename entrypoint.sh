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
if [ -n "$TZ" ]; then
	echo "⚠️ 警告：TZ未设置，默认使用UTC"
	export TZ="UTC"
fi
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ >/etc/timezone

# 检查定时任务设置
if [ -n "$CRON" ]; then
	echo "⚠️ 警告：CRON未设置，默认每日0时执行一次"
	export CRON="0 0 * * *"
fi
echo "$CRON /app/imageporter.sh" >imageporter
crontab imageporter
rm imageporter

# 检查启动时运行设置
if [ -n "$DISABLE_FIRSTRUN" ]; then
	echo "⚠️ 警告：DISABLE_FIRSTRUN未设置，默认不在启动时运行"
	export DISABLE_FIRSTRUN="false"
fi

# 检查默认平台设置
if [ -n "$DEFAULT_PLATFORM" ]; then
	echo "⚠️ 警告：DEFAULT_PLATFORM未设置，默认使用linux/amd64"
	export DEFAULT_PLATFORM="linux/amd64"
fi

# 检查目标仓库、用户名与密码
if [ -n "$TARGET_REGISTRY" ] || [ -n "$TARGET_USERNAME" ] || [ -n "$TARGET_PASSWORD" ]; then
	echo "❌ 错误：TARGET_REGISTRY、TARGET_USERNAME或TARGET_PASSWORD未设置"
	exit 1
fi

# 检查源仓库
if [ -n "$SOURCE_REGISTRY" ]; then
	echo "⚠️ 警告：SOURCE_REGISTRY未设置，默认使用docker.io"
	export SOURCE_REGISTRY="docker.io"
fi

# 检查源仓库用户名与密码
if [ -n "$SOURCE_USERNAME" ] || [ -n "$SOURCE_PASSWORD" ]; then
	echo "⚠️ 警告：SOURCE_USERNAME或SOURCE_PASSWORD未设置，将无法访问私有源仓库"
fi

# 开始运行
if [ "$DISABLE_FIRSTRUN" != "true" ]; then
	echo "🚀 启动时运行镜像同步任务"
	/app/imageporter.sh
else
	echo "ℹ️ 启动时跳过镜像同步任务"
fi

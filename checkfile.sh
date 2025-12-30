#!/bin/sh

set -e

# 检查images.json文件是否存在
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

echo "✅ images.json文件检查通过"

# 检查accounts.json文件是否存在
if [ ! -f accounts.json ]; then
	echo "⚠️ 警告：accounts.json不存在"
fi

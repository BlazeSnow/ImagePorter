#!/bin/sh

set -e

source /app/log.sh

# 检查images.json文件是否存在
if [ ! -f images.json ]; then
	log ERROR "images.json不存在"
	exit 1
fi

# 检查images.json文件中的target有无重复
duplicate_targets=$(jq -r '.[].target' images.json | sort | uniq -d)
if [ -n "$duplicate_targets" ]; then
	log ERROR "target存在重复"
	log ERROR "$duplicate_targets"
	exit 1
fi

log INFO "images.json的target重复性检查通过"

log SUCCESS "images.json检查通过"

# 检查accounts.json文件是否存在
if [ ! -f accounts.json ]; then
	log ERROR "accounts.json不存在"
	exit 1
fi

# 检查accounts.json文件格式是否正确
if jq -e 'all(.[]; .username and .password and .registry)' accounts.json >/dev/null 2>&1; then
	log INFO "accounts.json格式正确"
else
	log ERROR "accounts.json格式不正确，缺少必要字段"
	exit 1
fi

log SUCCESS "accounts.json检查通过"

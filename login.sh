#!/bin/sh

set -e

source /app/log.sh

# 账户数量
count=$(jq '. | length' accounts.json)

# 循环处理每个账户
for i in $(seq 0 $((count - 1))); do
	# 设定变量
	USERNAME="$(jq -r ".[$i].username" accounts.json)"
	PASSWORD="$(jq -r ".[$i].password" accounts.json)"
	REGISTRY="$(jq -r ".[$i].registry" accounts.json)"

	# 登录目标仓库
	log INFO "正在登录目标仓库: $REGISTRY"
	echo "$PASSWORD" | crane auth login "$REGISTRY" -u "$USERNAME" --password-stdin 2>/dev/null
done

log SUCCESS "所有目标仓库登录完成"

#!/bin/sh

set -e

# 账户数量
count=$(jq '. | length' accounts.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do
	# 设定变量
	USERNAME="$(jq -r ".[$i].username" accounts.json)"
	PASSWORD="$(jq -r ".[$i].password" accounts.json)"
	REGISTRY="$(jq -r ".[$i].registry" accounts.json)"

	# 登录目标仓库
	echo "🚀 正在登录目标仓库: $REGISTRY"
	crane auth login --username "$USERNAME" --password "$PASSWORD" "$REGISTRY"
done

echo "✅ 所有目标仓库登录完成"

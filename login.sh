#!/bin/bash

set -e

source /app/log.sh

login() {
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

		# 测试登录是否有效
		if crane catalog "$REGISTRY" >/dev/null 2>&1; then
			log "SUCCESS" "验证成功：已成功连接至 $REGISTRY"
		else
			log "ERROR" "验证失败：无法访问 $REGISTRY，请检查凭据或网络"
		fi

	done

	log SUCCESS "所有目标仓库登录完成"
}

#!/bin/bash

set -e

source /app/log.sh
source /app/login.sh

login

# 镜像数量
count=$(jq '. | length' images.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do

	# 设定变量
	SOURCE="$(jq -r ".[$i].source" images.json)"
	TARGET="$(jq -r ".[$i].target" images.json)"

	# 使用crane获取digest
	SOURCE_digest=$(crane digest "$SOURCE" 2>/dev/null || true)
	TARGET_digest=$(crane digest "$TARGET" 2>/dev/null || true)

	# 分隔符
	log INFO "----------------------------------------"
	log INFO "源: $SOURCE"
	log INFO "源哈希: $SOURCE_digest"
	log INFO "目的地: $TARGET"
	log INFO "目的地哈希: $TARGET_digest"
	# 模拟运行
	if [ "$DRY_RUN" == "true" ]; then
		log WARNING "已设置模拟运行，跳过同步"
		continue
	fi

	# 相同则跳过
	if [ -n "$SOURCE_digest" ] && [ -n "$TARGET_digest" ] && [ "$SOURCE_digest" = "$TARGET_digest" ]; then
		log SUCCESS "源和目的地内容一致，跳过同步"

		# 等待
		log INFO "等待 $SLEEP_TIME 秒后处理下一个镜像"
		sleep "$SLEEP_TIME"
		continue
	fi

	# 同步镜像
	log INFO "开始同步镜像"
	success="false"
	for attempt in 1 2 3; do
		if GODEBUG=http2client=0 crane copy --jobs 1 "$SOURCE" "$TARGET"; then
			success="true"
			break
		fi
		log WARNING "第 $attempt 次尝试失败，$SLEEP_TIME 秒后重试..."
		sleep "$SLEEP_TIME"
	done

	if [ "$success" = "false" ]; then
		log ERROR "镜像同步最终失败"
		exit 1
	fi
	log SUCCESS "同步完成"

	# 等待
	log INFO "等待 $SLEEP_TIME 秒后处理下一个镜像"
	sleep "$SLEEP_TIME"

done

log SUCCESS "========================================"
log SUCCESS "🎉 全部镜像同步完成"
exit 0

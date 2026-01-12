#!/bin/sh

set -e

source /app/log.sh
source /app/login.sh
source /app/crane.sh

ARGS="$@"

failed_list=""

login

# 镜像数量
count=$(jq '. | length' images.json)

# 循环处理
for i in $(seq 0 $((count - 1))); do

	# 设定变量
	SOURCE="$(jq -r ".[$i].source" images.json)"
	TARGET="$(jq -r ".[$i].target" images.json)"

	# 使用crane获取digest
	SOURCE_digest=$(CraneDigest "$SOURCE" $ARGS)
	TARGET_digest=$(CraneDigest "$TARGET" $ARGS)

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
		log INFO "等待 $SLEEP_TIME 秒后处理"
		sleep "$SLEEP_TIME"
		continue
	fi

	# 同步镜像
	log INFO "开始同步镜像"
	success="false"
	for attempt in 1 2 3; do
		if [ CraneCopy "$SOURCE" "$TARGET" $ARGS = 0 ]; then
			success="true"
			break
		fi
		log WARNING "第 $attempt 次尝试失败"
		log WARNING "等待 $SLEEP_TIME 秒后处理"
		sleep "$SLEEP_TIME"
	done

	# 同步多次后失败
	if [ "$success" = "false" ]; then
		log ERROR "镜像同步最终失败"
		failed_list="$failed_list $TARGET"
		continue
	fi

	# 同步成功
	log SUCCESS "同步完成"

	# 等待
	log INFO "等待 $SLEEP_TIME 秒后处理下一个镜像"
	sleep "$SLEEP_TIME"

done

if [ -n "$failed_list" ]; then
	log ERROR "以下镜像同步失败: $failed_list"
	exit 1
fi

log SUCCESS "========================================"
log SUCCESS "全部镜像同步完成"
exit 0

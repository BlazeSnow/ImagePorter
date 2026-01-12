#!/bin/sh

set -e

source /app/log.sh
source /app/login.sh
source /app/crane.sh

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
	SOURCE_digest=$(CraneDigest "$SOURCE")
	TARGET_digest=$(CraneDigest "$TARGET")

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
		log SUCCESS "源和目的地内容一致，跳过同步，等待 $SLEEP_TIME 秒后处理"
		sleep "$SLEEP_TIME"
		continue
	fi

	# 同步镜像
	success="false"
	while [ "$success" = "false" ]; do
		# 首次尝试同步
		log INFO "开始尝试同步镜像"
		if CraneCopy "$SOURCE" "$TARGET"; then
			success="true"
			break
		fi
		log WARNING "第一次尝试失败，等待 $RETRY_DELAY_TIME 秒后处理"
		sleep "$RETRY_DELAY_TIME"

		# 第二次尝试同步
		log INFO "开始第二次尝试同步镜像"
		if CraneCopy "$SOURCE" "$TARGET"; then
			success="true"
			break
		fi
		log WARNING "第二次尝试失败，等待 $RETRY_DELAY_TIME 秒后处理"
		sleep "$RETRY_DELAY_TIME"

		# 第三次尝试同步
		log INFO "开始第三次尝试同步镜像，下载后上传，此方式需要较长时间"
		if CraneAdvancedCopy "$SOURCE" "$TARGET"; then
			success="true"
			break
		fi
		log WARNING "第三次尝试失败"
		break

	done

	# 同步多次后失败
	if [ "$success" = "false" ]; then
		log ERROR "镜像同步最终失败"
		failed_list="$failed_list $TARGET"
		continue
	fi

	# 同步成功
	log SUCCESS "同步完成，等待 $SLEEP_TIME 秒后处理下一个镜像"
	sleep "$SLEEP_TIME"

done

if [ -n "$failed_list" ]; then
	log ERROR "以下镜像同步失败: $failed_list"
	exit 1
fi

log SUCCESS "========================================"
log SUCCESS "全部镜像同步完成"
log SUCCESS "========================================"
exit 0

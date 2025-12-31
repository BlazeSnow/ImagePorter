#!/bin/sh

set -e

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
	echo "----------------------------------------"
	echo "$(date '+%Y-%m-%d %H:%M:%S')"
	echo "源镜像: $SOURCE"
	echo "digest: $SOURCE_digest"
	echo "目的地: $TARGET"
	echo "digest: $TARGET_digest"

	# 模拟运行
	if [ "$DRY_RUN" == "true" ]; then
		echo "⚠️ 已设置模拟运行，跳过同步"
		continue
	fi

	# 相同则跳过
	if [ -n "$SOURCE_digest" ] && [ -n "$TARGET_digest" ] && [ "$SOURCE_digest" = "$TARGET_digest" ]; then
		echo "✅ 源和目的地内容一致，跳过同步"

		# 等待
		echo "💤 等待 $SLEEP_TIME 秒后处理下一个镜像"
		sleep "$SLEEP_TIME"
		continue
	fi

	# 同步镜像
	echo "🔄 同步镜像"
	success=false
	for attempt in 1 2 3; do
		if GODEBUG=http2client=0 crane copy --jobs 1 "$SOURCE" "$TARGET"; then
			success=true
			break
		fi
		echo "⚠️ 第 $attempt 次尝试失败，5秒后重试..."
		sleep 5
	done

	if [ "$success" = false ]; then
		echo "❌ 镜像同步最终失败"
		exit 1
	fi
	echo "✅ 同步完成"

	# 等待
	echo "💤 等待 $SLEEP_TIME 秒后处理下一个镜像"
	sleep "$SLEEP_TIME"

done

echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S')"
echo "🎉 全部镜像同步完成"
echo "----------------------------------------"
exit 0

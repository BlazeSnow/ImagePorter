#!/bin/sh

set -ex

source /app/log.sh

CraneDigest() {
	local IMAGE=$1
	log INFO "获取镜像哈希"
	crane digest "$IMAGE" 2>/dev/null || true
}

CraneCopy() {
	local SOURCE=$1
	local TARGET=$2
	log INFO "使用 crane copy 同步镜像"
	crane copy --jobs 1 "$SOURCE" "$TARGET"
}

CraneAdvancedCopy() {
	local SOURCE=$1
	local TARGET=$2
	log INFO "使用 crane pull 和 push 同步镜像"
	crane pull "$SOURCE" /app/temp.tar
	crane push /app/temp.tar "$TARGET"
	rm -f /app/temp.tar
}

CraneDebugCopy() {
	local SOURCE=$1
	local TARGET=$2
	log INFO "使用 crane copy 调试模式同步镜像"
	crane copy --debug --jobs 1 "$SOURCE" "$TARGET"
}

#!/bin/sh

set -e

source /app/log.sh

sync() {
	local SOURCE=$1
	local TARGET=$2
	local message

	message=$(GODEBUG=http2client=0 crane copy --jobs 1 "$SOURCE" "$TARGET" 2>&1 >/dev/null)
	local status=$?

	if [ $status -eq 0 ]; then
		return 0
	else
		log "ERROR" "镜像同步失败：$message"
		return 1
	fi
}

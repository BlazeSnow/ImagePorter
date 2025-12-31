#!/bin/bash

set -e

source /app/log.sh

sync() {
	local SOURCE=$1
	local TARGET=$2
	local message

	GODEBUG=http2client=0 crane copy "$SOURCE" "$TARGET" 2>&1 | while read -r line; do
		if [[ $line == *"Pushed"* || $line == *"Already exists"* ]]; then
			log INFO "进度: $line"
		elif [[ $line == *"Error"* || $line == *"error"* ]]; then
			log ERROR "$line"
		fi
	done

	if [ ${PIPESTATUS[0]} -eq 0 ]; then
		return 0
	else
		log "ERROR" "镜像同步失败：$message"
		return 1
	fi
}

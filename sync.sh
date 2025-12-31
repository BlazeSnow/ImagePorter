#!/bin/bash

set -o pipefail

source /app/log.sh

sync() {
	local SOURCE=$1
	local TARGET=$2

	stdbuf -oL -eL GODEBUG=http2client=0 crane copy "$SOURCE" "$TARGET" 2>&1 | while read -r line; do
		case "$line" in
		*[Pp]ushed* | *[Cc]opying* | *[Ee]xists*)
			log INFO "$line"
			;;
		*[Rr]etrying* | *[Ee]rror*)
			log ERROR "$line"
			;;
		esac
	done

	local exit_code=$?
	if [ $exit_code -eq 0 ]; then
		return 0
	else
		log "ERROR" "镜像同步失败"
		return 1
	fi
}

#!/bin/bash

log() {
	# 定义颜色代码
	local RED='\033[0;31m'
	local GREEN='\033[0;32m'
	local YELLOW='\033[0;33m'
	local BLUE='\033[0;34m'
	local PURPLE='\033[0;35m'
	local NC='\033[0m' # 重置颜色

	local LEVEL=$1
	local MSG=$2
	local COLOR=$NC

	# 根据级别选择颜色
	case "$LEVEL" in
	"INFO") COLOR=$BLUE ;;
	"SUCCESS") COLOR=$GREEN ;;
	"WARNING") COLOR=$YELLOW ;;
	"ERROR") COLOR=$RED ;;
	"DEBUG") COLOR=$PURPLE ;;
	*) COLOR=$NC ;;
	esac

	# 打印格式化日志：[时间] [颜色级别] 内容
	if [ "$LEVEL" == "ERROR" ]; then
		printf "[$(date +'%Y-%m-%d %H:%M:%S')] ${COLOR}[%s]${NC} %s\n" "$LEVEL" "$MSG" >&2
	else
		printf "[$(date +'%Y-%m-%d %H:%M:%S')] ${COLOR}[%s]${NC} %s\n" "$LEVEL" "$MSG"
	fi
}

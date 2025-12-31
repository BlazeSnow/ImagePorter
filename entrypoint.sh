#!/bin/bash

set -e

source /app/log.sh

# 欢迎语
log INFO "========================================"
log INFO "欢迎使用 ImagePorter 镜像同步工具"
log INFO "文档地址：https://github.com/BlazeSnow/ImagePorter"
log INFO "作者：BlazeSnow"
log INFO "========================================"

# 检查环境变量
/app/checkenv.sh

# 检查必要文件
/app/checkfile.sh

# 开始运行

if [ "$RUN_ONCE" == "true" ]; then
	log WARNING "已设置仅运行一次，正在运行镜像同步任务"
	/app/imageporter.sh
	log INFO "已完成一次镜像同步任务"
	log WARNING "已设置仅运行一次，正在退出"
	exit 0
fi

log WARNING "已禁用仅运行一次"
log INFO "正在启动supercronic服务"
supercronic -quiet /app/imageporter.cron >/dev/null 2>&1 &
log SUCCESS "成功启动supercronic服务"
log INFO "正在监听log文件"
exec tail -f /var/log/imageporter.log

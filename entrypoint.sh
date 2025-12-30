#!/bin/sh

set -e

# 检查环境变量
/app/checkenv.sh

# 检查必要文件
/app/checkfile.sh

# 登录账户
/app/login.sh

# 开始运行
echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S')"

if [ "$RUN_ONCE" == "true" ]; then
	echo "⚠️ 已设置仅运行一次，正在运行镜像同步任务"
	/app/imageporter.sh
	echo "----------------------------------------"
	echo "$(date '+%Y-%m-%d %H:%M:%S')"
	echo "✅ 已完成一次镜像同步任务"
	echo "⚠️ 已设置仅运行一次，正在退出"
	exit 0
fi

echo "⚠️ 已禁用仅运行一次"
echo "🚀 正在启动supercronic服务"
supercronic --quiet /app/imageporter.cron &
echo "✅ 成功启动supercronic服务"
echo "🚀 正在监听log文件"
tail -f /var/log/imageporter.log

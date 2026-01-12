# 更新日志

## v2026.1.12.3

1. 添加arm64支持
2. 删去CGO_ENABLED=0参数
3. 版本号固定：
   1. crane@v0.20.7
   2. supercronic@v0.2.41

## v2026.1.12.2

1. 优化文件检查的输出内容
2. 添加legacy模式的同步方式
3. 修改第三次重试为legacy模式
4. 添加环境变量：RETRY_DELAY_TIME
5. 移除登录检查

## v2026.1.12.1

1. 部分镜像同步失败不会直接结束进程

## v2025.12.31.1

1. 重做了日志输出
2. 添加了同步失败重试的功能

## v2025.12.30.1

1. 启用DRY_RUN变量
2. 启用SLEEP_TIME变量
3. 弃用.env文件登录流程
4. 新登录流程使用accounts.json文件
5. 弃用环境变量：
   1. DEFAULT_PLATFORM
   2. SOURCE_REGISTRY
   3. SOURCE_USERNAME
   4. SOURCE_PASSWORD
   5. TARGET_REGISTRY
   6. TARGET_USERNAME
   7. TARGET_PASSWORD

## v2025.11.3.1

1. 禁用DISABLE_FIRSTRUN变量
2. 启用RUN_ONCE变量

## v2025.11.1.1

1. 发布的第一个版本

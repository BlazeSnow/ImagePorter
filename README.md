# ImagePorter

## 软件说明

ImagePorter是一个用于同步Docker镜像的Docker镜像，将docker.io、ghcr.io、gcr.io等仓库的镜像同步至设定的目的地仓库。

## 使用说明

> [!TIP]
> 推荐使用Docker Compose部署本软件

1. 创建应用目录：`mkdir -p /srv/imageporter`
2. 进入应用目录：`cd /srv/imageporter`
3. 创建`docker-compose.yml`文件
4. 创建`accounts.json`文件
5. 创建`images.json`文件
6. 运行本软件：`docker compose up -d`

### `docker-compose.yml`

```yml
services:
  imageporter:
    image: imageporter/imageporter:dev
    container_name: imageporter
    restart: no
    volumes:
      - ./images.json:/app/images.json:ro
      - ./accounts.json:/app/accounts.json:ro
    environment:
      TZ: "Asia/Shanghai"
      CRON: "0 0 * * *"
      RUN_ONCE: "false"
      DRY_RUN: "false"
      SLEEP_TIME: "5"
```

### `accounts.json`

```json
[
    {
        "username": "blazesnow",
        "password": "PASSWORD",
        "registry": "registry.cn-hangzhou.aliyuncs.com"
    },
    {
        "username": "blazesnow",
        "password": "PASSWORD",
        "registry": "docker.io"
    }
]
```

### `images.json`

```json
[
    {
        "source": "hello-world:latest",
        "target": "registry.cn-hangzhou.aliyuncs.com/blazesnow/hello-world:latest"
    },
    {
        "source": "busybox:latest",
        "target": "registry.cn-hangzhou.aliyuncs.com/blazesnow/busybox:latest"
    }
]
```

## 环境变量设计说明

1. `TZ`和`CRON`：共同作用于定时任务。
2. `RUN_ONCE`：运行本镜像时，是否忽略定时任务，并运行一次后退出。
3. `DRY_RUN`：跳过`crane`的同步操作，注意，本变量不可用于验证登录情况。
4. `SLEEP_TIME`：同步一次镜像后的等待时间

## 镜像的命名方式

### 源仓库的镜像

`images.json`的`source`

### 目标仓库的镜像

`images.json`的`target`

## 运行逻辑

1. 获取`accounts.json`中的仓库及账户密码
2. 使用`crane`进行登录
3. 获取镜像列表
4. 比较`target`的值有无重复
5. 比较源镜像和目标镜像的`digest`值，若相同则跳过同步
6. 使用`Crane`同步镜像

## 许可证

本软件使用 MIT 许可证

### 第三方软件许可证

- Crane 遵守其原有的许可证
- Supercronic 遵守其原有的许可证
- 所有未提及的第三方软件均遵守其原有的许可证

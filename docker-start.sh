#!/bin/bash

# 显示执行的命令
set -x

# 复制Docker环境的.env文件
cp .env.docker .env

# 停止所有正在运行的容器
docker-compose down

# 启动Docker容器
docker-compose up -d

# 检查容器是否启动成功
if [ $? -ne 0 ]; then
  echo "Docker容器启动失败，请检查错误信息"
  exit 1
fi

# 等待容器完全启动
echo "等待数据库容器启动..."

# 等待数据库准备就绪
MAX_RETRIES=30
RETRIES=0

while [ $RETRIES -lt $MAX_RETRIES ]
do
  echo "尝试连接数据库... (尝试 $((RETRIES+1))/$MAX_RETRIES)"
  if docker-compose exec db mysqladmin ping -h localhost -u root -p46284628 --silent; then
    echo "数据库连接成功！"
    break
  fi
  
  RETRIES=$((RETRIES+1))
  echo "数据库尚未就绪，等待 5 秒..."
  sleep 5
done

if [ $RETRIES -eq $MAX_RETRIES ]; then
  echo "数据库连接超时，请检查数据库容器日志"
  docker-compose logs db
  exit 1
fi

# 检查容器状态
if ! docker ps | grep webstack_app > /dev/null; then
  echo "应用容器未启动，请检查错误信息"
  exit 1
fi

if ! docker ps | grep webstack_db > /dev/null; then
  echo "数据库容器未启动，请检查错误信息"
  exit 1
fi

# 安装依赖
docker-compose exec app composer install

# 生成应用密钥
docker-compose exec app php artisan key:generate

# 运行数据库迁移和填充
docker-compose exec app php artisan migrate --seed

# 创建存储链接
docker-compose exec app php artisan storage:link

# 设置权限
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage

echo "WebStack-Laravel 已成功启动！"
echo "请访问 http://localhost:8000 查看网站"
echo "后台地址：http://localhost:8000/admin"
echo "默认用户：admin"
echo "默认密码：admin"
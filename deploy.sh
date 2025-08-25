#!/bin/bash

# 全球贸易导航网站一键发布脚本
# 作者：AI助手
# 创建日期：$(date +"%Y-%m-%d")

# 显示执行的命令
set -x

# 定义颜色
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # 无颜色

# 输出带颜色的消息函数
info() {
  echo -e "${GREEN}[信息]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[警告]${NC} $1"
}

error() {
  echo -e "${RED}[错误]${NC} $1"
}

# 检查命令是否存在
check_command() {
  if ! command -v $1 &> /dev/null; then
    error "命令 '$1' 未找到，请先安装"
    exit 1
  fi
}

# 检查必要的命令
check_command git
check_command docker
check_command docker-compose

# 确认部署
echo "=================================================="
echo "           全球贸易导航网站发布脚本             "
echo "=================================================="
echo ""
echo "此脚本将执行以下操作："
echo "1. 拉取最新代码"
echo "2. 构建并启动Docker容器"
echo "3. 运行数据库迁移和填充"
echo "4. 优化应用程序"
echo ""
read -p "是否继续? (y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  info "已取消部署"
  exit 0
fi

# 拉取最新代码
info "正在拉取最新代码..."
if [ -d ".git" ]; then
  git pull
  if [ $? -ne 0 ]; then
    error "拉取代码失败，请检查Git配置"
    exit 1
  fi
else
  warn "当前目录不是Git仓库，跳过代码拉取"
fi

# 复制环境配置文件
info "正在配置环境..."
if [ ! -f ".env" ]; then
  cp .env.docker .env
  info "已复制Docker环境配置文件"
else
  warn "环境配置文件已存在，跳过复制"
fi

# 停止并移除现有容器
info "正在停止现有容器..."
docker-compose down

# 构建并启动Docker容器
info "正在启动Docker容器..."
docker-compose up -d --build

# 检查容器是否启动成功
if [ $? -ne 0 ]; then
  error "Docker容器启动失败，请检查错误信息"
  exit 1
fi

# 等待数据库准备就绪
info "等待数据库准备就绪..."
MAX_RETRIES=30
RETRIES=0

while [ $RETRIES -lt $MAX_RETRIES ]
do
  echo "尝试连接数据库... (尝试 $((RETRIES+1))/$MAX_RETRIES)"
  if docker-compose exec db mysqladmin ping -h localhost -u root -p46284628 --silent; then
    info "数据库连接成功！"
    break
  fi
  
  RETRIES=$((RETRIES+1))
  echo "数据库尚未就绪，等待 5 秒..."
  sleep 5
done

if [ $RETRIES -eq $MAX_RETRIES ]; then
  error "数据库连接超时，请检查数据库容器日志"
  docker-compose logs db
  exit 1
fi

# 检查容器状态
if ! docker ps | grep webstack_app > /dev/null; then
  error "应用容器未启动，请检查错误信息"
  exit 1
fi

if ! docker ps | grep webstack_db > /dev/null; then
  error "数据库容器未启动，请检查错误信息"
  exit 1
fi

# 安装依赖
info "正在安装依赖..."
docker-compose exec app composer install --no-dev --optimize-autoloader

# 生成应用密钥（如果需要）
if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env; then
  info "正在生成应用密钥..."
  docker-compose exec app php artisan key:generate
fi

# 清除缓存
info "正在清除缓存..."
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan view:clear

# 运行数据库迁移
info "正在运行数据库迁移..."
docker-compose exec app php artisan migrate --force

# 询问是否需要重新填充数据
read -p "是否需要重新填充数据? (y/n): " seed_confirm
if [ "$seed_confirm" = "y" ] || [ "$seed_confirm" = "Y" ]; then
  info "正在填充数据..."
  docker-compose exec app php artisan db:seed --force
fi

# 创建存储链接
info "正在创建存储链接..."
docker-compose exec app php artisan storage:link

# 优化应用程序
info "正在优化应用程序..."
docker-compose exec app php artisan optimize

# 设置权限
info "正在设置权限..."
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage

# 部署完成
info "全球贸易导航网站已成功部署！"
echo "=================================================="
echo "网站地址：http://localhost:8000"
echo "后台地址：http://localhost:8000/admin"
echo "默认用户：admin"
echo "默认密码：admin"
echo "=================================================="

# 询问是否需要查看日志
read -p "是否需要查看应用日志? (y/n): " log_confirm
if [ "$log_confirm" = "y" ] || [ "$log_confirm" = "Y" ]; then
  docker-compose logs -f app
fi
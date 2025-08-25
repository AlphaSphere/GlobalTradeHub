#!/bin/bash

# 全球贸易导航网站一键发布脚本（传统部署版）
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
check_command composer
check_command php

# 确认部署
echo "=================================================="
echo "      全球贸易导航网站发布脚本（传统部署版）     "
echo "=================================================="
echo ""
echo "此脚本将执行以下操作："
echo "1. 拉取最新代码"
echo "2. 安装/更新依赖"
echo "3. 配置环境"
echo "4. 运行数据库迁移和填充"
echo "5. 优化应用程序"
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

# 复制环境配置文件（如果不存在）
info "正在检查环境配置..."
if [ ! -f ".env" ]; then
  cp .env.example .env
  info "已复制环境配置文件模板"
  warn "请手动编辑 .env 文件，配置数据库连接信息"
  read -p "按回车键继续..." continue_key
else
  info "环境配置文件已存在"
fi

# 安装/更新依赖
info "正在安装/更新依赖..."
composer install --no-dev --optimize-autoloader

# 生成应用密钥（如果需要）
if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=$" .env; then
  info "正在生成应用密钥..."
  php artisan key:generate
fi

# 清除缓存
info "正在清除缓存..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# 询问是否需要运行数据库迁移
read -p "是否需要运行数据库迁移? (y/n): " migrate_confirm
if [ "$migrate_confirm" = "y" ] || [ "$migrate_confirm" = "Y" ]; then
  info "正在运行数据库迁移..."
  php artisan migrate --force
  
  # 询问是否需要重新填充数据
  read -p "是否需要重新填充数据? (y/n): " seed_confirm
  if [ "$seed_confirm" = "y" ] || [ "$seed_confirm" = "Y" ]; then
    info "正在填充数据..."
    php artisan db:seed --force
  fi
fi

# 创建存储链接
info "正在创建存储链接..."
php artisan storage:link

# 优化应用程序
info "正在优化应用程序..."
php artisan optimize

# 设置权限
info "正在设置权限..."
chmod -R 775 storage bootstrap/cache

# 部署完成
info "全球贸易导航网站已成功部署！"
echo "=================================================="
echo "请使用以下命令启动开发服务器："
echo "php artisan serve"
echo ""
echo "或配置您的Web服务器（Apache/Nginx）指向此目录"
echo "=================================================="

# 询问是否需要启动开发服务器
read -p "是否需要启动开发服务器? (y/n): " serve_confirm
if [ "$serve_confirm" = "y" ] || [ "$serve_confirm" = "Y" ]; then
  info "正在启动开发服务器..."
  php artisan serve
fi
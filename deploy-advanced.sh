#!/bin/bash

# 全球贸易导航网站高级发布脚本
# 作者：AI助手
# 创建日期：$(date +"%Y-%m-%d")
# 功能：支持多环境部署、版本控制和回滚

# 显示执行的命令
set -x

# 定义颜色
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
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

header() {
  echo -e "${BLUE}$1${NC}"
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

# 默认环境
ENV="production"

# 获取当前时间戳作为版本号
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
VERSION="v${TIMESTAMP}"

# 部署目录
DEPLOY_DIR="./deployments"
CURRENT_DEPLOY="${DEPLOY_DIR}/${VERSION}"
BACKUP_DIR="${DEPLOY_DIR}/backups"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--env)
      ENV="$2"
      shift 2
      ;;
    -r|--rollback)
      ROLLBACK=true
      shift
      ;;
    -v|--version)
      ROLLBACK_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      echo "用法: $0 [选项]"
      echo "选项:"
      echo "  -e, --env ENV       指定部署环境 (development, testing, production)"
      echo "  -r, --rollback      执行回滚操作"
      echo "  -v, --version VER   指定回滚的版本"
      echo "  -h, --help          显示此帮助信息"
      exit 0
      ;;
    *)
      error "未知选项: $1"
      exit 1
      ;;
  esac
done

# 显示标题
header "=================================================="
header "        全球贸易导航网站高级发布脚本            "
header "=================================================="
echo ""

# 创建部署目录
mkdir -p "${DEPLOY_DIR}"
mkdir -p "${BACKUP_DIR}"

# 回滚功能
if [ "$ROLLBACK" = true ]; then
  header "执行回滚操作"
  
  # 列出可用的备份版本
  if [ -z "$ROLLBACK_VERSION" ]; then
    echo "可用的备份版本:"
    ls -lt "${BACKUP_DIR}" | grep -v total | awk '{print $9}'
    read -p "请输入要回滚的版本: " ROLLBACK_VERSION
  fi
  
  ROLLBACK_PATH="${BACKUP_DIR}/${ROLLBACK_VERSION}"
  
  if [ ! -d "$ROLLBACK_PATH" ]; then
    error "回滚版本 ${ROLLBACK_VERSION} 不存在"
    exit 1
  fi
  
  info "正在回滚到版本 ${ROLLBACK_VERSION}..."
  
  # 备份当前版本
  info "备份当前版本..."
  cp -r .env "${BACKUP_DIR}/env_before_rollback_${TIMESTAMP}"
  
  # 复制回滚版本的环境文件
  cp "${ROLLBACK_PATH}/.env" .
  
  # 停止当前容器
  info "停止当前容器..."
  docker-compose down
  
  # 启动容器
  info "启动容器..."
  docker-compose up -d
  
  info "回滚完成！当前版本: ${ROLLBACK_VERSION}"
  exit 0
fi

# 正常部署流程
header "开始部署到 ${ENV} 环境"

# 确认部署
echo "此脚本将执行以下操作："
echo "1. 拉取最新代码"
echo "2. 构建并启动Docker容器"
echo "3. 运行数据库迁移和填充"
echo "4. 优化应用程序"
echo "5. 创建版本备份"
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

# 备份当前环境配置
if [ -f ".env" ]; then
  info "备份当前环境配置..."
  cp .env "${BACKUP_DIR}/env_${TIMESTAMP}"
fi

# 复制环境配置文件
info "正在配置环境..."
ENV_FILE=".env.${ENV}"

if [ -f "${ENV_FILE}" ]; then
  cp "${ENV_FILE}" .env
  info "已复制 ${ENV} 环境配置文件"
else
  if [ "${ENV}" = "docker" ] && [ -f ".env.docker" ]; then
    cp .env.docker .env
    info "已复制Docker环境配置文件"
  else
    warn "环境配置文件 ${ENV_FILE} 不存在，使用默认配置"
    if [ ! -f ".env" ]; then
      cp .env.example .env
      info "已复制默认环境配置文件"
    fi
  fi
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

# 创建版本备份
info "正在创建版本备份..."
mkdir -p "${BACKUP_DIR}/${VERSION}"
cp .env "${BACKUP_DIR}/${VERSION}/"

# 记录部署信息
echo "版本: ${VERSION}" > "${BACKUP_DIR}/${VERSION}/deploy-info.txt"
echo "环境: ${ENV}" >> "${BACKUP_DIR}/${VERSION}/deploy-info.txt"
echo "部署时间: $(date)" >> "${BACKUP_DIR}/${VERSION}/deploy-info.txt"
echo "Git提交: $(git rev-parse HEAD)" >> "${BACKUP_DIR}/${VERSION}/deploy-info.txt"

# 部署完成
info "全球贸易导航网站已成功部署！版本: ${VERSION}"
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
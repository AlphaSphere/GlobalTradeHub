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

# 获取服务器公网地址
read -p "请输入服务器公网IP或域名 (不含http://和端口): " SERVER_HOST
if [ -z "$SERVER_HOST" ]; then
  warn "未提供服务器地址，将使用默认值 'localhost'"
  SERVER_HOST="localhost"
fi

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
  # 确保有足够权限
  if [ "$(whoami)" != "root" ]; then
    sudo chown -R $(whoami) .
  fi
  git pull
  if [ $? -ne 0 ]; then
    warn "拉取代码失败，可能是权限问题，继续执行部署流程"
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

# 更新环境配置中的APP_URL
# 检测操作系统类型并使用对应的sed命令语法
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS系统
  sed -i "" "s|APP_URL=http://localhost:8000|APP_URL=http://${SERVER_HOST}:8000|g" .env
else
  # Linux系统
  sed -i "s|APP_URL=http://localhost:8000|APP_URL=http://${SERVER_HOST}:8000|g" .env
fi
info "已更新环境配置中的APP_URL为 http://${SERVER_HOST}:8000"

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

# 修复Git仓库权限问题
info "正在配置Git仓库权限..."
docker-compose exec -T app bash -c "git config --global --add safe.directory /var/www/html"

# 安装依赖（修改这里，确保依赖正确安装）
info "正在安装依赖..."

# 确保 storage 和 bootstrap/cache 目录存在且可写
info "正在创建和设置 storage, bootstrap/cache 目录权限..."
docker-compose exec -T app bash -c "mkdir -p /var/www/html/storage/framework/{sessions,views,cache} && mkdir -p /var/www/html/bootstrap/cache"
docker-compose exec -T app bash -c "chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache"


# 尝试多种方式安装依赖
MAX_INSTALL_RETRIES=3
INSTALL_RETRIES=1
DEPENDENCIES_INSTALLED=false

while [ $INSTALL_RETRIES -le $MAX_INSTALL_RETRIES ] && [ "$DEPENDENCIES_INSTALLED" = false ]
do
  info "尝试安装依赖... (尝试 ${INSTALL_RETRIES}/${MAX_INSTALL_RETRIES})"

  # 清理旧的依赖和锁文件
  info "清理旧的依赖文件..."
  docker-compose exec -T -u root app bash -c "cd /var/www/html && rm -rf vendor composer.lock"

  # 确保composer缓存目录存在且可写
  info "以root用户配置Composer缓存目录和Git安全目录..."
  docker-compose exec -T -u root app bash -c "mkdir -p /var/www/.composer/cache && chown -R www-data:www-data /var/www && git config --global --add safe.directory /var/www/html"

  # 动态修改 composer.json
  info "正在动态配置 composer.json..."
  # 备份 composer.json
  cp composer.json composer.json.bak

  # 使用更可靠的 python 脚本来修改 json
  cat > composer_modifier.py << EOF
import json

with open('composer.json', 'r+') as f:
    data = json.load(f)
    
    # 设置 minimum-stability 和 prefer-stable
    data['minimum-stability'] = 'dev'
    data['prefer-stable'] = True
    
    # 添加或更新 repositories
    repo_url = "https://github.com/laravel-admin-extensions/editor"
    if 'repositories' not in data:
        data['repositories'] = []
        
    repo_exists = False
    for repo in data['repositories']:
        if repo.get('url') == repo_url:
            repo_exists = True
            break
            
    if not repo_exists:
        data['repositories'].append({
            "type": "vcs",
            "url": repo_url
        })
        
    f.seek(0)
    json.dump(data, f, indent=4)
    f.truncate()

print("composer.json 已成功更新。")
EOF

  python3 composer_modifier.py
  rm composer_modifier.py

  # 复制修改后的 composer.json 到容器
  info "复制更新后的 composer.json 到容器..."
  docker cp composer.json webstack_app:/var/www/html/

  # 根据尝试次数选择不同策略
  COMMAND=""
  case $INSTALL_RETRIES in
      1)
          # 第一次：正常安装
          COMMAND="composer install --no-dev --optimize-autoloader"
          ;;
      2)
          # 第二次：尝试更新，这可以解决一些锁文件问题
          warn "第二次尝试失败，尝试更新依赖而不是安装..."
          COMMAND="composer update --no-dev --ignore-platform-reqs"
          ;;
      3)
          # 第三次：终极大法，使用--no-scripts来避免脚本执行问题
          warn "第三次尝试失败，使用 --no-scripts 选项..."
          COMMAND="composer install --no-dev --no-scripts"
          ;;
  esac

  # 执行安装命令
  info "执行命令: ${COMMAND}"
  if docker-compose exec -T app bash -c "cd /var/www/html && ${COMMAND}"; then
      # 检查vendor目录是否存在
      if docker-compose exec -T app test -d /var/www/html/vendor; then
        info "依赖安装成功！"
        DEPENDENCIES_INSTALLED=true
      else
        warn "命令执行成功但vendor目录未创建，标记为失败。"
      fi
  else
    warn "依赖安装失败，准备下一次重试..."
  fi

  # 恢复 composer.json
  mv composer.json.bak composer.json
  
  INSTALL_RETRIES=$((INSTALL_RETRIES+1))
done

# 最终检查vendor目录
if [ "$DEPENDENCIES_INSTALLED" = false ]; then
  error "所有依赖安装尝试均失败，请检查以下几点："
  echo "1. 检查网络连接是否可以访问 a composer repository (e.g. packagist.org) 和 GitHub."
  echo "2. 查看上方具体的错误日志，分析失败原因。"
  echo "3. 尝试手动进入容器执行安装命令进行调试: docker-compose exec app bash"
  exit 1
fi

# 生成应用密钥（如果需要）
if ! grep -q "APP_KEY=" .env || grep -q "APP_KEY=.$" .env; then
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

# 部署完成
info "全球贸易导航网站已成功部署！"
echo "=================================================="
echo "网站地址：http://${SERVER_HOST}:8000"
echo "后台地址：http://${SERVER_HOST}:8000/admin"
echo "默认用户：admin"
echo "默认密码：admin"
echo "=================================================="
echo "请及时修改默认密码以确保安全"

# 询问是否需要查看日志
read -p "是否需要查看应用日志? (y/n): " log_confirm
if [ "$log_confirm" = "y" ] || [ "$log_confirm" = "Y" ]; then
  docker-compose logs -f app
fi
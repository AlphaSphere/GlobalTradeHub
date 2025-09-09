# Global Trade Hub

一个专业的全球贸易导航网站项目，具备完整的前后台，您可以拿来制作自己的网址导航。

![首页](public/screen/01.JPG)

## Docker部署

使用Docker可以快速部署应用，无需手动配置环境。

> **注意**：本项目基于PHP 7.4开发，如果您的服务器运行的是PHP 8.x版本，强烈建议使用Docker环境运行项目，以避免PHP版本不兼容问题。

### 前提条件

- 安装 [Docker](https://www.docker.com/get-started)
- 安装 [Docker Compose](https://docs.docker.com/compose/install/)

### 快速开始

1. 克隆代码：

```shell
git clone https://github.com/AlphaSphere/GlobalTradeHub.git
cd GlobalTradeHub
```

2. 启动Docker容器：

```shell
./docker-start.sh
```

这个脚本会自动完成以下操作：
- 启动所有必要的容器（PHP、Nginx、MySQL）
- 生成应用密钥
- 运行数据库迁移和填充
- 创建存储链接
- 设置正确的文件权限

3. 访问网站：

打开浏览器，访问 http://localhost:8080

### 手动启动

如果您想手动控制启动过程，可以执行以下命令：

```shell
# 启动容器
docker-compose up -d

# 生成应用密钥
```

## 常见问题解决

### Composer依赖安装问题

如果在部署过程中遇到Composer依赖安装失败，特别是与`laravel-admin-ext/editor`包相关的问题，可以尝试以下解决方案：

#### 解决方案1：使用deploy.sh脚本

我们的`deploy.sh`脚本已经包含了自动处理依赖问题的逻辑，会自动添加必要的配置：

```shell
# 使用部署脚本
bash deploy.sh
```

#### 解决方案2：手动修改composer.json

1. 添加`minimum-stability`和`prefer-stable`设置：

```json
{
    "name": "laravel/laravel",
    "description": "The Laravel Framework.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "type": "project",
    "minimum-stability": "dev",
    "prefer-stable": true,
    ...
}
```

2. 添加自定义仓库：

```json
{
    ...
    "repositories": [
        {
            "type": "vcs",
            "url": "https://github.com/laravel-admin-extensions/editor"
        }
    ],
    ...
}
```

3. 如果仍然失败，可以尝试移除问题包：

```shell
# 在容器内执行
docker-compose exec -T -u root app bash -c 'cd /var/www/html && rm -rf vendor composer.lock'
docker-compose exec -T app bash -c 'cd /var/www/html && composer install --no-dev --ignore-platform-reqs'
```
docker-compose exec app php artisan key:generate

# 运行数据库迁移
docker-compose exec app php artisan migrate --seed

# 创建存储链接
docker-compose exec app php artisan storage:link
```

### 2024-06-12: Composer依赖安装问题修复

#### 完成的主要任务
- 修复了`laravel-admin-ext/editor`包找不到的问题
- 改进了`deploy.sh`脚本中的依赖安装流程
- 添加了自动处理Composer依赖问题的机制
- 更新了README文档，添加了常见问题解决方案

#### 关键决策和解决方案
- 在composer.json中添加了`minimum-stability: "dev"`和`prefer-stable: true`设置
- 添加了自定义仓库配置，指向GitHub上的包源
- 在deploy.sh脚本中添加了多种尝试安装依赖的方法
- 提供了详细的错误处理和解决方案提示

#### 修改的文件
- composer.json: 添加了稳定性设置和自定义仓库
- deploy.sh: 改进了依赖安装流程和错误处理
- README.md: 添加了常见问题解决方案



# 创建存储链接
docker-compose exec app php artisan storage:link

# 设置权限
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage
```

## 传统部署

克隆代码：

```shell
git clone https://github.com/AlphaSphere/GlobalTradeHub.git
```

安装依赖：

```shell
composer install
php artisan key:generate  
```

编辑配置：

```
cp .env.example .env
```

```
...
DB_DATABASE=database
DB_USERNAME=username
DB_PASSWORD=password
...
```

迁移数据：

```shell
php artisan migrate:refresh --seed
```

开启服务：

```shell
php artisan serve
```

安装完成：http://127.0.0.1:8000


## 使用

后台地址：http://domain/admin

默认用户：admin

默认密码：admin462813

![分类](public/screen/02.JPG)

![网站](public/screen/03.JPG)


## 发布脚本使用说明

本项目提供了三种不同的发布脚本，满足不同的部署需求：

### 1. 基础Docker发布脚本

适用于简单的Docker环境部署：

```shell
./deploy.sh
```

此脚本会执行以下操作：
- 拉取最新代码
- 构建并启动Docker容器
- 运行数据库迁移和填充
- 优化应用程序

### 2. 传统部署脚本

适用于非Docker环境的传统部署方式：

```shell
./deploy-traditional.sh
```

此脚本会执行以下操作：
- 拉取最新代码
- 安装/更新依赖
- 配置环境
- 运行数据库迁移和填充
- 优化应用程序

### 3. 高级发布脚本

支持多环境部署和版本回滚功能：

```shell
# 部署到生产环境
./deploy-advanced.sh -e production

# 部署到测试环境
./deploy-advanced.sh -e testing

# 部署到开发环境
./deploy-advanced.sh -e development

# 执行回滚操作
./deploy-advanced.sh -r

# 回滚到指定版本
./deploy-advanced.sh -r -v v20240101123456

# 查看帮助信息
./deploy-advanced.sh -h
```

高级脚本的特点：
- 支持多环境部署（开发、测试、生产）
- 自动创建版本备份，便于回滚
- 提供回滚功能，可回滚到指定版本
- 详细的部署日志和错误处理

## License

MIT


## 项目部署记录

### 2024-10-22: Docker环境配置

#### 会话主要目的
- 将Global Trade Hub项目配置为可在Docker环境中运行
- 简化部署流程，提高开发和部署效率

#### 完成的主要任务
- 创建了Dockerfile配置PHP 7.4环境
- 创建了docker-compose.yml配置多容器应用（PHP、Nginx、MySQL）
- 配置了Nginx服务器设置，优化了Laravel应用的请求处理
- 创建了自动化项目启动脚本docker-start.sh
- 配置了Docker专用的环境变量，适配容器化环境
- 更新了项目文档，添加了Docker部署指南

#### 关键决策和解决方案
- 使用PHP 7.4-fpm镜像作为基础，确保与Laravel 5.5兼容
- 将数据库配置从本地连接调整为容器服务名连接
- 使用Docker卷挂载保证数据持久化
- 配置了适当的文件权限，确保Laravel应用正常运行
- 创建了自动化脚本简化部署流程

#### 使用的技术栈
- Docker & Docker Compose
- PHP 7.4-fpm
- Nginx 1.21-alpine
- MySQL 5.7
- Laravel 5.5

#### 修改的文件
- 新增 `/Dockerfile`
- 新增 `/docker-compose.yml`
- 新增 `/docker-start.sh`
- 新增 `/docker/nginx/conf.d/app.conf`
- 新增 `/docker/php/local.ini`
- 新增 `/docker/mysql/my.cnf`
- 修改 `/.env`
- 更新 `/README.md`

### 2024-10-23: Docker环境优化与问题解决

#### 会话主要目的
- 解决Docker环境中的数据库连接问题
- 优化容器配置，提高应用稳定性
- 确保Global Trade Hub在Docker环境中正常运行

#### 完成的主要任务
- 修复了数据库连接问题，确保应用能正确连接到MariaDB容器
- 优化了docker-compose.yml配置，解决了容器依赖关系
- 改进了docker-start.sh脚本，增加了容器状态检查和错误处理
- 解决了ARM64架构下的容器兼容性问题
- 成功部署并验证了Global Trade Hub的运行状态

#### 关键决策和解决方案
- 将MySQL数据库替换为MariaDB，解决了ARM64架构兼容性问题
- 调整了端口映射，避免端口冲突（从3306改为33061）
- 在docker-compose.yml中添加了depends_on配置，确保容器按正确顺序启动
- 在启动脚本中增加了容器状态检查，提高了部署的可靠性
- 优化了环境变量配置，确保数据库连接参数一致

#### 使用的技术栈
- Docker & Docker Compose
- PHP 7.4-fpm
- Nginx 1.21-alpine
- MariaDB 10.5（替代MySQL 5.7）
- Laravel 5.5

#### 修改的文件
- 更新 `/docker-compose.yml`：替换MySQL为MariaDB，调整端口映射
- 更新 `/docker-start.sh`：增加容器状态检查和错误处理
- 更新 `/.env.docker`：确保数据库连接参数一致
- 更新 `/README.md`：添加最新部署记录

### 2024-10-25: 发布脚本开发

#### 会话主要目的
- 开发一键发布脚本，简化项目部署流程
- 支持多种部署环境和场景
- 提高部署效率和可靠性

#### 完成的主要任务
- 创建了基础Docker发布脚本deploy.sh
- 创建了传统部署脚本deploy-traditional.sh
- 创建了高级发布脚本deploy-advanced.sh，支持多环境部署和版本回滚
- 更新了项目文档，添加了发布脚本使用说明

#### 关键决策和解决方案
- 基础脚本：针对Docker环境，提供简单直接的部署流程
- 传统脚本：针对非Docker环境，适用于传统服务器部署
- 高级脚本：添加了版本控制和回滚功能，适用于生产环境
- 所有脚本都添加了详细的日志输出和错误处理
- 使用彩色输出提高脚本可读性

#### 使用的技术栈
- Bash脚本
- Docker & Docker Compose
- Git版本控制

#### 修改的文件
- 新增 `/deploy.sh`
- 新增 `/deploy-traditional.sh`
- 新增 `/deploy-advanced.sh`
- 更新 `/README.md`

### 2024年代码优化记录

#### 优化内容
- 合并重复代码：修复了`SitesTableSeeder.php`中的重复URL（将Lstore的URL从`https://free.lstore.graphics/`更改为`https://www.lstore.graphics/`）
- 删除临时文件：移除了`cookies.txt`、`ExampleComponent.vue`和`ExampleTest.php`等临时文件
- 优化CSS：将`xenon-components.css`中的重复样式提取到单独的`xe-todo-list-optimized.css`文件中，减少了代码冗余
- 移除临时注释：清理了`xenon-toggles.js`中的临时演示注释

#### 优化效果
- 提高了代码可维护性
- 减少了文件体积和冗余代码
- 改进了CSS组织结构，使用了更现代的CSS技术
- 确保了所有功能正常运行，没有影响现有功能

### 2024年用户认证系统更新

#### 更新内容
- 完善后台登录功能：将后台登录功能与数据库对接
- 角色系统优化：创建了超级管理员和普通用户两种角色
- 用户管理：设置默认管理员账号(admin)密码为admin462813
- 权限控制：为不同角色分配不同权限，确保系统安全

#### 数据库表结构
- `admin_users`：存储用户信息，包括用户名、密码、头像等
- `admin_roles`：定义角色，包括超级管理员和普通用户
- `admin_permissions`：存储系统权限信息
- `admin_role_users`：用户与角色的关联表
- `admin_role_permissions`：角色与权限的关联表

#### 技术实现
- 使用Laravel内置的认证系统和中间件
- 采用bcrypt加密算法保护用户密码
- 通过数据库迁移和种子文件初始化用户数据
- 实现基于角色的访问控制(RBAC)


### 2023-11-15: 富文本编辑器优化

#### 会话主要目的
- 升级和优化系统中的富文本编辑器
- 解决CKEditor安全警告问题
- 提升编辑器功能和用户体验

#### 完成的主要任务
- 优化了CKEditor 4配置，提升了编辑体验和安全性
- 创建了自定义配置文件，实现更灵活的编辑器定制
- 添加了图片上传功能，支持直接在编辑器中上传图片
- 更新了缓存清理指南，帮助用户解决安全警告问题

#### 关键决策和解决方案
- **CKEditor版本选择**：CKEditor 4已于2023年6月达到生命周期结束(EOL)，最新开源版本为4.22.1。考虑到升级到CKEditor 5需要大量重构工作，我们选择优化当前的CKEditor 4配置，同时禁用版本检查警告。
- **自定义配置文件**：创建了`custom-ckeditor-config.js`文件，将编辑器配置从PHP代码中分离出来，便于后续维护和更新。
- **图片上传功能**：添加了专用的图片上传控制器和路由，支持直接在编辑器中上传图片，提升了内容编辑体验。
- **安全警告处理**：更新了`clear-cache.html`文件，添加了关于CKEditor安全警告的详细说明，帮助用户理解和解决问题。

#### 使用的技术栈
- CKEditor 4.22.1
- Laravel Admin
- PHP
- JavaScript

#### 修改的文件
- `/vendor/laravel-admin-ext/editor/src/Form/Field/Editor.php` - 优化编辑器初始化逻辑
- `/vendor/laravel-admin-ext/editor/ckeditor/ckeditor.js` - 更新CDN加载方式和注释
- `/public/js/custom-ckeditor-config.js` - 新增自定义配置文件
- `/public/clear-cache.html` - 更新缓存清理指南
- `/app/Admin/routes.php` - 添加图片上传路由
- `/app/Admin/Controllers/EditorController.php` - 新增图片上传控制器


### 2024-05-28: 网站底部信息更新

**会话目的**：更新网站底部信息为新的公司信息

**完成的任务**：
- 修改了网站所有页面的底部信息，包括index.blade.php、site/detail.blade.php和about.blade.php
- 统一了所有页面底部信息的格式和样式

**关键决策**：
- 保持了所有页面底部信息的一致性
- 使用了mailto链接使邮箱可点击
- 使用strong标签突出显示重要信息

**修改的文件**：
- /resources/views/index.blade.php
- /resources/views/site/detail.blade.php
- /resources/views/about.blade.php

### 2024-06-01: 网站Logo更新为Global Trade Hub

#### 会话目的
将网站的Logo和标题从WebStack更新为Global Trade Hub，统一品牌形象。

#### 完成的任务
1. 创建了新的Global Trade Hub SVG格式logo图片（标准版、折叠版和深色版）
2. 创建了新的favicon图标
3. 更新了网站标题、描述和元数据信息
4. 更新了所有页面中的logo图片路径

#### 关键决策
1. 使用SVG矢量格式替代原有的PNG格式，提高图片质量和加载速度
2. 在logo中添加了中文副标题"全球贸易中心"，增强品牌识别度
3. 统一了网站的Open Graph和Twitter Cards元数据，优化社交媒体分享效果

#### 使用的技术栈
- SVG矢量图形
- HTML/CSS
- Laravel Blade模板

#### 修改的文件
1. `/public/vendor/global-trade-hub/images/logo@2x.svg`（新建）
2. `/public/vendor/global-trade-hub/images/logo-collapsed@2x.svg`（新建）
3. `/public/vendor/global-trade-hub/images/logo_dark@2x.svg`（新建）
4. `/public/vendor/global-trade-hub/images/favicon.svg`（新建）
5. `/resources/views/layouts/sidebar.blade.php`（更新logo路径）
6. `/resources/views/about.blade.php`（更新logo路径）
7. `/resources/views/layouts/header.blade.php`（更新网站标题和元数据）

### 2024-06-02: Logo背景色更新

#### 会话目的
将网站Logo的背景色从蓝色更新为深灰色(#2c2e2e)，提升品牌形象的专业感。

#### 完成的任务
1. 修改了所有SVG格式Logo图片的背景色
2. 确保了颜色一致性和视觉协调性

#### 关键决策
1. 选择深灰色(#2c2e2e)作为新的品牌色，提升专业感和稳重感
2. 保持了文字颜色为白色，确保在深色背景上的可读性
3. 为深色版Logo调整了文字颜色，确保在白色背景上的对比度

#### 修改的文件
1. `/public/vendor/global-trade-hub/images/logo@2x.svg`（更新背景色）
2. `/public/vendor/global-trade-hub/images/logo-collapsed@2x.svg`（更新背景色）
3. `/public/vendor/global-trade-hub/images/logo_dark@2x.svg`（更新文字颜色）
4. `/public/vendor/global-trade-hub/images/favicon.svg`（更新背景色）
5. `/README.md`（添加更新记录）

### 2024-06-02: 代码推送到GitHub仓库

#### 会话目的
将Global Trade Hub项目代码推送到GitHub仓库，便于版本控制和团队协作。

#### 完成的任务
1. 更改了远程仓库地址为https://github.com/AlphaSphere/GlobalTradeHub.git
2. 提交了所有代码更改，包括Logo颜色更新和功能优化
3. 成功推送代码到GitHub仓库

#### 关键决策
1. 使用.gitignore文件排除了临时生成的文件，如node_modules、vendor和.env等
2. 提交了完整的项目代码，包括最近的Logo背景色更新

#### 使用的技术栈
- Git版本控制
- GitHub代码托管

#### 修改的文件
- 全部项目文件已推送至GitHub仓库
- README.md（添加代码推送记录）

### 2024-06-03: README.md更新与代码重新推送

#### 会话目的
更新README.md文件内容，统一项目名称为Global Trade Hub，并重新推送代码到GitHub仓库。

#### 完成的任务
1. 将README.md中的项目名称从WebStack-Laravel更新为Global Trade Hub
2. 更新了项目描述，强调全球贸易导航的专业性
3. 更新了GitHub仓库地址为https://github.com/AlphaSphere/GlobalTradeHub.git
4. 更新了后台默认密码信息
5. 重新推送代码到GitHub仓库

#### 关键决策
1. 保留了原有的部署说明和使用指南，确保用户可以顺利部署和使用项目
2. 统一了项目名称，确保品牌一致性
3. 更新了后台默认密码信息，提高安全性

#### 使用的技术栈
- Markdown文档
- Git版本控制

#### 修改的文件
- README.md（更新项目名称和相关信息）

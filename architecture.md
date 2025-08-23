# WebStack-Laravel 项目架构说明

## 1. 项目概述

WebStack-Laravel 是一个基于 Laravel 框架开发的网址导航网站，提供分类整理的网站导航功能。项目采用了现代化的开发架构，包括前端展示和后台管理系统，使用 Docker 容器化技术进行部署。

## 2. 技术栈

### 2.1 后端技术
- **PHP 7.4**：核心编程语言
- **Laravel**：PHP Web 应用框架
- **Laravel-Admin**：后台管理系统框架
- **MariaDB 10.5**：关系型数据库

### 2.2 前端技术
- **Bootstrap**：响应式前端框架
- **jQuery**：JavaScript 库
- **Font Awesome**：图标库
- **Blade 模板引擎**：Laravel 视图渲染

### 2.3 部署技术
- **Docker**：容器化部署
- **Nginx**：Web 服务器
- **Docker Compose**：多容器应用编排

## 3. 系统架构

### 3.1 整体架构

项目采用经典的 MVC（Model-View-Controller）架构模式，结合 Laravel 框架的特性，实现了前后端分离的设计理念。

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  表示层 (View)   |<--->|  控制层 (Controller) |<--->|  数据层 (Model)  |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
         ^                                               ^
         |                                               |
         v                                               v
+------------------+                           +------------------+
|                  |                           |                  |
|    用户界面      |                           |     数据库       |
|                  |                           |                  |
+------------------+                           +------------------+
```

### 3.2 Docker 部署架构

项目使用 Docker Compose 编排以下三个主要服务：

1. **app 服务**：PHP 7.4-FPM 应用容器，运行 Laravel 应用
2. **nginx 服务**：Web 服务器，处理 HTTP 请求并转发到 PHP-FPM
3. **db 服务**：MariaDB 数据库服务，存储应用数据

这三个服务通过 Docker 网络（webstack-network）互相连接，形成完整的应用栈。

## 4. 代码结构

### 4.1 目录结构

```
/
├── app/                    # 应用核心代码
│   ├── Admin/              # Laravel-Admin 后台管理代码
│   │   ├── Controllers/    # 后台控制器
│   │   └── routes.php      # 后台路由
│   ├── Http/               # HTTP 相关代码
│   │   ├── Controllers/    # 前端控制器
│   │   └── Middleware/     # 中间件
│   ├── Category.php        # 分类模型
│   └── Site.php            # 网站模型
├── config/                 # 配置文件
│   └── admin.php           # Laravel-Admin 配置
├── database/               # 数据库相关文件
│   ├── migrations/         # 数据库迁移文件
│   └── seeds/              # 数据库种子文件
├── docker/                 # Docker 配置文件
│   ├── nginx/              # Nginx 配置
│   └── php/                # PHP 配置
├── public/                 # 公共资源文件
│   └── vendor/             # 前端资源
├── resources/              # 资源文件
│   └── views/              # 视图文件
│       ├── index.blade.php # 首页视图
│       └── layouts/        # 布局文件
├── routes/                 # 路由文件
│   └── web.php             # Web 路由
├── docker-compose.yml      # Docker Compose 配置
├── Dockerfile              # Docker 镜像构建文件
└── README.md              # 项目说明文档
```

### 4.2 核心模型

项目主要包含两个核心模型：

1. **Category 模型**：网站分类
   - 实现了树形结构（ModelTree）
   - 与 Site 模型建立一对多关系

2. **Site 模型**：网站信息
   - 包含网站标题、描述、URL、缩略图等信息
   - 与 Category 模型建立多对一关系

### 4.3 管理员模型

项目使用 Laravel-Admin 提供的管理员模型和权限系统：

1. **Administrator**：管理员用户
2. **AdminRole**：管理员角色
3. **AdminPermission**：权限定义
4. **AdminMenu**：后台菜单

这些模型之间通过中间表建立多对多关系，实现了基于角色的访问控制（RBAC）。

## 5. 数据库设计

### 5.1 主要数据表

1. **sites 表**：存储网站信息
   - id：主键
   - category_id：分类ID（外键）
   - title：网站标题
   - thumb：网站缩略图
   - describe：网站描述
   - url：网站URL
   - created_at/updated_at：时间戳

2. **categories 表**：存储分类信息
   - id：主键
   - parent_id：父分类ID（自引用）
   - order：排序
   - title：分类标题
   - icon：分类图标
   - created_at/updated_at：时间戳

### 5.2 管理员相关表

1. **admin_users 表**：管理员用户
2. **admin_roles 表**：角色定义
3. **admin_permissions 表**：权限定义
4. **admin_menu 表**：后台菜单
5. **admin_role_users 表**：用户-角色关联
6. **admin_role_permissions 表**：角色-权限关联
7. **admin_user_permissions 表**：用户-权限关联
8. **admin_role_menu 表**：角色-菜单关联
9. **admin_operation_log 表**：操作日志

## 6. 前端架构

### 6.1 视图结构

前端视图采用 Blade 模板引擎，主要包含以下部分：

1. **layouts/header.blade.php**：页面头部，包含 CSS 和 JS 引用
2. **layouts/sidebar.blade.php**：侧边栏，显示分类导航
3. **layouts/content.blade.php**：主内容区，显示网站卡片
4. **index.blade.php**：首页模板，整合以上组件

### 6.2 静态资源

前端使用了多种静态资源：

- Bootstrap CSS 框架
- Font Awesome 图标
- jQuery JavaScript 库
- 自定义 CSS 和 JS 文件

## 7. 后台管理系统

### 7.1 Laravel-Admin 框架

项目使用 Laravel-Admin 构建后台管理系统，提供以下功能：

1. 用户认证和授权
2. 基于角色的权限控制
3. 菜单管理
4. 内容管理（分类和网站）
5. 操作日志

### 7.2 主要控制器

1. **CategoryController**：分类管理
   - 实现树形结构展示和编辑

2. **SiteController**：网站管理
   - 实现网站的 CRUD 操作

## 8. 部署架构

### 8.1 Docker 容器化

项目使用 Docker 和 Docker Compose 实现容器化部署，主要包含三个服务：

1. **PHP 应用容器**：
   - 基于 php:7.4-fpm 镜像
   - 安装必要的 PHP 扩展
   - 挂载项目代码和配置文件

2. **Nginx 容器**：
   - 基于 nginx:1.21-alpine 镜像
   - 配置虚拟主机和反向代理
   - 暴露 8000 端口

3. **MariaDB 容器**：
   - 基于 mariadb:10.5 镜像
   - 配置数据库名称和密码
   - 持久化数据存储

### 8.2 网络配置

所有容器通过自定义 Docker 网络（webstack-network）互相连接，实现服务间通信。

## 9. 安全架构

### 9.1 用户认证

后台管理系统使用 Laravel 的认证机制，包括：

1. 用户名和密码认证
2. 记住我功能
3. 密码加密存储（bcrypt）

### 9.2 授权控制

使用基于角色的访问控制（RBAC）：

1. 超级管理员角色（拥有所有权限）
2. 普通用户角色（拥有有限权限）
3. 细粒度的权限控制（基于路由和操作）

## 10. 总结

WebStack-Laravel 项目采用了现代化的 Web 开发架构，结合 Laravel 框架、Laravel-Admin 后台管理系统和 Docker 容器化技术，实现了一个功能完善、易于部署和维护的网址导航网站。项目架构清晰，代码组织合理，具有良好的可扩展性和可维护性。
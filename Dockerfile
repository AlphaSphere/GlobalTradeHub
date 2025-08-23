FROM php:7.4-fpm

# 设置工作目录
WORKDIR /var/www/html

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# 清理apt缓存
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装PHP扩展
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 获取最新的Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 设置工作目录权限
RUN chown -R www-data:www-data /var/www/html

# 设置用户
USER www-data

# 暴露端口
EXPOSE 9000

# 启动PHP-FPM
CMD ["php-fpm"]
<?php

use Illuminate\Routing\Router;

Admin::registerAuthRoutes();

Route::group([
    'prefix'        => config('admin.route.prefix'),
    'namespace'     => config('admin.route.namespace'),
    'middleware'    => config('admin.route.middleware'),
], function (Router $router) {

    $router->get('/', 'HomeController@index');
    $router->resource('categories', CategoryController::class);
    $router->resource('sites', SiteController::class);
    
    // 添加CKEditor图片上传路由
    $router->post('editor/upload', 'EditorController@upload');
});

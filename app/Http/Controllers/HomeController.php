<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Category;
use App\Site;

class HomeController extends Controller
{
    public function index()
    {
        return view('index', [
            'categories' => Category::with('children', 'sites')->get(),
        ]);
    }

    public function about()
    {
        return view('about');
    }
    
    public function siteDetail($id)
    {
        try {
            // 获取网站详情
            $site = Site::findOrFail($id);
            
            // 获取所有分类，用于侧边栏显示
            $categories = Category::with('children', 'sites')->get();
            
            return view('site.detail', [
                'site' => $site,
                'categories' => $categories, // 传递分类数据给视图
            ]);
        } catch (\Exception $e) {
            // 记录错误日志
            Log::error('网站详情页访问错误: ' . $e->getMessage());
            
            // 重定向到首页并显示错误消息
            return redirect('/')->with('error', '抱歉，您访问的网站不存在或已被删除');
        }
    }
}

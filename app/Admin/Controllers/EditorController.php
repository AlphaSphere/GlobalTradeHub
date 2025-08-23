<?php

namespace App\Admin\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class EditorController extends Controller
{
    /**
     * 处理CKEditor图片上传
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function upload(Request $request)
    {
        // 验证上传文件
        $request->validate([
            'upload' => 'required|image|max:2048', // 最大2MB
        ]);

        if ($request->hasFile('upload')) {
            $file = $request->file('upload');
            
            // 确保文件名安全
            $fileName = time() . '_' . preg_replace('/\s+/', '_', $file->getClientOriginalName());
            
            // 存储路径
            $path = public_path('uploads/images');
            
            // 确保目录存在
            if (!file_exists($path)) {
                mkdir($path, 0755, true);
            }
            
            // 移动文件到目标位置
            $file->move($path, $fileName);
            
            // 返回CKEditor所需的JSON响应
            return response()->json([
                'uploaded' => 1,
                'fileName' => $fileName,
                'url' => asset('uploads/images/' . $fileName)
            ]);
        }
        
        // 上传失败
        return response()->json([
            'uploaded' => 0,
            'error' => [
                'message' => '文件上传失败'
            ]
        ]);
    }
}
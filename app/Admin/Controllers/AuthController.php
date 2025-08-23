<?php

namespace App\Admin\Controllers;

use Encore\Admin\Controllers\AuthController as BaseAuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Lang;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class AuthController extends BaseAuthController
{
    /**
     * 显示登录页面
     * 
     * @return \Illuminate\Contracts\View\Factory|Redirect|\Illuminate\View\View
     */
    public function getLogin()
    {
        // 添加调试日志
        Log::info('访问登录页面');
        
        // 检查是否已经登录
        if ($this->guard()->check()) {
            Log::info('用户已登录，重定向到管理页面');
            return redirect(config('admin.route.prefix'));
        }
        
        // 返回登录视图
        return view('admin::login');
    }
    
    /**
     * 自定义登录处理逻辑
     * 
     * @param Request $request
     * 
     * @return \Illuminate\Http\Response
     */
    public function postLogin(Request $request)
    {
        // 添加调试日志
        Log::info('提交登录表单', $request->only(['username']));
        
        $credentials = $request->only(['username', 'password']);

        $validator = Validator::make($credentials, [
            'username' => 'required',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            Log::info('表单验证失败', $validator->errors()->toArray());
            return back()->withInput()->withErrors($validator);
        }

        if ($this->guard()->attempt($credentials)) {
            Log::info('登录成功');
            return $this->sendLoginResponse($request);
        }

        Log::info('登录失败');
        return back()->withInput()->withErrors([
            'username' => $this->getFailedLoginMessage(),
        ]);
    }

    /**
     * 获取登录失败消息
     * 
     * @return string
     */
    protected function getFailedLoginMessage()
    {
        return Lang::has('auth.failed')
            ? trans('auth.failed')
            : '用户名或密码错误';
    }

    /**
     * 发送登录成功响应
     * 
     * @param Request $request
     * 
     * @return \Illuminate\Http\Response
     */
    protected function sendLoginResponse(Request $request)
    {
        admin_toastr(trans('admin.login_successful'));

        $request->session()->regenerate();

        return redirect()->intended(config('admin.route.prefix'));
    }
}

<?php

use Illuminate\Database\Seeder;

class AdminUsersTableSeeder extends Seeder
{

    /**
     * Auto generated seed file
     *
     * @return void
     */
    public function run()
    {
        

        DB::table('admin_users')->delete();
        
        DB::table('admin_users')->insert(array (
            0 => 
            array (
                'id' => 1,
                'username' => 'admin',
                'password' => bcrypt('admin462813'), // 设置超级管理员密码为admin462813
                'name' => 'Administrator',
                'avatar' => NULL,
                'remember_token' => NULL,
                'created_at' => '2019-01-21 09:24:58',
                'updated_at' => date('Y-m-d H:i:s'),
            ),
            1 => 
            array (
                'id' => 2,
                'username' => 'user',
                'password' => bcrypt('user123'), // 设置普通用户密码为user123
                'name' => '普通用户',
                'avatar' => NULL,
                'remember_token' => NULL,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ),
        ));
        
        
    }
}
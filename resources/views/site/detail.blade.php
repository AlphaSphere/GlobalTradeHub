<!DOCTYPE html>
<html lang="zh">

@include('layouts.header')

<body class="page-body">
    <!-- skin-white -->
    <div class="page-container">

        @include('layouts.sidebar')

        <div class="main-content">
            <nav class="navbar user-info-navbar" role="navigation">
                <!-- User Info, Notifications and Menu Bar -->
                <!-- Left links for user info navbar -->
                <ul class="user-info-menu left-links list-inline list-unstyled">
                    <li class="hidden-sm hidden-xs">
                        <a href="#" data-toggle="sidebar">
                            <i class="fa fa-bars"></i>
                        </a>
                    </li>
                </ul>
            </nav>

            <div class="site-detail-container">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <div class="site-header">
                                    <div class="site-logo">
                                        <img src="/uploads/{{ $site->thumb ?? 'default.png' }}" class="img-circle" width="80" onerror="this.src='/vendor/web-stack/images/default-site.png'">
                                    </div>
                                    <div class="site-title">
                                        <h3>{{ $site->title }}</h3>
                                        <p class="site-category">分类：{{ $site->category ? $site->category->title : '未分类' }}</p>
                                    </div>
                                    <div class="site-header-actions">
                        <a href="{{ $site->url ?? '#' }}" target="_blank" class="btn btn-primary btn-sm" {{ !$site->url ? 'disabled' : '' }}>访问官网</a>
                        <a href="/" class="btn btn-default btn-sm back-btn">返回首页</a>
                    </div>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="site-content">
                                    <div class="site-description">
                                        <h4>网站介绍</h4>
                                        <div class="content-box">
                                            @if($site->content)
                                                <div class="rich-content">{!! $site->content !!}</div>
                                            @else
                                                <p>{{ $site->describe ?? '暂无描述' }}</p>
                                            @endif
                                        </div>
                                    </div>
                                    <!-- 按钮已移至标题行 -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Main Footer -->
            <footer class="main-footer sticky footer-type-1">
                <div class="footer-inner">
                    <!-- Add your copyright text here -->
                    <div class="footer-text">
                        Global Trade Hub &copy; 2025
                        <a href="mailto:jaden.ecc@gmail.com"><strong>jaden.ecc@gmail.com</strong></a> | 
                        <span><strong>微信号：GoodHabit_Lemon</strong></span> | 
                        <span><strong>WhatsApp：+86 18666877674</strong></span> | 
                        <span><strong>中国·东莞</strong></span>
                    </div>
                    <!-- Go to Top Link, just add rel="go-top" to any link to add this functionality -->
                    <div class="go-up">
                        <a href="#" rel="go-top">
                            <i class="fa fa-angle-up"></i>
                        </a>
                    </div>
                </div>
            </footer>
        </div>
    </div>
    
    <!-- 自定义样式 -->
    <style>
        .site-detail-container {
            padding: 20px;
        }
        .site-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .site-logo {
            margin-right: 20px;
        }
        .site-title h3 {
            margin: 0;
            color: #3498db;
        }
        .site-header-actions {
            margin-left: auto;
            display: flex;
            gap: 10px;
        }
        .rich-content {
            line-height: 1.6;
            color: #333;
        }
        .rich-content img {
            max-width: 100%;
            height: auto;
            margin: 10px 0;
        }
        .rich-content h1, .rich-content h2, .rich-content h3, .rich-content h4, .rich-content h5, .rich-content h6 {
            margin-top: 20px;
            margin-bottom: 10px;
            color: #2c3e50;
        }
        .rich-content p {
            margin-bottom: 15px;
        }
        .rich-content ul, .rich-content ol {
            margin-bottom: 15px;
            padding-left: 20px;
        }
        .rich-content blockquote {
            border-left: 4px solid #3498db;
            padding: 10px 15px;
            margin: 15px 0;
            background-color: #f8f9fa;
        }
        .rich-content a {
            color: #3498db;
            text-decoration: none;
        }
        .rich-content a:hover {
            text-decoration: underline;
        }
        .site-content {
            margin-top: 20px;
        }
        .site-description {
            margin-bottom: 20px;
            font-size: 16px;
            line-height: 1.6;
        }
        .site-description h4 {
            margin-bottom: 15px;
            color: #2c3e50;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .content-box {
            background-color: #f9f9f9;
            border-radius: 5px;
            padding: 15px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .site-action {
            margin-top: 30px;
            text-align: center;
        }
        .site-action .btn {
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 30px;
            transition: all 0.3s ease;
        }
        .site-action .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .site-action .back-btn {
            margin-left: 15px;
        }
        .site-category {
            color: #7f8c8d;
            font-size: 14px;
            margin-top: 5px;
        }
        .panel {
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .panel-heading {
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            background-color: #f5f5f5;
        }
    </style>
    
    <!-- 锚点平滑移动 -->
    <script type="text/javascript">
    $(document).ready(function() {
        $(document).on('click', '.has-sub', function(){
            var _this = $(this)
            if(!$(this).hasClass('expanded')) {
               setTimeout(function(){
                    _this.find('ul').attr("style","")
               }, 300);
              
            } else {
                $('.has-sub ul').each(function(id,ele){
                    var _that = $(this)
                    if(_this.find('ul')[0] != ele) {
                        setTimeout(function(){
                            _that.attr("style","")
                        }, 300);
                    }
                })
            }
        });
        
        $('.user-info-menu .hidden-sm').click(function(){
            if($('.sidebar-menu').hasClass('collapsed')) {
                $('.has-sub.expanded > ul').attr("style","")
            } else {
                $('.has-sub.expanded > ul').show()
            }
        });
        
        $("#main-menu a").each(function() {
            if($(this).parent().hasClass('has-sub') && $(this).attr('href') !== '#') {
                $(this).parent().addClass('has-sub');
            }
        });
        
        // 点击侧边栏链接时，跳转到首页对应位置
        $(".sidebar-menu a.smooth").click(function(e) {
            e.preventDefault();
            // 获取锚点
            var anchor = $(this).attr("href");
            // 如果当前不在首页，则跳转到首页并添加锚点
            if(window.location.pathname !== "/") {
                window.location.href = "/" + anchor;
            } else {
                // 如果在首页，执行平滑滚动
                $("html, body").animate({
                    scrollTop: $(anchor).offset().top - 30
                }, {
                    duration: 500,
                    easing: "swing"
                });
            }
            return false;
        });
    });
    </script>
    
    <!-- Bottom Scripts -->
    <script src="/vendor/web-stack/js/bootstrap.min.js"></script>
    <script src="/vendor/web-stack/js/TweenMax.min.js"></script>
    <script src="/vendor/web-stack/js/resizeable.js"></script>
    <script src="/vendor/web-stack/js/joinable.js"></script>
    <script src="/vendor/web-stack/js/xenon-api.js"></script>
    <script src="/vendor/web-stack/js/xenon-toggles.js"></script>
    <!-- JavaScripts initializations and stuff -->
    <script src="/vendor/web-stack/js/xenon-custom.js"></script>
</body>

</html>
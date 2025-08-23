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
                            <i class="fa-bars"></i>
                        </a>
                    </li>
                </ul>

            </nav>
            
            <!-- 显示错误消息 -->
            @if(session('error'))
            <div class="alert alert-danger">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                <strong>错误：</strong> {{ session('error') }}
            </div>
            @endif

            @include('layouts.content')
            
            
            <!-- Main Footer -->
            <!-- Choose between footer styles: "footer-type-1" or "footer-type-2" -->
            <!-- Add class "sticky" to  always stick the footer to the end of page (if page contents is small) -->
            <!-- Or class "fixed" to  always fix the footer to the end of page -->
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
        })
        $('.user-info-menu .hidden-sm').click(function(){
            if($('.sidebar-menu').hasClass('collapsed')) {
                $('.has-sub.expanded > ul').attr("style","")
            } else {
                $('.has-sub.expanded > ul').show()
            }
        })
        $("#main-menu li ul li").click(function() {
            $(this).siblings('li').removeClass('active'); // 删除其他兄弟元素的样式
            $(this).addClass('active'); // 添加当前元素的样式
        });
        $("a.smooth").click(function(ev) {
            ev.preventDefault();

            public_vars.$mainMenu.add(public_vars.$sidebarProfile).toggleClass('mobile-is-visible');
            ps_destroy();
            $("html, body").animate({
                scrollTop: $($(this).attr("href")).offset().top - 30
            }, {
                duration: 500,
                easing: "swing"
            });
        });
        return false;
    });

    var href = "";
    var pos = 0;
    $("a.smooth").click(function(e) {
        $("#main-menu li").each(function() {
            $(this).removeClass("active");
        });
        $(this).parent("li").addClass("active");
        e.preventDefault();
        href = $(this).attr("href");
        pos = $(href).position().top - 30;
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

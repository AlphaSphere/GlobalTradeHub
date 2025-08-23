/**
 * 自定义CKEditor配置文件
 * 用于优化CKEditor 4的功能和外观
 * 创建日期: 2023-11-15
 */

CKEDITOR.editorConfig = function(config) {
    // 基本设置
    config.language = 'zh-cn'; // 设置语言为中文
    config.height = 400; // 设置编辑器高度
    config.autoGrow_minHeight = 300; // 自动增长最小高度
    config.autoGrow_maxHeight = 800; // 自动增长最大高度
    config.autoGrow_onStartup = true; // 启动时自动增长
    
    // 禁用版本检查警告
    config.versionCheck = false;
    
    // 内容过滤设置
    config.allowedContent = true; // 允许所有内容，不过滤
    
    // 移除不需要的插件
    config.removePlugins = 'flash,iframe,smiley,specialchar';
    
    // 添加额外插件
    config.extraPlugins = 'autogrow,colorbutton,font,justify,uploadimage';
    
    // 简单模式工具栏配置
    config.toolbar_simple = [
        ['Bold', 'Italic', 'Underline', 'Strike', '-', 'RemoveFormat'],
        ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'],
        ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'],
        ['Link', 'Unlink'],
        ['TextColor', 'BGColor'],
        ['Styles', 'Format', 'Font', 'FontSize'],
        ['Image', 'Table'],
        ['Maximize', 'Source']
    ];
    
    // 完整模式工具栏配置
    config.toolbar_full = [
        ['Source', '-', 'Save', 'NewPage', 'Preview', 'Print', '-', 'Templates'],
        ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'],
        ['Find', 'Replace', '-', 'SelectAll', '-', 'Scayt'],
        ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat'],
        ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'],
        ['Link', 'Unlink', 'Anchor'],
        ['Image', 'Table', 'HorizontalRule', 'SpecialChar', 'PageBreak'],
        ['Styles', 'Format', 'Font', 'FontSize'],
        ['TextColor', 'BGColor'],
        ['Maximize', 'ShowBlocks']
    ];
    
    // 图片上传设置
    // 注意：需要在服务器端实现对应的上传处理逻辑
    config.filebrowserImageUploadUrl = '/admin/editor/upload?type=Images';
    
    // 其他设置
    config.resize_enabled = true; // 允许调整大小
    config.toolbarCanCollapse = true; // 工具栏可折叠
    config.removeDialogTabs = 'image:advanced;link:advanced'; // 移除对话框中的高级选项卡
};
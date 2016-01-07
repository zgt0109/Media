/*
利用如下片段生成后的元素应html如下：
img:
<a class="xcursor-move xscene-elem xscene-image" data-elemtype="img">
    <div class="xscene-elem-wrapp">
        <img class="xscene-img-img" src="../../assets_vscene_3.0.0/images/vscene_3.0.0/scene_elem_img_default.png" alt=""></div>
    <div class="xscene-elem-border"></div>
    <div class="xscene-elem-close xcursor-pointer">×</div>
</a>

txt:
<a class="xcursor-move xscene-elem xscene-text" data-elemtype="txt">
    <div class="xscene-elem-wrapp">这里显示您编辑的文字。。。</div>
    <div class="xscene-elem-border"></div>
    <div class="xscene-elem-close xcursor-pointer">×</div>
</a>

btn:
<a class="xcursor-move xscene-elem xpanel-btn1 xscene-button ui-draggable ui-draggable-handle xscene-elem-active" data-elemtype="btn">
    <div class="xscene-elem-wrapp">按钮</div>
    <div class="xscene-elem-border"></div>
    <div class="xscene-elem-close xcursor-pointer">×</div>
</a>
*/

// +++++ depend on xpanelsControls.js +++++
;(function(obj){
    var xsceneDespTpl = xconfig.xsceneDespTpl;

    obj.xelemModule = {
        // 元素必须有的class
        xelemClassesBase: 'xcursor-move xscene-elem {{elemTypeClass}}',
        // 元素的公共子元素
        xelemChildrenPublic: '<div class="xscene-elem-wrapp">{{elemChildren}}</div>\
                                <div class="xscene-elem-border"></div>\
                                <div class="xscene-elem-close xcursor-pointer">&#x00d7</div>',
        // 元素的种类class与其包含的子元素，顺序与控件的位置一致
        xelemDefault: [
            {
                typeClass: 'xscene-img',
                elemChildren: '<img class="xscene-img-img" src="' + xsceneDespTpl.img.props.src + '" alt="">',
                elemType: 'img'
            },
            {
                typeClass: 'xscene-txt',
                elemChildren: xsceneDespTpl.txt.props.html,
                elemType: 'txt'
            },
            {
                typeClass: 'xscene-btn ' + xsceneDespTpl.btn.props.addClass,
                elemChildren: xsceneDespTpl.btn.props.text,
                elemType: 'btn'
            },
            {
                typeClass: 'xscene-video ',
                elemChildren: '<img class="xscene-img-img" src="' + xsceneDespTpl.video.props.src + '" alt="">',
                elemType: 'video'
            }
        ]
    }
})( window.xconfig = window.xconfig ? window.xconfig : {} );
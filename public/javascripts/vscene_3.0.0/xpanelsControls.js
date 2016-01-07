;(function(obj){

    // 控制面板中各个control的模板
    obj.xpanelsControls = {
        slider: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xpanel-slider xradius"></div>\
                        <div class="xpanel-slider-val">{{controlVal}}</div>\
                    </div>\
                </div>',

        select: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-select"></div>\
                    </div>\
                </div>',

        zindex: '<div class="xclearfix xpanel-control xpanel-control-zindex">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-zindex">\
                            <div class="xtransition xpanel-zindex-item xpanel-zindex-first" data-title="置顶"></div>\
                            <div class="xtransition xpanel-zindex-item xpanel-zindex-last" data-title="置底"></div>\
                            <div class="xtransition xpanel-zindex-item xpanel-zindex-prev" data-title="上移"></div>\
                            <div class="xtransition xpanel-zindex-item xpanel-zindex-next" data-title="下移"></div>\
                        </div>\
                    </div>\
                </div>',

        text: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-text">\
                            <input type="text" class=" xradius xpanel-border xpanel-text-input" value="{{controlCnt}}">\
                        </div>\
                    </div>\
                </div>',

        color: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xnoselection xpanel-color">\
                            <div class="xradius xpanel-border xpanel-color-transparent"></div>\
                            <div class="xradius xpanel-border xpanel-color-transparent xpanel-color-show" data-color="{{controlColor}}"></div>\
                            <div class="xradius xpanel-color-button">设为透明</div>\
                        </div>\
                    </div>\
                </div>',

        editor: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xpanel-editor" id="xpanel-editor"></div>\
                    </div>\
                </div>',

        imgup: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xpanel-imgup">\
                            <img class="xpanel-imgup-img" src="{{controlSrc}}" alt="">\
                            <input class="xpanel-imgup-input" type="file">\
                            <div class="xpanel-imgup-percent"></div>\
                            <div class="xpanel-imgup-delete">删除</div>\
                        </div>\
                    </div>\
                </div>',

        btns: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-btns">\
                            <div class="xnoselection xpanel-btn xscene-btn1">样式1</div>\
                            <div class="xnoselection xpanel-btn xscene-btn2">样式2</div>\
                            <div class="xnoselection xpanel-btn xscene-btn3">样式3</div>\
                            <div class="xnoselection xpanel-btn xscene-btn4">样式4</div>\
                            <div class="xnoselection xpanel-btn xscene-btn5">样式5</div>\
                            <div class="xnoselection xpanel-btn xscene-btn6">样式6</div>\
                            <div class="xnoselection xpanel-btn xscene-btn7">样式7</div>\
                            <div class="xnoselection xpanel-btn xscene-btn8">样式8</div>\
                        </div>\
                    </div>\
                </div>',

        four: '<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-four">\
                            <div class="xpanel-four-wp">\
                                <div class="xpanel-four-center">文本内容</div>\
                                <div class="xpanel-four-input xpanel-four-inputt">\
                                    <input class="xpanel-four-txt" type="text" maxlength="2">\
                                    <div class="xpanel-four-triangle xpanel-four-triangleb"></div>\
                                    <div class="xpanel-four-triangle xpanel-four-trianglet"></div>\
                                </div>\
                                <div class="xpanel-four-input xpanel-four-inputr">\
                                    <input class="xpanel-four-txt" type="text" maxlength="2">\
                                    <div class="xpanel-four-triangle xpanel-four-triangler"></div>\
                                    <div class="xpanel-four-triangle xpanel-four-trianglel"></div>\
                                </div>\
                                <div class="xpanel-four-input xpanel-four-inputb">\
                                    <input class="xpanel-four-txt" type="text" maxlength="2">\
                                    <div class="xpanel-four-triangle xpanel-four-triangleb"></div>\
                                    <div class="xpanel-four-triangle xpanel-four-trianglet"></div>\
                                </div>\
                                <div class="xpanel-four-input xpanel-four-inputl">\
                                    <input class="xpanel-four-txt" type="text" maxlength="2">\
                                    <div class="xpanel-four-triangle xpanel-four-triangler"></div>\
                                    <div class="xpanel-four-triangle xpanel-four-trianglel"></div>\
                                </div>\
                            </div>\
                        </div>\
                    </div>\
                </div>',

        link:'<div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">{{controlName}}</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-link">\
                            <a class="xpanel-link" href="http://www.winwemedia.com/site/dev_logs/239">什么是视频通用代码？</a>\
                        </div>\
                        <div class="xclearfix xpanel-text">\
                            <input type="text" class=" xradius xpanel-border xpanel-text-input" value="">\
                        </div>\
                    </div>\
                </div>\
                <div class="xclearfix xpanel-control">\
                    <div class="xpanel-control-name">支持视频</div>\
                    <div class="xclearfix xpanel-control-entity">\
                        <div class="xclearfix xpanel-link">\
                            <a class="xpanel-link" href="">优酷</a>\
                            <a class="xpanel-link" href="">土豆</a>\
                            <a class="xpanel-link" href="">腾讯</a>\
                        </div>\
                    </div>\
                </div>'
    };

    // select control的模板
    var xcontrolSelectsTpl = obj.xcontrolSelectsTpl = {
        linkType: '<select class="xpanel-select-select xradius xpanel-border">\
                    <option value="none">无</option>\
                    <option value="http">链接</option>\
                    <option value="tel">电话</option>\
                    <option value="sys">系统链接</option>\
                </select>',

        link: '<select class="xpanel-select-select xradius xpanel-border">\
                    <optgroup label="微投票">\
                        <option value="http://微投票1">微投票1</option>\
                        <option value="http://微投票2">微投票2</option>\
                    </optgroup>\
                    <optgroup label="微报名">\
                        <option value="http://微报名1">微报名1</option>\
                        <option value="http://微报名2">微报名2</option>\
                    </optgroup>\
                    <optgroup label="微调研">\
                        <option value="http://微调研1">微调研1</option>\
                        <option value="http://微调研2">微调研2</option>\
                    </optgroup>\
                    <optgroup label="微预定">\
                        <option value="http://微调研1">微调研1</option>\
                        <option value="http://微调研2">微调研2</option>\
                    </optgroup>\
                </select>',

        animation: '<select class="xpanel-select-select xradius xpanel-border">\
                        <option value="none">无</option>\
                        <optgroup label="进入">\
                            <option value="fadeIn">淡入</option>\
                            <option value="zoomIn">中心放大</option>\
                            <option value="bounceIn">中心弹出</option>\
                        </optgroup>\
                        <optgroup label="滑入">\
                            <option value="slideLeft">划入：由左至右</option>\
                            <option value="slideRight">划入：由右至左</option>\
                            <option value="slideUp">划入：由上至下</option>\
                            <option value="slideDown">划入：由下至上</option>\
                        </optgroup>\
                        <optgroup label="弹入">\
                            <option value="elasticLeft">弹入：由左至右</option>\
                            <option value="elasticRight">弹入：由右至左</option>\
                            <option value="elasticUp">弹入：由上至下</option>\
                            <option value="elasticDown">弹入：由下至上</option>\
                        </optgroup>\
                        <optgroup label="旋转浮现">\
                            <option value="rotateClockwise">中心旋转：顺时针</option>\
                            <option value="rotateAnticlockwise">中心旋转：逆时针</option>\
                            <option value="rotateUp">横轴旋转：由上至下</option>\
                            <option value="rotateDown">横轴旋转：由下至上</option>\
                            <option value="rotateLeft">纵轴旋转：由左至右</option>\
                            <option value="rotateRight">纵轴旋转：由右至左</option>\
                        </optgroup>\
                        <option value="wobble">晃动</option>\
                        <option value="swing">抖动</option>\
                    </select>',

        align: '<select class="xpanel-select-select xradius xpanel-border">\
                    <option value="top">顶部对齐</option>\
                    <option value="middle">居中对齐</option>\
                    <option value="bottom">底部对齐</option>\
                </select>',
        bdstyle: '<select class="xpanel-select-select xradius xpanel-border">\
                    <option value="none">无</option>\
                    <option value="solid">实线</option>\
                    <option value="dashed">虚线</option>\
                </select>'
    };

    // 将xcontrolSelectsTpl中的link模板替换成系统真正的链接
    !function(){
        if(xconfig.xsceneLinks){
            xcontrolSelectsTpl.link = '<select class="xpanel-select-select xradius xpanel-border">';
            $.each(xconfig.xsceneLinks, function(key, value){
                var group = xconfig.xsceneLinks[key];

                $.each(group, function(key2, value2){
                    xcontrolSelectsTpl.link += '<optgroup label="' + key2 + '">';
                    $.each(value2, function(key3, value3){
                        xcontrolSelectsTpl.link += '<option value="'+ value3.url +'">'+ value3.name +'</option>';
                    });
                    xcontrolSelectsTpl.link += '</optgroup>';
                });
            });
            xcontrolSelectsTpl.link += '</select>';
        }
    }();


    // 定义元素对应的控制面板，及其control的属性
    obj.xpanelsControlsDefined = {
        img: [
            {name: '图片', type: 'imgup', attr: 'src', tabDivision: 0, tabName: '内容'},
            {name: '宽度比例', type: 'slider', css: 'width', unit: '%', min: 10, max: 100, step: 1},
            {name: '控件层级', type: 'zindex'},
            {name: '跳转类型', type: 'select', attr: 'data-href-type', control: 'control-link', selectType: 2, structure: xcontrolSelectsTpl.linkType},
            {name: '系统链接', type: 'select', attr: 'data-href-sys', controlled: 'control-link control-link-sys', selectType: 0, structure: xcontrolSelectsTpl.link, action: 'setSys'},
            {name: '自定义链接', type: 'text', attr: 'data-href-http', controlled: 'control-link control-link-http', placeholder: '请输入带http://的完整网址', action: 'setHttp'},
            {name: '联系电话', type: 'text', attr: 'data-href-tel', controlled: 'control-link control-link-tel', placeholder: '请输入联系电话', action: 'setTel'},
            {name: '动画效果', type: 'select', css: 'animationName', control: 'control-animation', selectType: 1, structure: xcontrolSelectsTpl.animation, tabDivision: 1, tabName: '动画'},
            {name: '开始时间', type: 'slider', css: 'animationDelay', controlled: 'control-animation control-animation-delay', unit: 's', min: 0, max: 10, step: 0.1},
            {name: '动画时长', type: 'slider', css: 'animationDuration', controlled: 'control-animation control-animation-duration', unit: 's', min: 0, max: 10, step: 0.1}
        ],
        txt: [
            {name: '编辑内容', type: 'editor', tabDivision: 0, tabName: '内容', action: 'setHtml'},
            {name: '控件层级', type: 'zindex'},
            {name: '跳转类型', type: 'select', attr: 'data-href-type', control: 'control-link', selectType: 2, structure: xcontrolSelectsTpl.linkType},
            {name: '系统链接', type: 'select', attr: 'data-href-sys', controlled: 'control-link control-link-sys', selectType: 0, structure: xcontrolSelectsTpl.link, action: 'setSys'},
            {name: '自定义链接', type: 'text', attr: 'data-href-http', controlled: 'control-link control-link-http', placeholder: '请输入带http://的完整网址', action: 'setHttp'},
            {name: '联系电话', type: 'text', attr: 'data-href-tel', controlled: 'control-link control-link-tel', placeholder: '请输入联系电话', action: 'setTel'},

            {name: '背景颜色', type: 'color', css: 'backgroundColor', tabDivision: 1, tabName: '样式'},
            {name: '宽度比例', type: 'slider', css: 'width', unit: '%', min: 10, max: 100, step: 1},
            {name: '高度', type: 'slider', css: 'height', unit: 'px', min: 10, max: 400, step: 1},
            {name: '垂直对齐', type: 'select', css: 'verticalAlign', selectType: 0, structure: xcontrolSelectsTpl.align},
            // {name: '边距（左）', type: 'slider', css: 'paddingLeft', unit: 'px', min: 0, max: 100, step: 1},
            // {name: '边距（右）', type: 'slider', css: 'paddingRight', unit: 'px', min: 0, max: 100, step: 1},
            // {name: '边距（上）', type: 'slider', css: 'paddingTop', unit: 'px', min: 0, max: 100, step: 1},
            // {name: '边距（下）', type: 'slider', css: 'paddingBottom', unit: 'px', min: 0, max: 100, step: 1},
            {name: '文本边距', type: 'four', css: 'padding'},
            {name: '边框样式', type: 'select', css: 'borderStyle', control: 'control-bdstyle', selectType: 1, structure: xcontrolSelectsTpl.bdstyle},
            {name: '边框颜色', type: 'color', css: 'borderColor', controlled: 'control-bdstyle'},
            {name: '边框宽度', type: 'slider', css: 'borderWidth', controlled: 'control-bdstyle', unit: 'px', min: 1, max: 100, step: 1},
            // {name: '透明度', type: 'slider', css: 'opacity', unit: '%', min: 0, max: 100, step: 1},

            {name: '动画效果', type: 'select', css: 'animationName', control: 'control-animation', selectType: 1, structure: xcontrolSelectsTpl.animation, tabDivision: 2, tabName: '动画'},
            {name: '开始时间', type: 'slider', css: 'animationDelay', controlled: 'control-animation control-animation-delay', unit: 's', min: 0, max: 10, step: 0.1},
            {name: '动画时长', type: 'slider', css: 'animationDuration', controlled: 'control-animation control-animation-duration', unit: 's', min: 0, max: 10, step: 0.1}
        ],
        btn: [
            {name: '按钮名称', type: 'text', tabDivision: 0, tabName: '内容', placeholder: '按钮名称', action: 'setText'},
            {name: '控件层级', type: 'zindex'},
            {name: '跳转类型', type: 'select', attr: 'data-href-type', control: 'control-link', selectType: 2, structure: xcontrolSelectsTpl.linkType},
            {name: '系统链接', type: 'select', attr: 'data-href-sys', controlled: 'control-link control-link-sys', selectType: 0, structure: xcontrolSelectsTpl.link, action: 'setSys'},
            {name: '自定义链接', type: 'text', attr: 'data-href-http', controlled: 'control-link control-link-http', placeholder: '请输入带http://的完整网址', action: 'setHttp'},
            {name: '联系电话', type: 'text', attr: 'data-href-tel', controlled: 'control-link control-link-tel', placeholder: '请输入联系电话', action: 'setTel'},
            {name: '按钮样式', type: 'btns', tabDivision: 1, tabName: '样式'},
            {name: '按钮字号', type: 'slider', css: 'fontSize', unit: 'px', min: 12, max: 32, step: 1},
            {name: '宽度比例', type: 'slider', css: 'width', unit: '%', min: 10, max: 100, step: 1},
            {name: '动画效果', type: 'select', css: 'animationName', control: 'control-animation', selectType: 1, structure: xcontrolSelectsTpl.animation, tabDivision: 2, tabName: '动画'},
            {name: '开始时间', type: 'slider', css: 'animationDelay', controlled: 'control-animation control-animation-delay', unit: 's', min: 0, max: 10, step: 0.1},
            {name: '动画时长', type: 'slider', css: 'animationDuration', controlled: 'control-animation control-animation-duration', unit: 's', min: 0, max: 10, step: 0.1},
        ],
        video: [
            {name: '预览图', type: 'imgup', attr: 'src', tabDivision: 0, tabName: '视频'},
            {name: '宽度比例', type: 'slider', css: 'width', unit: '%', min: 10, max: 100, step: 1},
            {name: '通用代码', type: 'link', attr: 'data-video', controlled: 'control-video', placeholder: '将视频的通用代码粘贴到这里', action: 'setHttp'},
            {name: '动画效果', type: 'select', css: 'animationName', control: 'control-animation', selectType: 1, structure: xcontrolSelectsTpl.animation, tabDivision: 2, tabName: '动画'},
            {name: '开始时间', type: 'slider', css: 'animationDelay', controlled: 'control-animation control-animation-delay', unit: 's', min: 0, max: 10, step: 0.1},
            {name: '动画时长', type: 'slider', css: 'animationDuration', controlled: 'control-animation control-animation-duration', unit: 's', min: 0, max: 10, step: 0.1}
        ],
        scene: [
            {name: '背景图片', type: 'imgup', css: 'backgroundImage', tabDivision: 0, tabName: '页面设置'},
            {name: '背景颜色', type: 'color', css: 'backgroundColor'},
            {name: '跳转类型', type: 'select', attr: 'data-href-type', control: 'control-link', selectType: 2, structure: xcontrolSelectsTpl.linkType},
            {name: '系统链接', type: 'select', attr: 'data-href-sys', controlled: 'control-link control-link-sys', selectType: 0, structure: xcontrolSelectsTpl.link, action: 'setSys'},
            {name: '自定义链接', type: 'text', attr: 'data-href-http', controlled: 'control-link control-link-http', placeholder: '请输入带http://的完整网址', action: 'setHttp'},
            {name: '联系电话', type: 'text', attr: 'data-href-tel', controlled: 'control-link control-link-tel', placeholder: '请输入联系电话', action: 'setTel'}
        ]
    }

    // select的selectType的四个值含义
        // 0表示单纯的设置值
        // 1表示用value=none来控制其他control的显示，其他的value均用来设置值
        // 2表示用value=none来控制其他control的显示，其他的value用来控制特定control的显示
        // 3表示包括多个对control显示的控制和多个值得设置

})( window.xconfig = window.xconfig ? window.xconfig : {} );
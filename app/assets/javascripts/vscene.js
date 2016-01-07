var utils = {};
utils.color = {
    colorFormat: function(color, format) { //color[rgba format|rgb format|hex format], format["rgba"|"rgb"|"hex"]

        var expRgba = /^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d?\.?\d*)\s*\)$/i;
        var expRgb = /^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i;
        var expHex = /(^#[\d|a-f]{3}$)|(^#[\d|a-f]{6}$)/i;

        var result = false;
        var resultColor = "error";
        var colorObj = {};
        var hexStep = 2;

        var hex = function(x) {
            return ("0" + parseInt(x).toString(16)).slice(-2);
        }

        if (result = color.match(expRgba)) {
            colorObj = {
                r: Number(result[1]),
                g: Number(result[2]),
                b: Number(result[3]),
                a: parseFloat(result[4])
            };
        } else if (result = color.match(expRgb)) {
            colorObj = {
                r: Number(result[1]),
                g: Number(result[2]),
                b: Number(result[3]),
                a: 1
            };
        } else if (result = color.match(expHex)) {
            if (color.length == 4) {
                hexStep = 1;
            }

            colorObj = {
                r: Number("0x" + color.substring(1, 1 + 1 * hexStep)),
                g: Number("0x" + color.substring(1 + 1 * hexStep, 1 + 2 * hexStep)),
                b: Number("0x" + color.substring(1 + 2 * hexStep, 1 + 3 * hexStep)),
                a: 1
            };
        }

        if (format === "rgba") {
            resultColor = "rgba(" + colorObj.r + "," + colorObj.g + "," + colorObj.b + "," + colorObj.a + ")";
        } else if (format === "rgb") {
            resultColor = "rgba(" + colorObj.r + "," + colorObj.g + "," + colorObj.b + ")";
        } else if (format == "hex") {
            resultColor = "#" + hex(colorObj.r) + hex(colorObj.g) + hex(colorObj.b);
        } else {
            resultColor = "error";
        }

        return resultColor;
    },
    colorObjToRGBA: function(o) {
        return "rgba(" + o.r + ", " + o.g + ", " + o.b + ", " + o.a + ")";
    }
};

$(function() {

    pageViewInit();
    // migration(); // 数据迁移js
    $(".add-page").on("click", function() {
        // 添加新页面
        var $this = $(this),
            $pageBox = $(".page-view"),
            boxWidth = $pageBox.width(),
            html = '<div class="page edit"><section class="page-main"></section></div>',
            $slideBtn = $(".swipe-left,.swipe-right");
        if ($pageBox.find(".page").length > 0) {
            $pageBox.css("width", boxWidth + 320).animate({
                "left": -boxWidth
            }, 500);
        } else {
            $pageBox.empty();
        }
        $pageBox.append(html);
        $this.addClass("hide").next().removeClass("hide");
        editInit();
        $slideBtn.hide();
    });
    $(".phone-main").on("click", ".page-edit", function() {
        // 编辑页面
        var $this = $(this),
            $tool = $this.parent(),
            $page = $this.parents(".page"),
            $slideBtn = $(".swipe-left,.swipe-right");
        $tool.remove();
        $slideBtn.hide();
        $page.addClass("edit");
        $(".add-page").addClass("hide").next().removeClass("hide");
        editInit();
    }).on("click", ".page-delet", function() {
        // 删除页面
        var $this = $(this),
            $page = $this.parents(".page"),
            $pageView = $page.parent(),
            $len = $page.siblings().length,
            pageViewWidth = parseInt($pageView.width()),
            pageViewLeft = parseInt($pageView.css("left"));
        renderModal({
            id: "delPage",
            title: "系统提示",
            text: "确定要删除吗?",
            btns: 2,
            selector: self
        });
        $("#delPage").find("[data-fn=submit]").on("click", function(e) {
            if ($len == 0) {
                var temp = '<p class="empty">你的场景还是空的，<br>赶紧点击下边按钮添加一个页面吧！</p>';
                $pageView.html(temp);
                temp = "";
            } else {
                if (pageViewLeft + pageViewWidth <= 320) {
                    $pageView.animate({
                        "left": pageViewLeft + 320,
                        "width": pageViewWidth - 320
                    }, 500, function() {
                        $page.remove();
                        save();
                    });
                } else {
                    $page.animate({
                        "width": 0
                    }, 500, function() {
                        $page.remove();
                        save();
                    });
                    $pageView.animate({
                        "width": pageViewWidth - 320
                    }, 500);
                }
            }
            hideModals("#delPage");
            e.preventDefault();
        });
    });
    var isAnimate = false;
    $(".swipe-left,.swipe-right").on("click", function() {
        // 切换页面
        var $this = $(this),
            $box = $(".page-view"),
            width = parseInt($box.width()),
            left = parseInt($box.css("left")) || 0;
        if (!isAnimate) {
            if ($this.is(".swipe-right") && width + left > 320) {
                isAnimate = true;
                $box.animate({
                    "left": left - 320
                }, 500, function() {
                    isAnimate = false;
                });
            }
            if ($this.is(".swipe-left") && left <= -320) {
                isAnimate = true;
                $box.animate({
                    "left": left + 320
                }, 500, function() {
                    isAnimate = false;
                });
            }
        }
    });
    $(".save-page").on("click", function() {
        // 保存
        var $this = $(this),
            $rightBox = $(".custom-right"),
            $page = $(".page.edit"),
            $slideBtn = $(".swipe-left,.swipe-right"),
            $tools = '<div class="page-setting"> <a href="javascript:;" class="page-edit"> <i></i> <span>编辑</span> </a> <a href="javascript:;" class="page-delet"> <i></i> <span>删除</span> </a> <div class="page-index">第<span></span>页</div> </div>';
        if ($("#editorMini").length) {
            initText.destroy();
        }
        $rightBox.off(); // 移除所有custom-right上的事件和代理事件
        $rightBox.empty();
        $slideBtn.show();
        $page.find(".active").removeClass("active");
        $page.removeClass("edit").append($tools);
        $this.addClass("hide").prev().removeClass("hide");
        $(".toolbar .add-modular").draggable("destroy");
        save();
    });
});

function save() {
    var saveHtml = $(".page-view").html(),
        temp = $("<div></div>"),
        callback = $(".save-page").attr("data-fn"),
        html = "";
    temp.append(saveHtml).find(".module-control,.page-setting").remove();
    temp.find(".map-content").empty().removeAttr("style");
    html = temp.html();
    window[callback](html);
}

function pageViewInit() {
    // 加载数据之后初始化，添加拖动元素，提示层
    var $box = $(".page-view"),
        $page = $box.find(".page"),
        len = $page.length || 1,
        boxWidth = len * 320;
    $modul = $(".module"),
        $control = '<div class="module-control"> <span class="module-move"></span> <span class="module-delete"><i class="fa fa-times"></i></span> </div>',
        $tool = '<div class="page-setting"> <a href="javascript:;" class="page-edit"> <i></i> <span>编辑</span> </a> <a href="javascript:;" class="page-delet"> <i></i> <span>删除</span> </a> <div class="page-index">第<span></span>页</div> </div>';
    $page.append($tool);
    $modul.prepend($control);
    $box.width(boxWidth);
}

function editInit() {
    dragMod();
    setPanel = setPanelFn();
    setPanel.init();
    // 初始化编辑状态，添加拖动效果
    (function() {
        var $rightBox = $(".custom-right"),
            $bgBox = $(".page.edit"),
            $index = $bgBox.index() + 1,
            bgImg = $bgBox.css("background-image"),
            bgColor = $bgBox.css("background-color"),
            // toolbar = '<div class="toolbar"> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="image"> <i class="modul-icon-pic"></i> <span>添加图片</span> </div> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="text"> <i class="modul-icon-text"></i> <span>添加文本</span> </div> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="button"> <i class="modul-icon-btn"></i> <span>添加按钮</span> </div> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="map"> <i class="modul-icon-map"></i> <span>添加地图</span> </div> </div>',
            toolbar = '<div class="toolbar"> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="image"> <i class="modul-icon-pic"></i> <span>添加图片</span> </div> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="text"> <i class="modul-icon-text"></i> <span>添加文本</span> </div> <div class="add-modular" data-clear="0" data-toggle="addModalur" data-type="button"> <i class="modul-icon-btn"></i> <span>添加按钮</span> </div> </div>',
            $bg = $('<div class="c-panel panel-bg"> <div class="panel-t"> <span>背景设置</span> <div class="panel-icon-edit"></div> </div> <div class="panel-handle"></div> <div class="panel-main"> <div class="c-group"> <label class="label-name">背景图</label> <div class="c-box"> <div> <div class="cieldon-file width-auto" data-callback="setBg" data-type="0" data-width="80" data-height="120"></div><small class="help-inline text-warning line-height-30">图片建议尺寸：860像素*1280像素</small> </div> </div> </div> <div class="c-group"> <label class="label-name">背景颜色</label> <div class="c-box"> <input type="text" data-name="bgColor" class="colorpicker"> <span class="help-inline text-warning">若上传了背景图，则无需配置背景色</span> </div> </div> <div class="c-group"> <label class="label-name">页面序号</label> <div class="c-box"> <input type="text" data-name="pageIndex" class="col-sm-12" placeholder="请输入页面序号" value="' + $index + '"> </div> </div> </div> </div> </div>');
        $link = createPanel.link || $("");
        if (bgImg == "none") {
            bgColor = utils.color.colorFormat(bgColor, "rgba");
            $bg.find("[data-name=bgColor]").val(bgColor).css({
                "background-color": bgColor
            });
        } else {
            var len = bgImg.length,
                bgImg = bgImg.substr(4, len - 5);
            $bg.find(".cieldon-file").attr("data-img", bgImg);
        }
        $bg.find(".panel-main").append($link)

        var linkType = $bgBox.attr("data-link") || 0,
            href = $bgBox.attr("data-href");

        $bg.find("#menuable_type option[value=" + linkType + "]").attr("selected", "selected");
        var link_options = $bg.find('.' + linkType);
        link_options.show();
        link_options.find('select').length ? link_options.find("[value='" + href + "']").attr("selected", "selected") : link_options.find("input").val(href);
        $rightBox.append(toolbar, $bg);
        fileup();
        // 初始化当前页面background-color的colorpicker
        $('input[class*="colorpicker"]').colorpicker({
            format: "rgba"
        }).on("changeColor", function(e) {
            var self = $(this);
            var objRGBA = e.color.toRGB();

            self.css({
                "background-color": utils.color.colorObjToRGBA(objRGBA)
            });
            self.val(utils.color.colorObjToRGBA(objRGBA));
            $(".page.edit").css({
                "background-color": utils.color.colorObjToRGBA(objRGBA)
            });
        });
        $rightBox.on("click", ".panel-icon-edit", function() {
            var $this = $(this),
                $parent = $this.parents(".panel-bg"),
                $panel = $(".panel-bg").nextAll(),
                $actBox = $(".module");
            $parent.find(".panel-main").slideDown();
            if ($("#editorMini").length) {
                initText.destroy();
            }
            $panel.remove();
            $actBox.removeClass("active");
        }).on("change", "[data-name=pageIndex]", function() {
            var $this = $(this),
                $val = parseInt($this.val()),
                $index = $bgBox.index() + 1,
                $boxView = $bgBox.parent(),
                $len = $boxView.children().length;
            if ($val == 1) {
                $boxView.prepend($bgBox);
                $boxView.css("left", "0px");
            } else if ($val >= $len) {
                $boxView.append($bgBox);
                $boxView.css("left", -($len - 1) * 320 + "px");
            } else if ($val > $index) {
                $boxView.find(".page").eq($val - 1).after($bgBox);
                $boxView.css("left", -($val - 1) * 320 + "px");
            } else if ($val < $index) {
                $boxView.find(".page").eq($val - 2).after($bgBox);
                $boxView.css("left", -(val - 1) * 320 + "px");
            }
        });
        setPanel.setLinkEle = $bgBox;
    })();
    $(".toolbar .add-modular").draggable({
        revertDuration: 0,
        cancel: ".disabled",
        revert: true
    });
    $(".phone-main .page .page-main").droppable({
        drop: function(event, ui) {
            var dom = ui.helper,
                drapBox = $(this),
                type = dom.attr("data-type"),
                left = parseInt(dom.css("left")),
                top = parseInt(dom.css("top")),
                flag = dom.hasClass("add-modular");
            if (flag) {
                top = Math.round((top - 30) / 486 * 100);
                if ($("#editorMini").length) {
                    initText.destroy();
                }
                createmodule(type, drapBox, left, top);
                dragMod();
            }
            /*else{
                            top = Math.round(top/486*100);
                            left = Math.round(left/320*100);
                            dom.css({"top":top+"%","left":left+"%"});
                        }*/
        }
    });
    $(".page-view").on("click", ".module", function() {
        var $this = $(this),
            $type = $this.attr("data-type");
        if (!$this.is(".active")) {
            $this.addClass("active").siblings().removeClass("active");
            if ($("#editorMini").length) {
                initText.destroy();
            }
            createPanel($type, $this);
        }
    }).on("click", ".module-delete", function() {
        var $this = $(this),
            $parents = $this.parents(".module");
        if ($parents.is(".modul-map")) {
            $("[data-type=map]").removeClass("disabled");
        }
        if ($("#editorMini").length) {
            initText.destroy();
        }
        $parents.remove();
        $(".custom-right .c-panel").not(".panel-bg").remove();
        $(".panel-bg .panel-main").slideUp();
        return false;
    });

    function dragMod() {
        $(".phone-main .module").draggable({
            containment: "parent",
            revert: false,
            handle: ".module-move"
        });
    }
}

function createdom(dom) {}

function createmodule(type, el, left, top) {
    var control = '<div class="module-control"> <span class="module-move"></span> <span class="module-delete"><i class="fa fa-times"></i></span> </div>',
        $view = $(".page-view .module");
    switch (type) {
        case "image":
            var newLeft = Math.round((left + 400) / 320 * 100);
            var html = '<div class="module moduled modul-image active" data-type="' + type + '" style="left:' + newLeft + '%;top:' + top + '%;">' + control + '<a class="modul-box"><img data-image="image" src="/assets/720.jpg" alt="" /></a></div>';
            el.append(html);
            break;
        case "text":
            var newLeft = Math.round((left + 566) / 320 * 100);
            var html = '<div class="module moduled modul-text active" data-type="' + type + '" style="left:' + newLeft + '%;top:' + top + '%;">' + control + '<a class="modul-box"><div class="text-wrapp"><div class="text">请输入文本内容</div></div></a></div>';
            el.append(html);
            break;
        case "button":
            var newLeft = Math.round((left + 732) / 320 * 100);
            var html = '<div class="module moduled modul-btn active" data-type="' + type + '" style="left:' + newLeft + '%;top:' + top + '%;">' + control + '<a class="modul-box"><div class="p-btn p-btn-default">默认按钮</div></a></div>';
            el.append(html);
            break;
        case "map":
            $(".add-modular[data-type=map]").addClass("disabled");
            var num = el.parent().index(),
                id = "mapContent" + num;
            var html = '<div class="module moduled modul-map active" data-type="' + type + '"><div class="module-control"> <span class="module-delete"><i class="fa fa-times"></i></span> </div><div class="modul-box"><div class="map-content" id="' + id + '"></div></div></div>';
            el.append(html);
            createMap(id);
            break;
        default:
            break;
    }
    $view.removeClass("active");
    createPanel(type, $(".module.active"));
}

function createPanel(type, el) {
    var $main = $(".custom-right"),
        $title = $('<div class="panel-t"><span></span></div>'),
        $title2 = $('<div class="panel-t"><span></span></div>'),
        $box = $('<div class="c-panel c-panel-trip"><div class="panel-main"></div></div>'),
        $box2 = $('<div class="c-panel c-panel-trip c-panel2"><div class="panel-main"></div></div>'),
        $img = $('<div class="c-group"><label class="label-name">图片</label><div class="c-box"><div class="cieldon-file width-auto" data-image="file" data-type="0" data-callback="upDataImg" data-width="100" data-height="100"></div></div></div>'),
        $text = $('<div class="c-group"> <label class="label-name">编辑内容 </label> <div class="c-box"> <div id="editorMini" style="height:100px;"></div> </div> </div>'),
        $textBg = $('<div class="c-group"> <label class="label-name">背景颜色</label> <div class="c-box"> <input data-name="textBgColor" type="text" class="colorpicker" value="none"><a href="javascript:;"class="btn btn-sm btn-primary" data-name="clearTextBgColor">清空颜色</a> </div> </div>'),
        $opacity = $('<div class="c-group"> <label class="label-name">透明度</label> <div class="c-box"> <div class="table"> <span class="slider-num">100%</span> <div class="cell"> <div class="slider sliderOpacity"></div> </div> </div> </div> </div>'),
        $button = $('<div class="c-group"> <label class="label-name">按钮名称 </label> <div class="c-box"> <input type="text" data-name="button" class="col-sm-12" placeholder="请输入按钮名称"> </div> </div>'),
        $buttonStyle = $('<div class="c-group"> <label class="label-name">按钮样式 </label> <div class="c-box"><button class="p-btn p-btn-primary">样式一</button> <button class="p-btn p-btn-warning">样式二</button> <button class="p-btn p-btn-default">样式三</button> <button class="p-btn p-btn-danger">样式四</button> <button class="p-btn p-btn-success">样式五</button> <button class="p-btn p-btn-inverse">样式六</button> <button class="p-btn p-btn-info">样式七</button> <button class="p-btn disabled">样式八</button></div> </div>'),
        $buttonSize = $('<div class="c-group"> <label class="label-name">按钮字号  </label> <div class="c-box"> <select data-name="textSize" class="col-sm-12"> <option value="12px">12px</option> <option selected value="14px">14px</option> <option value="16px">16px</option></select> </div> </div>'),
        $map = $('<div class="c-group"> <label class="label-name">详细地址 </label> <div class="c-box"> <div class="table"> <div class="cell"> <input id="address_keyword" type="text" class="col-sm-12" rows="5" placeholder="请输入详细地址"> </div><div id="searchResultPanel" style="border:1px solid #C0C0C0;width:150px;height:auto; display:none;"></div> <div class="cell"> <a href="javascript:;" class="c-btn" id="search_button" data-lng="121.50235" data-lag="31.300511">定位</a> </div> </div> </div> </div><div class="c-group"> <div class="map-content" id="dituContent"></div> </div>'),
        $index = $('<div class="c-group"><label class="label-name">控件层级</label><div class="c-box"><a href="javascript:;" class="index-box" data-type="top" data-rel="tooltip" data-original-title="置顶"><i class="z-index-top"></i></a><a href="javascript:;" class="index-box" data-type="bottom" data-rel="tooltip" data-original-title="置底"><i class="z-index-bottom"></i></a><a href="javascript:;" class="index-box" data-type="up" data-rel="tooltip" data-original-title="上移"><i class="z-index-up"></i></a><a href="javascript:;" class="index-box" data-type="down" data-rel="tooltip" data-original-title="下移"><i class="z-index-down"></i></a></div></div>'),
        $width = $('<div class="c-group"> <label class="label-name">宽度比例</label> <div class="c-box"> <div class="table"> <span class="slider-num">50%</span> <div class="cell"> <div class="slider sliderWidth"></div> </div> </div> </div> </div>'),
        $height = $('<div class="c-group"> <label class="label-name">高度</label> <div class="c-box"> <div class="table"> <span class="slider-num">20px</span> <div class="cell"> <div class="slider sliderHeight"></div> </div> </div> </div> </div>'),
        $animate = $('<div class="c-group"> <label class="label-name">动画效果</label> <div class="c-box"> <select data-name="animate" class="col-sm-12"> <option value="null">无</option> <option value="fade">淡入</option> <option value="slide">滑入</option> <option value="elastic">弹入</option> <option value="rollover">旋转浮现</option> </select> </div> </div>'),
        $direction = $('<div class="c-group hide" data-name="direction"> <label class="label-name">动画方式</label> <div class="c-box"> <select data-name="slide" class="col-sm-12 hide"><option value="slideLeft">由左至右</option><option value="slideRight">由右至左</option><option value="slideUp">由上至下</option><option value="slideDown">由下至上</option> </select><select data-name="elastic" class="col-sm-12 hide"><option value="elasticLeft">由左至右</option><option value="elasticRight">由右至左</option><option value="elasticUp">由上至下</option><option value="elasticDown">由下至上</option> </select> <select data-name="rollover" class="col-sm-12 hide"><option value="clockwise">顺时针</option><option value="anti-clockwise">逆时针</option> </select></div> </div>'),
        $delay = $('<div class="c-group hide" data-name="delay"> <label class="label-name">开始时间</label> <div class="c-box"> <div class="table"> <span class="slider-num">0.5s</span> <div class="cell"> <div class="slider sliderDelay"></div> </div> </div> </div> </div>'),
        $duration = $('<div class="c-group hide" data-name="duration"> <label class="label-name">动画时长</label> <div class="c-box"> <div class="table"> <span class="slider-num">2s</span> <div class="cell"> <div class="slider sliderDuration"></div> </div> </div> </div> </div>'),
        $paddingLeft = $('<div class="c-group"> <label class="label-name">边距（左）</label> <div class="c-box"> <div class="table"> <span class="slider-num">0px</span> <div class="cell"> <div class="slider sliderPaddingLeft"></div> </div> </div> </div> </div>'),
        $paddingRight = $('<div class="c-group"> <label class="label-name">边距（右）</label> <div class="c-box"> <div class="table"> <span class="slider-num">0px</span> <div class="cell"> <div class="slider sliderPaddingRight"></div> </div> </div> </div> </div>'),
        $paddingTop = $('<div class="c-group"> <label class="label-name">边距（上）</label> <div class="c-box"> <div class="table"> <span class="slider-num">0px</span> <div class="cell"> <div class="slider sliderPaddingTop"></div> </div> </div> </div> </div>'),
        $paddingBottom = $('<div class="c-group"> <label class="label-name">边距（下）</label> <div class="c-box"> <div class="table"> <span class="slider-num">0px</span> <div class="cell"> <div class="slider sliderPaddingBottom"></div> </div> </div> </div> </div>'),
        $borderWidth = $('<div class="c-group" data-name="setBorderWidth"> <label class="label-name">边框宽度</label> <div class="c-box"> <div class="table"> <span class="slider-num">3px</span> <div class="cell"> <div class="slider sliderBorderWidth"></div> </div> </div> </div> </div>'),
        $borderColor = $('<div class="c-group" data-name="setBorderColor"> <label class="label-name">边框颜色</label> <div class="c-box"> <input data-name="textBorderColor" type="text" class="colorpicker" value="none"><a href="javascript:;"class="btn btn-sm btn-primary" data-name="clearTextBorderColor">清空颜色</a> </div> </div>'),
        $borderStyle = $('<div class="c-group"> <label class="label-name">边框样式</label> <div class="c-box"> <select data-name="borderStyle" class="col-sm-12"> <option value="none">无</option> <option value="solid">实线</option> <option value="dashed">虚线</option> <option value="dotted">点线</option> </select> </div> </div>'),
        $alignVertical = $('<div class="c-group"> <label class="label-name">垂直对齐</label> <div class="c-box"> <select data-name="alignVertical" class="col-sm-12"> <option value="top">居上</option> <option value="middle">居中</option> <option value="bottom">居下</option> </select> </div> </div>'),
        $alignHorizontal = $('<div class="c-group"> <label class="label-name">水平对齐</label> <div class="c-box"> <select data-name="alignHorizontal" class="col-sm-12"> <option value="left">居左</option> <option value="center">居中</option> <option value="right">居右</option> </select> </div> </div>'),
        $link = $(createPanel.link) || $(""),
        boxWidth = Math.round(Math.round(el.width()) / 320 * 100),
        boxHeight = parseInt(el.find(".text").height()),
        animate = el.attr("data-animate") || "null",
        direction = el.attr("data-direction") || 0,
        delay = parseFloat(el.css("animation-delay")),
        duration = parseFloat(el.css("animation-duration")),
        linkType = el.attr("data-link") || 0,
        href = el.find('.modul-box').attr("href");
    $main.find(".c-panel").not(".panel-bg").remove();
    $(".panel-bg .panel-main").slideUp();
    $animate.find("option[value=" + animate + "]").attr("selected", "selected");
    if (animate != "null") {
        if (animate != "fade") {
            $direction.removeClass("hide");
            $direction.find("[data-name=" + animate + "]").removeClass("hide").find("option[value=" + direction + "]").attr("selected", "selected");
        }
        $delay.removeClass("hide").find(".slider-num").text(delay + "s");
        $duration.removeClass("hide").find(".slider-num").text(duration + "s");
    }

    if (type == "image") {
        var imgUrl = el.find("[data-image=image]").attr("src"),
            inext = el.index();
        $title.find("span").text("图片");
        if (imgUrl.indexOf("720.jpg") == -1) {
            $img.find(".cieldon-file").attr("data-img", imgUrl);
        }
        $width.find(".slider-num").text(boxWidth + "%");
        $box.prepend($title).find(".panel-main").append($img, $width, $index, $animate, $direction, $delay, $duration, $link);
        $main.append($box);
        fileup();
    } else if (type == "text") {
        var $textBox = el.find(".text"),
            $textModuleBox = el.find(".modul-box"),
            text = $textBox.html(),
            bgColor = $textBox.css("background-color"),
            boxOpacity = Math.round($textModuleBox.css("opacity") * 100),
            boxPaddingLeft = parseInt($textBox.css("paddingLeft")),
            boxPaddingRight = parseInt($textBox.css("paddingRight")),
            boxPaddingTop = parseInt($textBox.css("paddingTop")),
            boxPaddingBottom = parseInt($textBox.css("paddingBottom")),
            boxBorderColor = $textBox.css("border-color"),
            boxBorderWidth = parseInt($textBox.css("border-width")),
            boxBorderStyle = $textBox.css("border-style"),
            alignOption = ['top', 'middle', 'bottom', 'left', 'center', 'right'],
            alignVertical = $textBox.css("vertical-align"),
            alignHorizontal = $textBox.css("text-align");
        $title.find("span").text("基础编辑");
        $title2.find("span").text("更多编辑");
        $width.find(".slider-num").text(boxWidth + "%");
        $height.find(".slider-num").text(boxHeight + "px");
        $opacity.find(".slider-num").text(boxOpacity + "%");

        bgColor = utils.color.colorFormat(bgColor, "rgba");
        $textBg.find(".colorpicker").val(bgColor).css({
            "background-color": bgColor
        });

        $paddingLeft.find(".slider-num").text(boxPaddingLeft + "px");
        $paddingRight.find(".slider-num").text(boxPaddingRight + "px");
        $paddingTop.find(".slider-num").text(boxPaddingTop + "px");
        $paddingBottom.find(".slider-num").text(boxPaddingBottom + "px");

        // 设置文本垂直对齐
        if ($.inArray(alignVertical, alignOption)) {
            $alignVertical.find("option[value=" + alignVertical + "]").prop("selected", true);
        } else {
            $alignVertical.find("option[value=top]").prop("selected", true);
        }
        // 设置文本水平对齐
        if ($.inArray(alignHorizontal, alignOption)) {
            $alignHorizontal.find("option[value=" + alignHorizontal + "]").prop("selected", true);
        } else {
            $alignHorizontal.find("option[value=left]").prop("selected", true);
        }

        $box.prepend($title).find(".panel-main").append($text, $index, $textBg, $width, $height, $animate, $direction, $delay, $duration, $link);
        $box2.prepend($title2).find(".panel-main").append($alignVertical, $paddingLeft, $paddingRight, $paddingTop, $paddingBottom, $borderStyle, $borderColor, $borderWidth, $opacity);
        $main.append($box, $box2);

        initText.init(text, bgColor);
        slider("height", boxHeight, $textModuleBox);
        slider("opacity", boxOpacity, $textModuleBox);
        slider("sliderPaddingLeft", boxPaddingLeft, $textModuleBox);
        slider("sliderPaddingRight", boxPaddingRight, $textModuleBox);
        slider("sliderPaddingTop", boxPaddingTop, $textModuleBox);
        slider("sliderPaddingBottom", boxPaddingBottom, $textModuleBox);
        slider("sliderBorderWidth", boxBorderWidth, $textModuleBox);
        $('input[data-name="textBgColor"]').colorpicker({
            format: "rgba"
        }).on("changeColor", function(e) {
            var self = $(this);
            var objRGBA = e.color.toRGB();
            var colorRGBA = utils.color.colorObjToRGBA(objRGBA);

            self.css({
                "background-color": colorRGBA
            });

            self.val(colorRGBA);

            $textBox.css({
                "background-color": colorRGBA
            });

            UE.getEditor('editorMini', ue_type.mini).execCommand('background', {
                "background-color": colorRGBA
            });
        });
        $('input[data-name="textBorderColor"]').colorpicker({
            format: "rgba"
        }).on("changeColor", function(e) {
            var self = $(this);
            var objRGBA = e.color.toRGB();

            self.css({
                "background-color": utils.color.colorObjToRGBA(objRGBA)
            });
            self.val(utils.color.colorObjToRGBA(objRGBA));
            $textBox.css({
                "border-color": utils.color.colorObjToRGBA(objRGBA)
            });
        });

        // 设置边框宽度
        $borderWidth.find(".slider-num").text(boxBorderWidth + "px");
        // 设置边框颜色
        boxBorderColor = utils.color.colorFormat(boxBorderColor, "rgba");
        $borderColor.find(".colorpicker").val(boxBorderColor).css({
            "background-color": boxBorderColor
        });;
        // 设置边框样式
        if (boxBorderStyle == "none") {
            setTextBorderNo();
        }
        $borderStyle.find("option[value=" + boxBorderStyle + "]").prop("selected", true);

    } else if (type == "button") {
        var button = el.find(".p-btn"),
            textSize = button.css("font-size");
        $title.find("span").text("按钮");
        $buttonSize.find("option[value=" + textSize + "]").attr("selected", "selected");
        $button.find("input[type=text]").val(button.text());
        $width.find(".slider-num").text(boxWidth + "%");
        $box.prepend($title).find(".panel-main").append($button, $buttonStyle, $buttonSize, $width, $index, $animate, $direction, $delay, $duration, $link);
        $main.append($box);
    } else if (type == "map") {
        var id = el.find(".map-content").attr("id");
        $title.find("span").text("地图");
        $box.prepend($title).find(".panel-main").append($map);
        $main.append($box);
        createMap("dituContent");
    }



    //默认展开第一个编辑面板
    $title.trigger("click");

    slider("delay", delay * 10, el);
    slider("duration", duration * 10, el);
    $box.find("#menuable_type option[value=" + linkType + "]").attr("selected", "selected");
    var link_options = $box.find('.' + linkType);
    link_options.show();
    link_options.find('select').length ? link_options.find("[value='" + href + "']").attr("selected", "selected") : link_options.find("input").val(href)
    slider("width", boxWidth, el);
    $('[data-rel=tooltip]').tooltip();
}

function slider(type, value, el) {
    var defaults = {
            range: "min",
            values: 100,
            max: 100,
            min: 0
        },
        opt = {},
        _self;

    if (type == "width") {
        _self = $(".sliderWidth");
        opt = {
            values: 90,
            max: 100,
            min: 10,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev(),
                    elLeft = parseInt(parseInt(el.css("left")) / 320 * 100);
                $numBox.text(ui.value + "%");
                if (elLeft + ui.value >= 100) {
                    elLeft = 100 - ui.value;
                    el.css({
                        "width": ui.value + "%",
                        "left": elLeft + "%"
                    });
                } else {
                    el.css({
                        "width": ui.value + "%"
                    });
                }
            }
        }
    } else if (type == "height") {
        _self = $(".sliderHeight");
        opt = {
            values: 90,
            max: 400,
            min: 10,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev();
                $numBox.text(ui.value + "px");
                el.find(".text").css({
                    "height": ui.value
                });
            }
        }
    } else if (type == "opacity") {
        _self = $(".sliderOpacity");
        opt = {
            max: 100,
            min: 0,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev();
                $numBox.text(ui.value + "%");
                el.css({
                    "opacity": ui.value / 100
                });
            }
        }
    } else if (type == "delay") {
        _self = $(".sliderDelay");
        opt = {
            values: 100,
            max: 100,
            min: 0,
            value: 20,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev(),
                    $val = ui.value / 10 + "s";
                $numBox.text($val);
                el.css({
                    "-webkit-animation-delay": $val
                });
            }
        }
    } else if (type == "duration") {
        _self = $(".sliderDuration");
        opt = {
            values: 50,
            max: 50,
            min: 0,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev(),
                    $val = ui.value / 10 + "s";
                $numBox.text($val);
                el.css({
                    "-webkit-animation-duration": $val
                });
            }
        }
    } else if ((/sliderPadding/i).test(type)) {
        _self = $("." + type); //这里传的type值跟滑块的class相同，直接使用
        opt = {
            values: 20,
            max: 100,
            min: 0,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev(),
                    $val = ui.value + "px";
                $numBox.text($val);
                el.find(".text").css("p" + type.substring(7), $val);
            }
        }
    } else if (type == "sliderBorderWidth") {
        _self = $("." + type); //这里传的type值跟滑块的class相同，直接使用
        opt = {
            values: 20,
            max: 100,
            min: 0,
            value: value,
            slide: function(event, ui) {
                var $numBox = $(this).parent().prev(),
                    $val = ui.value + "px";
                $numBox.text($val);
                el.find(".text").css("border-width", $val);
            }
        }
    }

    _self.slider($.extend({}, defaults, opt));
}

var setPanelFn = function() {
    var $main = $(".custom-right");

    var zIndex = function() {
        $main.on("click", ".index-box", function() {
            var $this = $(this),
                $type = $this.attr("data-type"),
                $actBox = $(".module.active"),
                $viewBox = $actBox.parent();
            switch ($type) {
                case "top":
                    $viewBox.append($actBox);
                    break;
                case "bottom":
                    $viewBox.prepend($actBox);
                    break;
                case "up":
                    var $next = $actBox.next();
                    $next.after($actBox);
                    break;
                case "down":
                    var $prev = $actBox.prev();
                    $prev.before($actBox);
                    break;
                default:
                    break;
            }
        });
    };
    var setTextPanel = function() {
        $main.on("click", ".c-panel-trip .panel-t", function() {
            var self = $(this);
            var parent = self.parent();
            var main = self.next(".panel-main");

            if (parent.hasClass('c-panel-on')) {
                parent.removeClass('c-panel-on').siblings('.c-panel-trip').addClass('c-panel-on').find('.panel-main').slideDown();
                main.slideUp();
            } else {
                parent.addClass('c-panel-on').siblings('.c-panel-trip').removeClass('c-panel-on').find('.panel-main').slideUp();
                main.slideDown();
            }
        });
    };
    var bindClearColorEvent = function() {
        $main.on("click", "[data-name=clearTextBgColor]", function() {
            var $actBox = $(".module.active"),
                setText = UE.getEditor('editorMini', ue_type.mini);
            $actBox.find(".text").css("background-color", "rgba(0, 0, 0, 0)")
            setText.execCommand('background', {
                "background-color": "rgba(0, 0, 0, 0)"
            });
            $("[data-name=textBgColor]").colorpicker("setValue", "rgba(0, 0, 0, 0)").colorpicker("hide");
        });

        $main.on("click", "[data-name=clearTextBorderColor]", function() {
            var $actBox = $(".module.active");

            $actBox.find(".text").css("border-color", "rgba(0, 0, 0, 0)");
            $("[data-name=textBorderColor]").colorpicker("setValue", "rgba(0, 0, 0, 0)").colorpicker("hide");
        });
    };
    var setTextBorderStyle = function() {
        $main.on("change", "[data-name=borderStyle]", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val();

            if ($.trim($val) === "none") {
                setTextBorderNo();
            } else {
                setTextBorderDefault();
            }
            $actBox.find(".text").css("border-style", $val);
        });
    };
    var setTextAlignVertical = function() {
        $main.on("change", "[data-name=alignVertical]", function() {
            console.log("xxxxx")
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val();

            $actBox.find(".text").css("vertical-align", $val);
        });
    }
    var setTextAlignHorizontal = function() {
        $main.on("change", "[data-name=alignHorizontal]", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val();

            $actBox.find(".text").css("text-align", $val);
        });
    }
    var setButton = function() {
        $main.on("input", "[data-name=button]", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val();
            if ($val == "") {
                $val = "默认按钮";
            }
            $actBox.find(".p-btn").text($val);
        });
    }
    var setButtonStyle = function() {
        $main.on("click", ".p-btn", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $class = $this.attr("class");
            $actBox.find(".p-btn").attr("class", $class);
        });
    }
    var setButtonSize = function() {
        $main.on("change", "[data-name=textSize]", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $size = $this.val();
            $actBox.find(".p-btn").css("font-size", $size);
        });
    }
    var setAnimate = function() {
        $main.on("change", "[data-name=animate]", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val(),
                $selectall = $("[data-name=delay],[data-name=duration]"),
                $direction = $("[data-name=direction]");
            $actBox.attr("data-animate", $val);
            switch ($val) {
                case "null":
                    $selectall.addClass("hide");
                    $direction.addClass("hide");
                    setPanel.setAnimateEffective["-webkit-animation-name"] = "";
                    break;
                case "fade":
                    $selectall.removeClass("hide");
                    $direction.addClass("hide");
                    setPanel.setAnimateEffective["-webkit-animation-name"] = "fadeIn";
                    $actBox.attr("data-direction", "fadeIn");
                    break;
                case "slide":
                    $selectall.removeClass("hide");
                    $direction.removeClass("hide");
                    $direction.find("[data-name=slide]").removeClass("hide").siblings().addClass("hide");
                    setPanel.setAnimateEffective["-webkit-animation-name"] = "slideLeft";
                    $actBox.attr("data-direction", "slideLeft");
                    break;
                case "elastic":
                    $selectall.removeClass("hide");
                    $direction.removeClass("hide");
                    $direction.find("[data-name=elastic]").removeClass("hide").siblings().addClass("hide");
                    setPanel.setAnimateEffective["-webkit-animation-name"] = "elasticLeft";
                    $actBox.attr("data-direction", "elasticLeft");
                    break;
                case "rollover":
                    $selectall.removeClass("hide");
                    $direction.removeClass("hide");
                    $direction.find("[data-name=rollover]").removeClass("hide").siblings().addClass("hide");
                    setPanel.setAnimateEffective["-webkit-animation-name"] = "clockwise";
                    $actBox.attr("data-direction", "clockwise");
                    break;
            }
            $actBox.css(setPanel.setAnimateEffective);
            var delay = parseFloat(setPanel.setAnimateEffective["-webkit-animation-delay"]) * 10;
            var duration = parseFloat(setPanel.setAnimateEffective["-webkit-animation-duration"]) * 10;
            slider("delay", delay, $actBox);
            slider("duration", duration, $actBox);
        });
    }
    var setDirection = function() {
        $main.on("change", "[data-name=direction] select", function() {
            var $actBox = $(".module.active"),
                $this = $(this),
                $val = $this.val();
            setPanel.setAnimateEffective["-webkit-animation-name"] = $val;
            $actBox.css(setPanel.setAnimateEffective);
            $actBox.attr("data-direction", $val);
        });
    }
    var setLink = function() {
        $main.on("change", "[data-name=link]", function() {
            var $this = $(this),
                $val = $this.val(),
                linkUrl = $('.url_option:visible').val(),
                $len = $(".module.active").length,
                $group = $this.parents(".c-group"),
                $actBox = null;
            if ($len) {
                $actBox = $(".module.active");
                $actBox.find('.modul-box').attr("href", linkUrl);
            } else {
                $actBox = $(".page.edit");
                $actBox.attr("data-href", linkUrl)
            }
            $actBox.attr("data-link", $val);
            $group.siblings(".link_options").hide();
            // $group.siblings("." + $val).show();
            $group.siblings("." + $val).show().find("option").eq(0).prop("selected", true).trigger("change");
        });
        $main.on("change input", ".url_option", function() {
            var $this = $(this),
                linkUrl = $this.val(),
                $len = $(".module.active").length,
                $actBox = null;
            if ($len) {
                $actBox = $(".module.active");
                $actBox.find('.modul-box').attr("href", linkUrl);
            } else {
                $actBox = $(".page.edit");
                $actBox.attr("data-href", linkUrl);
            }
        });
    }
    return {
        init: function() {
            console.log($main);
            console.log($main.attr("xxx"));
            zIndex();
            setTextPanel();
            bindClearColorEvent();
            // setText();
            setButton();
            setButtonStyle();
            setButtonSize();
            setTextBorderStyle();
            setTextAlignVertical();
            setTextAlignHorizontal();
            setAnimate();
            setDirection();
            setMap();
            setLink();
        },
        setLinkEle: null,
        setText: null,
        setAnimateEffective: {
            "-webkit-animation-name": "",
            "-webkit-animation-duration": "2s",
            "-webkit-animation-delay": ".5s",
            "-webkit-animation-timing-function": "ease-out",
            "-webkit-animation-fill-mode": "backwards"
        }
    }
}
var setPanel; // 解决右侧事件多次绑定bug，保存页面的时候重新赋值setPanel

function setTextBorderDefault() {
    var textBox = $(".module.active .text");

    $("[data-name='setBorderColor']").show();
    $("[data-name='setBorderWidth']").show();

    // 设置边框宽度为默认的2px, 颜色为#ccc
    if (textBox.css("border-style") === "none") {
        $(".sliderBorderWidth").slider("value", 2).parent().prev().text("2px");
        textBox.css({
            "border-width": 2
        });
        $("[data-name='textBorderColor']").colorpicker("setValue", "rgba(204, 204, 204, 1)");
    }
}

function setTextBorderNo() {
    var textBox = $(".module.active .text");
    // 设置边框宽度为0, 颜色为透明
    $(".sliderBorderWidth").slider("value", 0).parent().prev().text("0px");
    textBox.css({
        "border-width": 0
    });
    $("[data-name='textBorderColor']").colorpicker("setValue", "rgba(0, 0, 0, 0)");

    $("[data-name='setBorderColor']").hide();
    $("[data-name='setBorderWidth']").hide();
}

function upDataImg(key, url) {
    var img = $(".module.active").find("img");
    img.attr("src", url);
}

function setBg(key, url) {
    $(".page.edit").css("background-image", "url(" + url + ")");
}

function setMap() {
    var smap = $(".module.active .map-content");
    if (smap.length) {
        var id = smap.attr("id"),
            lng = smap.attr("data-lng") || 121.50235,
            lat = smap.attr("data-lat") || 31.300511,
            smap = new BMap.Map(id),
            point = new BMap.Point(lng, lat);
        smap.centerAndZoom(point, 18);
    }
}

function getColor(rgb) {
    if (rgb == "transparent") {
        return "none"
    } else {
        rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
        return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
    }

    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
}
var initText = function() {
    var createEdit = function(html, backgroundColor) {
        var setText = UE.getEditor('editorMini', ue_type.mini);
        setText.addListener('ready', function(editor) {
            if (html && html != "请输入文本内容") {
                setText.setContent(html);
            }
            setText.execCommand('background', {
                "background-color": backgroundColor
            });
        });
        setText.addListener('contentChange', function(editor) {
            var getHtml = setText.getContent(),
                getText = setText.getContentTxt(),
                $actBox = $(".module.active .text");
            if (getText) {
                $actBox.html(getHtml);
            } else {
                $actBox.html("请输入文本内容");
            }
        });
    }
    var destroyText = function() {
        UE.getEditor('editorMini').destroy();
        // setText.destroy();
    }
    return {
        init: function(html, backgroundColor) {
            createEdit(html, backgroundColor);
        },
        destroy: function() {
            destroyText();
        }
    }
}();

function createMap(id) {
    var map = new BMap.Map(id); //在百度地图容器中创建一个地图
    map.centerAndZoom("北京", 12);
    var ac = new BMap.Autocomplete({ //建立一个自动完成的对象
        "input": "address_keyword",
        "location": map
    });
    ac.addEventListener("onhighlight", function(e) { //鼠标放在下拉列表上的事件
        var str = "";
        var _value = e.fromitem.value;
        var value = "";
        if (e.fromitem.index > -1) {
            value = _value.province + _value.city + _value.district + _value.street + _value.business;
        }
        str = "FromItem<br />index = " + e.fromitem.index + "<br />value = " + value;

        value = "";
        if (e.toitem.index > -1) {
            _value = e.toitem.value;
            value = _value.province + _value.city + _value.district + _value.street + _value.business;
        }
        str += "<br />ToItem<br />index = " + e.toitem.index + "<br />value = " + value;
        G("searchResultPanel").innerHTML = str;
    });

    var myValue;
    ac.addEventListener("onconfirm", function(e) { //鼠标点击下拉列表后的事件
        var _value = e.item.value;
        myValue = _value.province + _value.city + _value.district + _value.street + _value.business;
        G("searchResultPanel").innerHTML = "onconfirm<br />index = " + e.item.index + "<br />myValue = " + myValue;

        setPlace();
    });

    function setPlace() {
        map.clearOverlays(); //清除地图上所有覆盖物
        function myFun() {
            var pp = local.getResults().getPoi(0).point; //获取第一个智能搜索的结果
            var smap = $(".module.active .map-content");
            map.centerAndZoom(pp, 18);
            smap.attr('data-lng', pp.lng);
            smap.attr('data-lat', pp.lat);
            map.addOverlay(new BMap.Marker(pp)); //添加标注
        }
        var local = new BMap.LocalSearch(map, { //智能搜索
            onSearchComplete: myFun
        });
        local.search(myValue);
    }
}

function G(id) {
    return document.getElementById(id);
}

function migration() { // 数据迁移
    var $page = $(".page"),
        $animate = $("[data-animate]"),
        $text = $(".text"),
        defaults = {
            "-webkit-animation-name": "",
            "-webkit-animation-duration": "2s",
            "-webkit-animation-delay": ".5s",
            "-webkit-animation-timing-function": "ease-out",
            "-webkit-animation-fill-mode": "backwards"
        }
    $animate.each(function() {
        var $this = $(this),
            animateType = $this.attr("data-animate"),
            delay = $this.attr("data-delay") || "0",
            newType = replaceType(animateType, delay);
        if (newType) {
            $this.attr(newType.dataAttr).removeAttr("data-delay");
            $this.css(newType.dataAniamte);
        }
    });
    $text.each(function() {
        var $this = $(this),
            fontSize = $this.css("font-size"),
            fontColor = $this.css("color"),
            $text = $this.text(),
            $newText = '<p><span style="font-size:' + fontSize + ';color:' + fontColor + '">' + $text + '</span></p>';
        // if ($this.attr("style")) {
        //     $this.removeAttr("style").html($newText);
        // }
        if ($this.is(".text-bg")) {
            $this.removeClass("text-bg").css("background-color", "rgba(0,0,0,.6)");
        }
    });
    $page.each(function() {
        var $this = $(this),
            $main = $this.find(".page-main");
        if (!$main.length) {
            var $pageMain = $('<section class="page-main"></section>'),
                temp = $this.find(".module");
            $this.removeClass("ui-droppable");
            $pageMain.append(temp);
            $this.prepend($pageMain);
        }
    });

    function replaceType(type, delay) {
        switch (type) {
            case "fade":
                return {
                    dataAttr: {
                        "data-animate": "fade",
                        "data-direction": "fadeIn"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "fadeIn",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            case "up":
                return {
                    dataAttr: {
                        "data-animate": "slide",
                        "data-direction": "slideDown"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "slideDown",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            case "down":
                return {
                    dataAttr: {
                        "data-animate": "slide",
                        "data-direction": "slideUp"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "slideUp",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            case "left":
                return {
                    dataAttr: {
                        "data-animate": "slide",
                        "data-direction": "slideLeft"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "slideLeft",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            case "right":
                return {
                    dataAttr: {
                        "data-animate": "slide",
                        "data-direction": "slideRight"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "slideRight",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            case "rollover":
                return {
                    dataAttr: {
                        "data-animate": "rollover",
                        "data-direction": "clockwise"
                    },
                    dataAniamte: $.extend({}, defaults, {
                        "-webkit-animation-name": "clockwise",
                        "-webkit-animation-delay": delay + "s"
                    })
                };
            default:
                return false;
        }
    }
}
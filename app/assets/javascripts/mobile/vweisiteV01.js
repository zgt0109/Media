//= require mobile/lib/jquery
//= require mobile/lib/swipe
//= require jquery_ujs

$(function() {
    $("a, .btn, .box").on({
        touchstart: function() {
            $(this).addClass("active");
        },
        touchend: function() {
            $(this).removeClass("active");
        },
        touchmove: function() {}
    });
    bannerAutoHeight();
    $(window).resize(bannerAutoHeight);
    //showBtnUp(300);
    //topRefresh(300);
});
//点击给制定的selector添加制定的class
function toggleToClass(selector, className) {
    $(selector).toggleClass(className);
}
//点击切换显示制定selector的类�?
function changeToClass(selector, cn1, cn2) {
    var cn = $(selector).attr("class");
    if (cn == cn1) {
        $(selector).attr("class", cn2);
    } else {
        $(selector).attr("class", cn1);
    }

}
//首页幻灯�?
function indexSwipe(idNmane, texts) {
    new Swipe(document.getElementById(idNmane), {
        speed: 500,
        auto: 3000,
        callback: function() {
            if (texts) {
                var lis = $(this.element).next("div").find("#pagenavi").children();
                lis.removeClass("active").eq(this.index).addClass("active");
                $("#slider-span").html(texts[this.index]);
            }
        }
    })
}
//切换效果
function divSwipe(idNmane) {
    var swipe = new Swipe(document.getElementById(idNmane), {
        speed: 500,
        callback: function() {}
    });
    return swipe;
}
// 设置控制按钮
function setSlide(elements) {
    var lis = $(elements),
        len = lis.find("li").length,
        box = '<div class="sub-slide">',
        li = '<a href="javascript:;"></a>';
    for (var i = 0; i < len; i++) {
        if (i == 0) {
            box += '<a href="javascript:;" class="active"></a>'
        } else {
            box += li;
        }
    }
    box += '</div>';
    lis.append(box);
}
// 滑动切换控制按钮
function mySwipe(idNmane, tools) {
    new Swipe(document.getElementById(idNmane), {
        speed: 500,
        auto: false,
        callback: function() {
            if (tools) {
                var lis = this.index;
                $(".sub-slide a").removeClass("active").eq(lis).addClass("active");
            }
        }
    })
}
//弹出菜单1
function navPop1(idName, input) {
    window.addEventListener("DOMContentLoaded", function() {
        //        btn = document.getElementById(input);
        var btn = (input == '#navLine-navPop') ? $(input).find("b").find("i") : $(input).children();
        var divs = $(idName).find("div");
        btn.click(function() {
            divs.toggleClass("on");
        });
        divs.click(function() {
            $(input).toggleClass("active");
            divs.toggleClass("on");
        });
        //        btn.onclick = function(){
        ////            var divs = document.getElementById(idName).querySelectorAll("div");
        ////            var className = className=this.checked?"on":"";
        ////            for(i = 0;i<divs.length; i++){
        ////                divs[i].className = className;
        ////            }
        //        }
    }, false);
}
//顶部下拉刷新
function topRefresh(h) {
    document.addEventListener("touchstart", function(e) {
        var t = e.touches[0],
            y = t.pageY;
        $("body").attr("data-y", y);
    });
    document.addEventListener("touchmove", function(e) {
        var t = e.touches[0],
            startY = parseInt($("body").attr("data-y")),
            pageY = t.pageY;
        if (startY <= h) {
            $(".loading").addClass("isloading").fadeIn();
            //$(".loading").removeClass("isloading").fadeOut();
        }
    });
}
//btn-up
function showBtnUp(h) {
    window.addEventListener("scroll", function(e) {
        var t = document.documentElement.scrollTop || document.body.scrollTop;
        if (t >= h) {
            $(".btn-up").fadeIn();
        } else {
            $(".btn-up").fadeOut();
        }
    });
}
//底部导航�?
function navLinePop(p, a) {
    $(p).click(function() {
        var self = $(this);
        if (self.hasClass("open")) {
            self.removeClass("open");
        } else {
            $(p).removeClass("open");
            self.addClass("open");
        }
    });
    $(p).on({
        touchstart: function() {
            $(this).addClass("active");
        },
        touchend: function() {
            $(this).removeClass("active");
        },
        touchmove: function() {}
    });
}
//点击显示弹出层（整个覆盖页面�?
function showPop(selector) {
    var h = $(document).height();
    $(selector).height(h).fadeIn();
}
//点击隐藏弹出�?
function hidePop(selector) {
    $(selector).fadeOut();
}

/**开场动画**/
//淡出
function fade1(selector) {
    setTimeout(function() {
        $(selector).fadeOut(3000);
    }, 3000);
}
//变小淡出
function fade2(selector) {
    setTimeout(function() {
        $(selector).hide(1000);
    }, 3000);
}
//焦点消失
function fade3(selector) {
    setTimeout(function() {
        $(selector).addClass("active");
        setTimeout(function() {
            $(selector).hide();
        }, 500);
    }, 3000);
}
//往左淡出
function fade4(selector) {
    setTimeout(function() {
        $(selector).addClass("active");
        setTimeout(function() {
            $(selector).hide();
        }, 500);
    }, 3000);
}
//往右淡出
function fade5(selector) {
    setTimeout(function() {
        $(selector).addClass("active");
        setTimeout(function() {
            $(selector).hide();
        }, 500);
    }, 3000);
}
//往上淡出
function fade6(selector) {
    setTimeout(function() {
        $(selector).addClass("active");
        setTimeout(function() {
            $(selector).hide();
        }, 500);
    }, 3000);

}
//往下淡出
function fade7(selector) {
    setTimeout(function() {
        $(selector).addClass("active");
        setTimeout(function() {
            $(selector).hide();
        }, 500);
    }, 3000);
}
//开门效果
function fade8(selector) {
    setTimeout(function() {
        $(".animate-l").css({
            "-webkit-transform": "translate(-100%,0)"
        });
        $(".animate-r").css({
            "-webkit-transform": "translate(+100%,0)"
        });
    }, 3000);
}

function fade8(selector) {
    setTimeout(function() {
        $(".animate-l").css({
            "-webkit-transform": "translate(-100%,0)"
        });
        $(".animate-r").css({
            "-webkit-transform": "translate(+100%,0)"
        });
    }, 3000);
}
// 刮刮卡
function fade9(selector, image){
    var $w = parseInt($(window).width()),
        $h = parseInt($(window).height());
    $w = $w > 640 ? 640 : $w;
    var sp=$(selector).wScratchPad({
        width:$w,
        height:$h,
        image: image || '../../assets/images/48.jpg',
        image2:'/assets/mobile/vweisiteV01/animateStart/bg.png',
        color:"#eee",
        size:40,
        realtimePercent:"true",
        scratchMove: function(e, percent) {
            if(percent > 70){
                this.clear();
            }
        },
        scratchUp:function(e, percent){
            if(percent >= 100){
                $("#animate-9").fadeOut();
            }
        }
    });
}
// 焦点图底栏设置
function bannerSet(o) {
    var box = $(".slider-text"),
        r = o.background.substr(1, 2),
        g = o.background.substr(3, 2),
        b = o.background.substr(5),
        R = parseInt("0x" + r),
        G = parseInt("0x" + g),
        B = parseInt("0x" + b),
        A = o.opacity / 100;
    box.css({
        "background": "rgba(" + R + "," + G + "," + B + "," + A + ")",
        "color": o.color
    });
}

function bannerAutoHeight() {
    // 设置幻灯片高度
    var $docW = $(window).width() < 640 ? $(window).width() : 640,
        $banH = parseInt($docW / 1.8);
    $(".slider-hor").height($banH);
}
function rotateMenu(box,selector){
    var $docW = parseInt($(window).width());
    var Pi = Math.PI;
    var $len = $(selector).length;
    $(box).outerHeight($docW);
    $(selector).each(function(i){
        var $this = $(this);
        var l = 50+Math.sin(2*Pi/360*360/$len*i)*50;
        var t = 50-Math.cos(2*Pi/360*360/$len*i)*50;
        $this.css({"left":l+"%","top":t+"%"});
    });
}

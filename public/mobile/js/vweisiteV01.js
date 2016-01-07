$(function(){
    $("a, .btn, .box").on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
             $(this).removeClass("active");
        },
        touchmove:function(){
        }
    });
    //showBtnUp(300);
    //topRefresh(300);
});
//点击给制定的selector添加制定的class
function toggleToClass(selector,className){
 $(selector).toggleClass(className);
}
//点击切换显示制定selector的类名
function changeToClass(selector,cn1,cn2){
    var cn=$(selector).attr("class");
    if(cn==cn1){
        $(selector).attr("class",cn2);
    }else{
        $(selector).attr("class",cn1);
    }

}
//首页幻灯片
function indexSwipe(idNmane,texts){
    new Swipe(document.getElementById(idNmane), {
        speed:500,
        auto:3000,
        callback: function(){
            if(texts){
                var lis = $(this.element).next("div").find("#pagenavi").children();
                lis.removeClass("active").eq(this.index).addClass("active");
                $("#slider-span").html(texts[this.index]);
            }
        }
    })
}
//切换效果
function divSwipe(idNmane){
    var swipe=new Swipe(document.getElementById(idNmane), {
        speed:500,
        callback: function(){
        }
    });
    return swipe;
}
//弹出菜单1
function navPop1(idName,input){
    window.addEventListener("DOMContentLoaded", function(){
//        btn = document.getElementById(input);
        var btn= (input == '#navLine-navPop') ? $(input).find("b").find("i"): $(input).children();
        var divs=$(idName).find("div");
        btn.click(function(){
            divs.toggleClass("on");
        });
        divs.click(function(){
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
function topRefresh(h){
    document.addEventListener("touchstart",function(e){
        var t=e.touches[0],
            y=t.pageY;
        $("body").attr("data-y",y);
    });
    document.addEventListener("touchmove",function(e){
        var t=e.touches[0],
            startY=parseInt($("body").attr("data-y")),
            pageY=t.pageY;
        if(startY<=h){
            $(".loading").addClass("isloading").fadeIn();
            //$(".loading").removeClass("isloading").fadeOut();
        }
    });
}
//btn-up
function showBtnUp(h){
    window.addEventListener("scroll",function(e){
        var t = document.documentElement.scrollTop || document.body.scrollTop;
        if(t>=h){
            $(".btn-up").fadeIn();
        }else{
            $(".btn-up").fadeOut();
        }
    });
}
//底部导航栏
function navLinePop(p,a){
    $(p).click(function(){
        var self=$(this);
        if(self.hasClass("open")){
            self.removeClass("open");
        }else{
            $(p).removeClass("open");
            self.addClass("open");
        }
    });
    $(p).on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
            $(this).removeClass("active");
        },
        touchmove:function(){
        }
    });
}
//点击显示弹出层（整个覆盖页面）
function showPop(selector){
    var h=$(document).height();
    $(selector).height(h).fadeIn();
}
//点击隐藏弹出层
function hidePop(selector){
    $(selector).fadeOut();
}

/**开场动画**/
//淡出
function fade1(selector){
    setTimeout(function(){
        $(selector).fadeOut(3000);
    },3000);
}
//变小淡出
function fade2(selector){
    setTimeout(function(){
        $(selector).hide(1000);
    },3000);
}
//焦点消失
function fade3(selector){
    setTimeout(function(){
        $(selector).addClass("active");
        setTimeout(function(){
            $(selector).hide();
        },500);
    },3000);
}
//往左淡出
function fade4(selector){
    setTimeout(function(){
        $(selector).addClass("active");
        setTimeout(function(){
            $(selector).hide();
        },500);
    },3000);
}
//往右淡出
function fade5(selector){
    setTimeout(function(){
        $(selector).addClass("active");
        setTimeout(function(){
            $(selector).hide();
        },500);
    },3000);
}
//往上淡出
function fade6(selector){
    setTimeout(function(){
        $(selector).addClass("active");
        setTimeout(function(){
            $(selector).hide();
        },500);
    },3000);

}
//往下淡出
function fade7(selector){
    setTimeout(function(){
        $(selector).addClass("active");
        setTimeout(function(){
            $(selector).hide();
        },500);
    },3000);
}
//开门效果
function fade8(selector){
    setTimeout(function(){
        $(".animate-l").css({"-webkit-transform":"translate(-100%,0)"});
        $(".animate-r").css({"-webkit-transform":"translate(+100%,0)"});
    },3000);
}
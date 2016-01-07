$(function(){
    $("a, .btn").on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
             $(this).removeClass("active");
        },
        touchmove:function(){
        }
    });
    showBtnUp(100);
    //topRefresh(300);
    //显示子分类
    $("#transition-category .categoey a").click(function(){
        var self=$(this),
            current="#"+self.parents("p").attr("id"),
            target="#category-"+self.attr("data-target");
        showCategory(current,target);
    });
});
//渲染页面长度
function renderBody(type){
    var h=window.innerHeight,
        header=$("header").innerHeight(),
        indexH=$("#index").innerHeight(),
        transitionH=$(".box-transition").innerHeight();
    if(type==0){
        if(h<=indexH){
            h=indexH;
        }
    }else{
        if(h<=transitionH){
            h=transitionH;
        }
    }
    $(".wrap-body").css({"min-height":h+"px"});
    $(".body").css({"min-height":h+"px"});
}
//左右出场
function transitionHorizontal(selector){
    $(selector).toggleClass("active")
}
//转场,type＝0，代表往左；＝1代表往右；＝2代表往上；＝3代表往下
function transition(selector,target,type){
    switch (type){
        case  0:
            $(selector).animate({
                left:"+=100%"
            },"fast");
            $(target).animate({
                left:"+=100%"
            },"fast",function(){
                $(selector).find("header").css({"position":"static"});
                if(target=="#index"){
                    $(target).find("header").css({"position":"fixed"});
                }
            });
            break;
        case  1:
            $(selector).animate({
                left:"-=100%"
            },"fast");
            $(target).animate({
                left:"-=100%"
            },"fast",function(){
                $(selector).find("header").css({"position":"static"});
                if(target=="#index"){
                    $(target).find("header").css({"position":"fixed"});
                }
            });
            break;
        case  2:
            $(selector).animate({
                top:"-=100%"
            },"fast");
            $(target).animate({
                top:"-=100%"
            },"fast",function(){
                $(selector).find("header").css({"position":"static"});
                if(target=="#index"){
                    $(target).find("header").css({"position":"fixed"});
                }
            });
            break;
        case  3:
            $(selector).animate({
                top:"+=100%"
            },"fast");
            $(target).animate({
                top:"+=100%"
            },"fast",function(){
                $(selector).find("header").css({"position":"static"});
                if(target=="#index"){
                    $(target).find("header").css({"position":"fixed"});
                }
            });
            break;
    }
}
//子分类的显示
function showCategory(current,target){
    $(current).hide();
    $(target).show();
}
//submit不刷新的提交
function submitNoRefresh(fn){
    event.preventDefault();
    if(fn){fn();}
}
//显示
function showDiv(selector){
    var dir=$(selector).attr("data-dir");
    $(selector).show();
    if(dir=="left"){
        $(selector).show().animate({
            right:0
        },1000);
        return false;
    }else if(dir=="right"){
        $(selector).show().animate({
            left:0
        },1000);
        return false;
    }else if(dir=="top"){
        $(selector).show().animate({
            bottom:0
        },1000);
        return false;
    }else{
        $(selector).show().animate({
            top:0
        },1000);
        return false;
    }
}
//隐藏
function hideDiv(selector){
    var dir=$(selector).attr("data-dir");
    $(selector).hide();
    if(dir=="left"){
        $(selector).animate({
            right:"-3000px"
        },1000);
        return false;
    }else if(dir=="right"){
        $(selector).animate({
            left:"-3000px"
        },1000);
        return false;
    }else if(dir=="top"){
        $(selector).animate({
            bottom:"-3000px"
        },1000);
        return false;
    }else{
        $(selector).animate({
            top:"-3000px"
        },1000);
        return false;
    }

}
function hideDiv2(selector){
    $("input:focus,textarea:focus").blur();
    $(selector).hide();
    $(selector).find(".box-order").animate({
        bottom:"-1000px"
    },1000,function(){
        $(".btn-zf").removeClass("active");
    });
}
//切换
function toggleDiv(self, selector){
    var self=$(self);
    self.toggleClass("active");
    if(self.hasClass("active")){
        $(selector).show();
        $(selector).find(".box-order").animate({
            bottom:"0px"
        },1000);
    }else{
        hideDiv2(selector);
    }
}
//显示pop
function showPop(selector){
    var h=$(document).height();
    $(selector).height(h).fadeIn();
}
//隐藏pop
function hidePop(selector){
    $(selector).fadeOut();
}
//点击toggleClass
function toggleclass(self,cn){
    $(self).toggleClass(cn);
}
//播放
function playVideo(selector){
    var video =$(selector),
        parent=video.parent();
    video[0].play();
    parent.find(".video-btn").hide();
    parent.find("img").hide();
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
//高度变高的拉伸效果
function changeHeight(selector,h){
    var self=$(selector),
        h1=self.find(".bd").height(),
        h2=self.find(".hd").height();;
    self.toggleClass("active");
    if(self.hasClass("active")){
        if(!h||h<0){
           h=h1+h2+"px";
        }
        self.animate({
            height:h
        });
    }else{
        self.animate({
            height:h2+"px"
        });
    }

}

//切换显示
function tab(current,selector,target){
    $(selector).hide();
    $(target).show();
    var self=$(current),
        p=self.parents("ul"),
        tag=self[0].tagName;
    p.find(tag).removeClass("active");
    if(current=="this"){
        self.addClass("active");
    }else{
        var currentClass=target.replace("#",".");
        p.find(currentClass).addClass("active");
    }
    window.location.href=target;
}
//获取URL＃参数
function getUrl(){
    var url=window.location.hash;
    return url;
}
//点击表单后
function focusForm(header,footer,fn1,fn2){
    $("input,select").focus(function(){
        if(header&&header!=""){
            $(header).css({"position":"absolute"});
        }
        if(footer&&footer!=""){
            $(footer).css({"position":"absolute"});
        }
        if(fn1){
            fn1()
        }
    });
    $("input,select").focusout(function(){
        if(header&&header!=""){
            $(header).css({"position":"fixed"});
        }
        if(footer&&footer!=""){
            $(footer).css({"position":"fixed"});
        }
        if(fn2){
            fn2();
        }
    });
}
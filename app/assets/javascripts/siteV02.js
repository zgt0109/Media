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
        var btn=$(input).children();
        btn.click(function(){
            var divs=$(idName).find("div");
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
//点击隐藏指定的div，隐藏指定的div
function showAndHind(se1,se2){
    $(se1).show();
    $(se2).hide();
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
//点击显示dd
function showSlider(selector){
    var dl=$(selector),
        dt=dl.find("dt"),
        dd=dl.find("dd");
    dt.click(function(){
        var cdt=$(this),
            cdl=cdt.parent(),
            cdd=cdl.find("dd");
        cdd.slideToggle();
        cdt.find(".fa-chevron-right").toggleClass("fa-chevron-down");
        cdl.prevAll().find("dd").slideUp();
        cdl.prevAll().find("dt").find(".fa-chevron-right").removeClass("fa-chevron-down");
        cdl.nextAll().find("dd").slideUp();
        cdl.nextAll().find("dt").find(".fa-chevron-right").removeClass("fa-chevron-down");
    });

}
//删除某自元素
function delTag(selector,tag){
    $(selector).find(tag).remove();
}

//页面过渡后的resize
function resize(selector,type){
    var h=$(selector).height(),
        stage=$("#stage"),
        w=stage.width(),
        $html=$("#html"),
        height=$html.height();
    if(h<height){h=height;}
    if($("#html").hasClass(type)){
        stage.height(h);
    }else{
        stage.removeAttr("style");
        stage.css({"min-height":h+"px"});
    }
    stage.attr("data-w",w);
    if($html.hasClass("dirL")){
        stage.animate({
            "left":"-"+w+"px"
        },"200s");
        //stage.css({"-webkit-transform":"translate(-"+w+"px,0)"});
    }else if($html.hasClass("dirR")){
        stage.animate({
            "left":w+"px"
        },"200s");
        //stage.css({"-webkit-transform":"translate(+"+w+"px,0)"});
    }else if($html.hasClass("dirT")){
        stage.animate({
            "top":"-"+h+"px"
        },"200s");
        //stage.css({"-webkit-transform":"translate(0,-"+h+"px)"});
    }else if($html.hasClass("dirB")){
        stage.animate({
            "top":h+"px"
        },"200s");
        //stage.css({"-webkit-transform":"translate(0,+"+h+"px)"});
    }else{
        scroll(0,0);
    }
}

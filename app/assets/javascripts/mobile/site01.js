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


    //单选
    $(".form-radio .box").click(function(){
        var self=$(this),
            $prev=self.prevAll(".box"),
            $next=self.nextAll(".box");
        self.toggleClass("selected");
        $prev.removeClass("selected");
        $next.removeClass("selected");
        $prev.find("input").prop("checked",false);
        $next.find("input").prop("checked",false);
        if(self.hasClass("selected")){
            self.find("input").prop("checked",true);
        }else{
            self.find("input").prop("checked",false);
        }
        return false;
    });
    //多选
    $(".form-checkbox .box").click(function(){
        var self=$(this);
        var length = 0;
        if(self.hasClass("selected")){
            self.find("input[type=checkbox]").attr("checked",false);
        }else{
            self.find("input[type=checkbox]").attr("checked",true);
        }

        self.toggleClass("selected");
        $.each($(".form-checkbox .box"), function(){
            var self = $(this);
            if(self.hasClass("selected")){
                length = length + 1;
            }
            return length
        });
        if($("#submit")){
            if(length > 0){
                $("#submit").attr('class', 'btn btn-bigest');
            }else{
                $("#submit").attr('class', 'btn btn-bigest btn-gray');
            }
        }
        return false;
    });
    //input 获得焦点，取消错误提示
    $(".input").focusin(function(){
        var self=$(this),
            li=self.parents(".form-li");
        li.removeClass("animated-vertical");
    });
});
function inputBlur(){
    $('input').blur();
}
//点击给制定的selector添加制定的class
function toggleToClass(selector,className){
    $(selector).toggleClass(className);
    return false;
}
//点击切换显示制定selector的类名
function changeToClass(selector,cn1,cn2){
    var cn=$(selector).attr("class");
    if(cn==cn1){
        $(selector).attr("class",cn2);
    }else{
        $(selector).attr("class",cn1);
    }
    return false;
}
//首页幻灯片
function indexSwipe(idNmane,texts){
    new Swipe(document.getElementById(idNmane), {
        speed:500,
        auto:3000,
        callback: function(){
            var lis = $(this.element).next("div").find("#pagenavi").children();
            lis.removeClass("active").eq(this.index).addClass("active");
            if(texts){

                $("#slider-span").html(texts[this.index]);
            }
        }
    });
    return false;
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
        var btn=$(input).children();
        btn.click(function(){
            var divs=$(idName).find("div");
            divs.toggleClass("on");
        });
    }, false);
    return false;
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
            $(".mod-load").addClass("loading").fadeIn();
            //$(".loading").removeClass("isloading").fadeOut();
        }
    });
    return false;
}
//底部下拉刷新
function btRefresh(h,fn){
    document.addEventListener("touchstart",function(e){
        var t=e.touches[0],
            y=t.pageY;
        $("body").attr("data-y",y);
    });
    document.addEventListener("touchmove",function(e){
        var t=e.touches[0],
            startY=parseInt($("body").attr("data-y")),
            pageY=startY-t.pageY;
        if(pageY>=h){
            $(".mod-load").addClass("loading").fadeIn();
            if(fn){
                fn();
            }
        }
    });
    return false;
}
//底部下拉刷新
function bottomRefresh(h,fn){
    document.addEventListener("touchmove",function(e){
        var a = document.documentElement.scrollTop==0? document.body.clientHeight : document.documentElement.clientHeight;
        var b = document.documentElement.scrollTop==0? document.body.scrollTop : document.documentElement.scrollTop;
        var c = document.documentElement.scrollTop==0? document.body.scrollHeight : document.documentElement.scrollHeight;
        if(a+b >= c){
            $(".mod-load").addClass("loading").slideDown();
            if(fn){
                fn();
            }
        }
    });

    return false;
}

//点击刷新(type=0,表示需要加载)
function clickRefresh(self,type){
    self=$(self);
    if(type==0){
        self.removeClass("load-btn").addClass("loading").html('<i class="fa fa-spinner"></i>正在加载..').show();
    }else{
        self.html("已全部显示");
    }

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
    return false;
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
    return false;
}
//点击显示弹出层（整个覆盖页面）
function showPop(selector){
    var h=$(document).innerHeight();
    $(selector).height(h).show();
    return false;
}
//点击隐藏弹出层
function hidePop(selector){
    $(selector).fadeOut();
    return false;
}
//点击隐藏指定的div，隐藏指定的div
function showAndHind(se1,se2){
    $(se1).show();
    $(se2).hide();
    return false;
}
//点击表单后
function focusForm(header,footer,fn1,fn2){
    $("input[data-input!='submit'],select").focus(function(){
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
    return false;
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
        cdt.find(">.fa").toggleClass("fa-chevron-down");
        cdl.prevAll().find("dd").slideUp();
        cdl.prevAll().find("dt").find(">.fa").removeClass("fa-chevron-down");
        cdl.nextAll().find("dd").slideUp();
        cdl.nextAll().find("dt").find(">.fa").removeClass("fa-chevron-down");
    });
    return false;
}
//点击显示dd
function showSliderCus(selector,openClass){
    var dl=$(selector),
        dt=dl.find("dt"),
        dd=dl.find("dd");
    dt.click(function(){
        var cdt=$(this),
            cdl=cdt.parent(),
            cdd=cdl.find("dd");
        cdd.slideToggle();
        cdt.find(">.fa").toggleClass(openClass);
        cdl.prevAll().find("dd").slideUp();
        cdl.prevAll().find("dt").find(">.fa").removeClass(openClass);
        cdl.nextAll().find("dd").slideUp();
        cdl.nextAll().find("dt").find(">.fa").removeClass(openClass);
    });
    return false;
}
//删除某自元素
function delTag(selector,tag){
    $(selector).find(tag).remove();
    return false;
}

//页面过渡后的resize
function resize(selector,type){
    var h=$(selector).innerHeight(),
        stage=$("#stage"),
        w=stage.width(),
        $html=$("#html"),
        height=$html.innerHeight();
    if(h<height){h=height;}
    console.log(h);
    if($("#html").hasClass(type)){
        stage.css({"min-height":h+"px"});
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
        stage.removeAttr("style");
    }
    return false;
}
//alert弹出层
function alertMessage(msg,fn){
    var h=$(".html").innerHeight();
    var $popTemp='<div class="mod-pop" style="display: block; height:'+h+'px"><div class="pop-bg"></div><div class="pop-box pop-alert"><p class="tcenter mt10">'+msg+'</p><p class="tcenter mt20"><a class="btn pop-close btn-confirm">确认</a><a class="btn pop-close">取消</a></p></div></div>';
    $("body").append($popTemp);
    //关闭弹出层
    $(document).on("touched click",".pop-close, .pop-bg",function(){
        $(".mod-pop").fadeOut(100).remove();
    });
    if(fn){
        $(document).on("touched click",".btn-confirm",function(){
            fn();
        });
    }
    return false;
}
//alert提示信息，自动消失
function alertTip(msg){
    var html='<div class="mod-tip">'+msg+'</div>';
    $("body").append(html);
    var w=parseInt($(".mod-tip").innerWidth())/2;
    $(".mod-tip").css({"margin":"0 0 0 -"+w+"px"});
    setTimeout(function(){
        $(".mod-tip").fadeOut(100).remove();
    },3000);
}
//单选 type=0代表多选
function labelSelect(select,type){
    $(select).click(function(){
        if(type==0){
            $(this).toggleClass("active");
        }else{
            $(select).removeClass("active");
            $(this).toggleClass("active");
        }

    });

}
//加减数字
function plusAndMinus(){
    var $div=$(".mod-number"),
        btnMinus=$div.find(".number-minus"),
        btnPlus=$div.find(".number-plus"),
        input=$div.find("input"),
        min=$div.attr("data-min"),
        max=$div.attr("data-max");
    btnMinus.click(function(){
        if(parseInt(input.val())>min&&(parseInt(input.val())-1)>=min){
            input.val(parseInt(input.val())-1);
        }
    });
    btnPlus.click(function(){
        if(parseInt(input.val())<max&&(parseInt(input.val())+1)<=max){
            input.val(parseInt(input.val())+1);
        }
    });
}
//收藏
function productSC(selector){
    var self=$(selector),
        small=self.find("small");
    toggleToClass(selector,'active');
    toggleToClass('.fa-star','fa-star-o');
    if(self.hasClass("active")){
        small.text("已收藏");
        self.addClass("animate-rotate1").removeClass("animate-rotate2");
    }else{
        small.text("收藏");
        self.removeClass("animate-rotate1").addClass("animate-rotate2");
    }
}
//倒计时
function countDown(secs,fn){
    for (var i = secs; i >= 0; i--) {
        (function(index) {
            setTimeout(function(){
                if(fn){
                    fn(index);
                }
            }, (secs - index) * 1000);
        })(i);
    };
}
function iScroll(id){
    var scrollBox = new IScroll(id, {
        scrollbars: false,
        mouseWheel: true,
        scrollY: false,
        scrollX: true,
        interactiveScrollbars: true,
        shrinkScrollbars: 'scale',
        fadeScrollbars: true,
        click: true
    });
    var DOM = $(id)[0];
    DOM.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
}
function showSearch(){
    var $search=$("#search");
    $search.slideToggle();
}
//reise图片
;(function($,win,doc){
    "use strict";
    $.cieldonResizeImg=function(el, options){
        var self=this,
            o,
            t;
        self.el=el;
        self.$el=$(el);
        self.$el.data("CieldonResizeImg",self);
        self.init=function(){
            self.options = o = $.extend({}, $.cieldonResizeImg.defaults, options);
            var h=self.$el.width();
            var $img= o.imgDiv;
            var n= o.n;
            self.$el.height(h+n);
            if($img.indexOf(",")>=0){
                $img=$img.split(",");
                $.each($img,function(i){
                    var $imgLi=self.$el.find($img[i]);
                    $imgLi.height(h);
                });
            }else{
                $img=self.$el.find($img);
                $img.height(h);
            }
        };
        self.init();
    };
    $.cieldonResizeImg.defaults={
    };
    $.fn.cieldonResizeImg=function(options,callback){
        return this.each(function(){
            var cdResizeImg = $(this).data('CieldonResizeImg');
            if ((typeof(options)).match('object|undefined')){
                if (!cdResizeImg) {
                    (new $.cieldonResizeImg(this, options));
                }
            }
        });
    };
})(jQuery, window, document);
!function($){
    $.fn.vcSwipe=function(id){
        var $this = $(this),
            $img = $this.find("img"),
            imgHtml = page = html = "",
            index = 0,
            $top = 0;
        $img.on("click",function(){
            index = $img.index($(this));
            $img = $(this).parent().children("img");
            var len = $img.length;
            $img.each(function(i){
                var self = $(this),
                    src = self.attr("data-url") || self.attr("src");
                imgHtml += '<li><img src="'+src+'"></li>';
                if(i == index){
                    page +='<a href="javascript:;" class="active"></a>'
                }else{
                    page +='<a href="javascript:;"></a>'
                }
            });
            html ='<div class="mod-swipe"><div class="mod-slider" id="'+id+'"><ul class="slider-list" >'+imgHtml+'</ul><div class="slider-text slider-center"><div id="pagenavi" class="slider-page">'+page+'</div></div></div></div>';
            $top = $("body").scrollTop();
            $(".html").css({"height":"100%","overflow":"hidden"}).scrollTop($top);
            $("body").append($(html).fadeIn());
            new Swipe(document.getElementById(id), {
                startSlide:index,
                speed:500,
                auto:3000,
                callback: function(){
                    var lis = $(this.element).next("div").find("#pagenavi").children();
                    lis.removeClass("active").eq(this.index).addClass("active");
                }
            });
        });
        $("body").on("click","#"+id+" img",function(){
            $(this).parents(".mod-swipe").fadeOut(function(){
                $(this).remove();
            });
            $(".html").removeAttr("style");
            $("body").scrollTop($top);
            imgHtml = page = html = "";
            $top = 0;
        });
    }
}(jQuery);
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require mobile/website_articles/swipe
$(function(){
    indexSwipe("banner",true,3000);
    autoHeight(".banner",400/720);
    menuAutoHeight();
    indexSwipe("list",true);
    // snowsFn();
    fade();
    navPop("#navPop-wrap","#navPop-btn");
    //newAudio();
    indexSwipe("navLine-menu");
    categorySelect();
    searchFn();
    //selectTheme();
});
function menuAutoHeight(){
    var el = ".list .box",
        $el = $(el),
        scale=$el.data("scale");
    autoHeight(el,scale);
}
//首页幻灯片
function indexSwipe(id,nav,time){
    if(nav){
        setSlide("#"+id);
    }
    var mySwipe = new Swipe(document.getElementById(id),{
        speed:500,
        auto:time || false,
        callback: function(){
            var lis = this.index;
            $("#"+id+" .sub-slide a").removeClass("active").eq(lis).addClass("active");
        }
    });
    var prev = $("#"+id).siblings(".slide-prev"),
        next = $("#"+id).siblings(".slide-next");
    prev.on("click",function(){
        mySwipe.prev();
    });
    next.on("click",function(){
        mySwipe.next();
    });
}
function autoHeight(el,scale){
    var $docW = $(el).width(),
        $elH = parseInt($docW*scale),
        $img = $(el).find(".menu-img");
    $(el).height($elH).css({"line-height":$elH+"px"});
}
function setSlide(elements){
    var lis = $(elements),
        len = lis.children().children("li").length,
        box= '<div class="sub-slide">',
        li = '<a href="javascript:;"></a>';
    for(var i = 0;i<len;i++){
        if(i==0){
            box += '<a href="javascript:;" class="active"></a>'
        }else{
            box += li;
        }
    }
    box +='</div>';
    lis.append(box);
}
function newAudio(){
    var $this = $(".mod-music"),
        $music= new Audio("assets/music/music.mp3"),
        $icon = $this.find("i");
    if($music.paused){
        $icon.attr("class","fa fa-volume-off");
        $(document).one("click touchstart",function(){
            $music.play();
            $icon.attr("class","fa fa-volume-up");
        });
    }
    $($this).on("click",function(){
        if($music.paused){
            $music.play();
            $icon.attr("class","fa fa-volume-up");
        }else{
            $music.pause();
            $icon.attr("class","fa fa-volume-off");
        }
    });
}
/**开场动画**/
//淡出
function fade(){
    var $this = $("#mod-animate"),
        $animate = $this.data("animate");
    switch($animate){
        case "fade1":
            setTimeout(function(){
                $this.fadeOut(3000);
            },3000);
            break;
        case "fade2":
            setTimeout(function(){
                $this.hide(1000);
            },3000);
            break;
        case "fade3":
            setTimeout(function(){
                $this.addClass("active");
                setTimeout(function(){
                    $this.hide();
                },500);
            },3000);
            break;
        case "fade4":
            setTimeout(function(){
                $this.addClass("active");
                setTimeout(function(){
                    $this.hide();
                },500);
            },3000);
            break;
        case "fade5":
            setTimeout(function(){
                $this.addClass("active");
                setTimeout(function(){
                    $this.hide();
                },500);
            },3000);
            break;
        case "fade6":
            setTimeout(function(){
                $this.addClass("active");
                setTimeout(function(){
                    $this.hide();
                },500);
            },3000);
            break;
        case "fade7":
            setTimeout(function(){
                $this.addClass("active");
                setTimeout(function(){
                    $this.hide();
                },500);
            },3000);
            break;
        default:
            break;
    }
}
function navPop(){
    var $this = $(".mod-navPop"),
        $btn = $this.find(".navPop-btn"),
        $menu = $this.find(".menu-pop");
    $btn.on("click",function(){
        $btn.toggleClass("active");
        $menu.toggleClass("on");
    });
    $menu.on("click",function(){
        $btn.toggleClass("active");
        $menu.toggleClass("on");
    });
}
// 分类选择
function categorySelect(){
    var $head = $(".head-name"),
        $cate = $(".category"),
        $cateMain = $cate.find(".category-main");
    $(document).on("click",".head-name",function(){
        if($head.is(".active")){
            $head.removeClass("active");
            $cateMain.slideUp(function(){
                $cate.hide();
                $(".main").removeAttr("style");
            });
        }else{
            $head.addClass("active");
            $cate.show();
            $cateMain.slideDown();
            $(".main").css({height:"100%",overflow:"hidden"})
        }
    });
    $(document).on("click",".category-bg",function(){
        $head.removeClass("active");
        $cateMain.slideUp(function(){
            $cate.hide();
            $(".main").removeAttr("style");
        });
    });
}
// 搜索
function searchFn(){
    $(document).on("click",".search",function(){
        var $search = $(".search-box");
        $search.toggle().find("input").focus();
    });
}
// 选择模板js 正式环境不需要
function selectTheme(){
    var html = '<div class="slide-bar"><a href="javascript:;" data-class="theme-1">色系1</a><a href="javascript:;" data-class="theme-2">色系2</a><a href="javascript:;" data-class="theme-3">色系3</a><a href="javascript:;" data-class="theme-4">色系4</a></div><style>.slide-bar{position:fixed;right:10px;bottom:100px;}.slide-bar a{padding:5px;color:#fff;display:block;width:60px;height:30px;margin:5px 0;background:rgba(0,0,0,.7);border:1px solid  #ccc;}</style>';
    $("body").append(html);
    $(document).on("click",".slide-bar a",function(){
        var $this = $(this),
            $class = $this.data("class");
        $(".main").attr("class","main "+$class);
    })
}


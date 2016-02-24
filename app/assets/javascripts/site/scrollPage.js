function scrollPage(options){
    var defaults = {
        // sections: ".page",
        // nav: ".next-page",
        // btnSelector: ".next-page",
        easing: "jswing",
        duration: 500,
        getTarget: null
    };
    var o = $.extend(defaults, options);
    
    var scrollStatu = false;
    var sec = $(o.sections);
    var secLength = sec.length;
    var nowPage = 0;

    var scrollTo = function(callback){
        var winHeight = $(window).height();
        // var target = (nowPage == 2) ? (-(nowPage-1) * winHeight - 260) : (-nowPage * winHeight);
        var target;
        if(o.getTarget){
            target = o.getTarget(nowPage, winHeight);
        }else{
           target =  -nowPage * winHeight;
        }
        //修改nav状态
        $(o.nav).removeClass(o.navCurrClass).eq(nowPage).addClass(o.navCurrClass);
        // 开始滚屏
        $(".container").stop().animate({"margin-top": target},o.duration,o.easing, function(){
            scrollStatu = false;
        });
    };

    $(o.sections).eq(0).addClass("active");
    $(document).on("mousewheel", function(e, delta){
        if(!scrollStatu){
            scrollStatu = true;
            if(delta < 0){
                if(nowPage < secLength-1) nowPage++;
                $(o.sections).removeClass("active").eq(nowPage).addClass("active");
            }else{
                if(nowPage > 0) nowPage--;
                $(o.sections).removeClass("active").eq(nowPage).addClass("active");
            }

            scrollTo();   
        }
    }).on("click", o.btnSelector, function(){
        nowPage = parseInt($(this).data("page"));
        scrollTo();
    });

    // page scroll nav
    $(o.nav).on("click", function(){
        nowPage = $(o.nav).index(this);
        scrollTo();
    });

    $("[data-scroll]").on("click",function(){
        var id = $(this).data("scroll");
        nowPage = id-1;
        $(o.sections).removeClass("active").eq(nowPage).addClass("active");
        scrollTo();
    });

    $(window).resize(function(){
        var winHeight = $(window).height();
        var target = (nowPage == 2) ? (-(nowPage-1) * winHeight - 260) : (-nowPage * winHeight);
        $(".container").css({"margin-top": target});
    });
}

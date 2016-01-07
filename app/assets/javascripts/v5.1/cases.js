$(function(){
    (function(){
        var div = $(".wrapp"),
            ul = $("ul", div),
            li = $("li", ul),
            wid = li.outerWidth(true),
            len = li.length,
            btns = $(".i-btns-item"),
            curr = 0,
            oldCurr = 0,
            timer = null,
            btn = $(".btn"),
            spanlen = btns.length;
        btns.parent().width( spanlen*32-16); 
        $(".silde_btn").width( spanlen*32-16+28*2 );

        slider = function(direction){
            if(curr == oldCurr) return false;
            var direction = curr > oldCurr ? 1 : -1;

            var item = li.eq(curr).css({display: "block"}).siblings("li").hide();
            li.eq(curr).addClass("active").siblings("li").removeClass("active");

            btns.removeClass("active").eq(curr).addClass("active");

            oldCurr = curr;
        },
        btn.eq(0).on("click", function(){
            curr = --curr<0 ? len-1 : curr;
            slider(-1);
        });
        btn.eq(1).on("click", function(){
            curr = ++curr>len-1 ? 0 : curr;
            slider(1);
        });

        $(".i-btns").on("click", ".i-btns-item", function(){
            curr = $(this).index();
            slider();
        });
        btns.eq(curr).addClass("active");
        li.eq(curr).addClass("active").fadeIn(400);
    })();
});

$(function(){
    var navHover = $(".mod-nav-hover");
    var navActiveIndex = $(".mod-nav .nav-cur").index();
    var navActiveTop = $(".mod-nav .nav-cur").position().top;
    var curr = 0;
    var h3Height = $(".mod-nav-h3").outerHeight(true);

    $(".mod-nav").on("mouseenter", "li", function(){
        var aimTop = $(this).position().top;

        if(!$(this).hasClass('nav-cur')){
            $(".nav-cur").removeClass('nav-cur');
        }

        navHover.stop(true, false).animate({
            top: aimTop + h3Height
        }, 300);
    }).on("mouseleave", function(){
        $(".mod-nav li").eq(navActiveIndex).addClass('nav-cur');

        navHover.stop(true, false).animate({
            top: navActiveTop + h3Height
        });
    }).trigger("mouseleave");

});
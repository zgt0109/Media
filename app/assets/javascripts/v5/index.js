$(function(){
    // index banner
    (function(){
        var div = $(".i-ban"),
            ul = $("ul", div),
            li = $("li", ul),
            wid = li.outerWidth(true),
            len = li.length,
            btn = $(".btn", div),
            curr = 0,
            timer = null,
            slider = function(direction){
                var item = li.eq(curr).css({display: "block", left: direction*wid});

                ul.stop(true, false).animate({left: -direction*wid}, function(){
                    $(this).css({left: 0});
                    item.css({left: 0}).siblings("li").hide();

                    display();
                });
            },
            display = function(){
                var item = li.eq(curr);
                item.addClass("active").siblings("li").removeClass("active")
            };

        btn.eq(0).on("click", function(){
            curr = --curr<0 ? len-1 : curr;
            slider(-1);
        });
        btn.eq(1).on("click", function(){
            curr = ++curr>len-1 ? 0 : curr;
            slider(1);
        });

        li.eq(curr).addClass("active").fadeIn(400);
    })();

});
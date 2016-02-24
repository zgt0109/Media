$(function(){
    // index banner
    (function(){
        var div = $(".i-ban"),
            ul = $("ul", div),
            li = $("li", ul),
            wid = li.outerWidth(true),
            len = li.length,
            btns = $(".i-btns-item"),
            curr = 0,
            oldCurr = 0,
            timer = null,
            spanlen = btns.length;
        btns.parent().width( spanlen*54);
        btns.parent().css("margin-right",-spanlen*54/2 );

        slider = function(direction){
            if(curr == oldCurr) return false;
            var direction = curr > oldCurr ? 1 : -1;

            var item = li.eq(curr).css({display: "block", left: direction*wid});
            btns.removeClass("active").eq(curr).addClass("active");
            ul.stop(true, false).animate({left: -direction*wid}, function(){
                $(this).css({left: 0});
                item.css({left: 0}).siblings("li").hide();
                li.eq(curr).addClass("active").siblings("li").removeClass("active")
            });
            oldCurr = curr;
        },
            slideAuto = function(){
                timer = setInterval(function(){
                    curr = (++curr > len-1) ? 0 : curr;
                    slider();
                }, 5000);
            };

        div.on("mouseleave", function(){
            slideAuto();
        }).on("mouseenter", function(){
            clearInterval(timer);
        });

        $(".i-btns").on("click", ".i-btns-item", function(){
            curr = $(this).index();
            slider();
        });
        btns.eq(curr).addClass("active");
        li.eq(curr).addClass("active").fadeIn(400);
    })();


    (function(){
        var HL = $(".case_tab li");
        var BL = $(".case_detail li");
        var line = $(".case_line");
        var curr = 0;
        var currClick = 0;
        var liWidth = HL.outerWidth(true);

        $(".case_tab").on("click", "li", function(){
            var self = $(this);
            curr = currClick = self.index();
            self.addClass('main_cur').siblings().removeClass('main_cur');
            BL.hide().eq(curr).show();
            var aimLeft = curr * liWidth;
            line.stop(true, false).animate({ left: aimLeft}, 300);
        }).find("li").eq(0).trigger("click");

    })();


});

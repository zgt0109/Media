
// platform dialog 图片切换事件绑定
$.platformBindLayerSlider = function(){
    var div = $(".platform-layer-scroll");
    var ul = $(".platform-layer-ul", div);
    var li = $(".platform-layer-item", ul);
    var liLen = li.length;
    var liWidth = li.outerWidth(true);
    var cellLen = Math.ceil(liLen/2);
    var cellWidth = liWidth * 2;
    var curr = 0;
    var arrow = $(".platform-layer-arrow");

    function slider(){
        ul.animate({
            left: -cellWidth * curr
        }, 600);
    }

    arrow.eq(1).on("click", function(){
        curr = (++curr > cellLen-1) ? (cellLen-1) : curr;
        slider();
    });
    arrow.eq(0).on("click", function(){
        curr = (--curr < 0) ? 0 : curr;
        slider();
    });

    ul.width(liLen * liWidth);
};
// platform dialog 模板渲染，并返回渲染好的html
$.platformRenderTpl = function(tpl, data){
    $.each(data, function(key, val){
        var replaceData = val;
        if(key == "imglist"){
            var list = "";
            $.each(val, function(key2, val2){
                list += '<li class="platform-layer-item"><img src="' + val2 + '" width="167" height="289" alt=""></li>';
            });
            replaceData = list;
        }

        tpl = tpl.replace("{"+key+"}", replaceData);
    });
    return tpl;
};



$(function(){
    var win = $(window);

    //************************************* section1 *******************************
    // ballon
    (function(){
        var ballonHover = $(".p1-ballon-hover");
        $(".page1 .p1-show").on("mouseenter", ".p1-ballon-wrapp", function(){
            $(this).prev().stop(true, false).fadeIn(400);
        }).on("mouseleave", ".p1-ballon-wrapp", function(){
            $(this).prev().stop(true, false).fadeOut(400);
        });

        var page1 = $(".page1");
        var ballon = $(".p1-ballon");
        var winSize = [win.width(), win.height()];
        var page1Size = [page1.width(), page1.height()];
        var page1Center = [page1Size[0]/2, page1Size[1]/2];

        page1.on("mousemove", function(e){
            var diffCenterX = e.pageX - page1Center[0];
            var diffCenterY = e.pageY - 81 - 300 - page1Center[1];
            var diffCenter = Math.sqrt(Math.pow(diffCenterX, 2) + Math.pow(diffCenterY, 2));
            // console.log(diffCenterX, diffCenterY, diffCenter)
            var diff = Math.round(diffCenter/30);

            ballon.each(function(i){
                var dict = (i%2 == 0) ? 1 : -1
                $(this).css({ "margin-top": dict * diff});
            });
            
        });
    })();

    // btns scroll && hover
    (function(){
        // 定义共享的当前索引值
        var curr = 0;
        var timer;
        
        // img scroll
        (function(){
            var ul = $(".p1-show-clip ul");
            var li = ul.find("li");
            var wid = li.outerWidth(true);
            var len = li.length;
            var oddCurr = -1;
            var txtLi = $(".p1-txt");
            var btnList = $(".p1-btns-item");
            // var curr = 0;

            $(".p1-btns").on("mouseenter myclick", ".p1-btns-item", function(){
                curr = $(this).index();
                var liCurr = li.eq(curr);
                var dict = (curr > oddCurr) ? 1 : -1

                if(oddCurr == curr) return false;
                
                txtLi.eq(curr).stop(true, false).fadeIn().siblings(".p1-txt").stop(true, false).fadeOut();
                $(this).addClass("p1-btns-item-hover").siblings().removeClass("p1-btns-item-hover");

                liCurr.css({
                    display: "block",
                    left: dict * wid
                });

                ul.stop(true, false).animate({ left: -dict * wid }, 400, function(){
                    ul.css({ left: 0 });
                    li.hide();
                    liCurr.css({
                        display: "block",
                        left: 0
                    });
                });

                // 记录本次的索引与下次做对比
                oddCurr = curr;
            });

            li.eq(curr).fadeIn(500);
            $(".p1-btns-item").eq(0).trigger("mouseenter");
        })();
        // btns scroll
        (function(){
            var div = $(".p1-btns");
            var ul = $("ul", div);
            var li = $("li", ul);
            var visible = 7;
            var visibleHref = Math.ceil(visible/2);
            var num = li.length;
            var wid = li.outerWidth(true);
            var arrow = $(".p1-btns-arrow");
            // var curr = 0;
            

            ul.width(num * wid);

            div.on("myclick", ".p1-btns-item", function(){
                curr = $(this).index();

                if(curr<visibleHref){
                    ul.stop(true,false).animate({'left':'0'},500)
                }else if(curr < (num - visibleHref)){
                    ul.stop(true,false).animate({'left':-(curr-visibleHref+1)*wid},500)
                }else{
                    ul.stop(true,false).animate({'left':-(num-visible)*wid},500)
                }
            });

            arrow.eq(1).on("click", function(){
                curr = ++curr>(num-1) ? 0 : curr;
                li.eq(curr).trigger("myclick");
            })
            arrow.eq(0).on("click", function(){
                curr = --curr<0 ? (num-1) : curr;
                li.eq(curr).trigger("myclick");
            });
            
            // auto slide
            div.on("mouseenter", function(){
                clearInterval(timer);
            }).on("mouseleave", function(){
                clearInterval(timer);
                timer = setInterval(function(){
                    curr = ++curr>(num-1) ? 0 : curr;
                    li.eq(curr).trigger("myclick");
                }, 2000);
            }).trigger("mouseleave");

        })();
    })();


    //************************************* section2 *******************************
    // btns hover
    (function(){
        $(".p2-btns").on("mouseenter", ".p2-btns-items", function(){
            $(this).addClass("hover").find(".p2-btns-blcok").eq(0).stop(true, false).animate({"margin-top": -60});

            $(this).siblings(".p2-btns-items").removeClass("hover").find(".p2-btns-blcok").each(function(){
                $(this).eq(0).stop(true, false).animate({"margin-top": 0});
            });
        });
    })();

    // img scroll
    (function(){
        var ul = $(".p2-show-clip ul");
        var li = ul.find("li");
        var txtLi = $(".p2-txt");
        var wid = li.outerWidth(true);
        var len = li.length;
        var curr = 0;
        var oddCurr = -1;

        li.eq(curr).fadeIn(500);

        $(".p2-btns").on("mouseenter", ".p2-btns-items", function(){
            curr = $(this).index();
            var liCurr = li.eq(curr);
            var dict = (curr > oddCurr) ? 1 : -1

            if(oddCurr == curr) return false;

            txtLi.eq(curr).stop(true, true).fadeIn().siblings(".p2-txt").stop(true, true).fadeOut();

            liCurr.css({
                display: "block",
                left: dict * wid
            });
            ul.stop(true, false).animate({ left: -dict * wid }, 400, function(){
                ul.css({ left: 0 });
                li.hide();
                liCurr.css({
                    display: "block",
                    left: 0
                });
            });

            oddCurr = curr;
        }).find(".p2-btns-items").eq(0).trigger("mouseenter");
    })();
        //到达底部去除浮动框
    var offsetH = $(".footer-wrapp").offset().top,
        winH = $(window).height();
    $(window).scroll(function() {
        if(  $(document).scrollTop() > offsetH-winH ){
            $(".float_bottom").css("display","none");
        }else{
            $(".float_bottom").css("display","block");
        }
    });        

});
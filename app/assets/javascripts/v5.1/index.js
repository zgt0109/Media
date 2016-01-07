$(function(){
    // index banner
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

    $(".productImg").on("mouseenter", function(){
        $(this).find("img").stop(true,true).animate({width:"+=40px",height:"+=40px",left:"-=20px",top:"-=20px"});
    }).on("mouseleave", function(){
        $(this).find("img").stop(true,true).animate({width:"-=40px",height:"-=40px",left:"+=20px",top:"+=20px"})
    });
    // index_notice
    (function(){
        var ndiv = $(".i-notice-wrapp"),
            nul = $(".i-notice-scroll"),
            nli = $(".i-notice-item"),
            nlen = nli.length,
            nhei = nli.outerHeight(true),
            ncurr = 0,
            ntimer = null,
            nslideAuto = function(){
                ntimer = setInterval(function(){
                    ncurr = (++ncurr > nlen-1) ? 0 : ncurr;
                    nul.stop(true, false).animate({
                        top: -ncurr * nhei
                    });
                }, 3000);
            };

        $(".i-notice").on("mouseleave", function(){
            nslideAuto();
        }).on("mouseenter", function(){
            clearInterval(ntimer);
        });
        nslideAuto();

    })();

});
//media report
$(function(){
    var HL = $(".media_title li"),
        BL = $(".media_item li"),
        line = $(".case-hd-line"),
        curr = 0,
        liWidth = HL.outerWidth(true);
    $(".media_title").on("click", "li", function(){
        curr = $(this).index();
        $(this).addClass('main_cur').siblings().removeClass('main_cur');
        BL.hide().eq(curr).show();
        var aimLeft = 14 + curr * liWidth;
        line.stop(true, false).animate({ left: aimLeft}, 300);
    }).find("li").eq(0).trigger("click");

    // (function(){
    //    var PHL = $(".pro_title ul"),
    //     PHLli = $("li",PHL),
    //     PBL = $(".pro_item ul"),   
    //     PBLli =$("li",PBL),        
    //     liwid = PBLli.outerWidth(true),
    //     poldCurr = 0,
    //     current = 0; 
    //     $(".pro_title").on("click", "li", function(){
    //         if($(this).is(".pro_cur")){
    //             return false;
    //         }
    //         current = $(this).index();
    //         var pro_direction = current > poldCurr ? 1 : -1;
    //         $(this).addClass('pro_cur').siblings().removeClass('pro_cur');
    //         var pitem = PBLli.eq(current).css({display: "block", left: pro_direction*liwid}); 
    //         PBL.stop(true, false).animate({left: -pro_direction*liwid}, function(){
    //             $(this).css({left: 0});
    //             pitem.css({left: 0}).siblings("li").hide();
    //             PBLli.eq(current).addClass("active").siblings("li").removeClass("active")
    //         });
    //         poldCurr = current;
    //     }).find("li").eq(0).trigger("click");
    // })();
    $(".media_right").on("click",function(){
        playVideo(0);
    });
    $(".videopeak-close").on("click",function(){
        $('#pop_video').css('display','none');
        $('#cover_video').css('display','none');
        $('#flash_player_id').remove();
    })

});

/*打开视频*/
var video_map = ['uu=3354dccd8a&vu=ff902617b5&auto_play=1&gpcflag=1&width=860&height=480'];
function playVideo($key)
{
    $key = parseInt($key);
    $key = Math.max(0, Math.min($key, Math.max(0, (video_map.length - 1))));

    var $video_key = video_map[$key];

    var $html = '<embed id="flash_player_id" src="http://yuntv.letv.com/bcloud.swf" allowFullScreen="true" quality="high"  width="860" height="480" align="middle" allowScriptAccess="always" flashvars="'+$video_key+'" type="application/x-shockwave-flash"></embed>';
    $('#flash_player_box').html($html);
    $('#cover_video').css('display','block');
    $('#pop_video').css('display','block');
}


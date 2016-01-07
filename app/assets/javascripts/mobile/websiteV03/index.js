$(function(){
    vcPlus.indexSwipe("banner",true,3000);
    vcPlus.newAudio();
});
var vcPlus = {
    indexSwipe : function (id,nav,time){
        if(nav){
            vcPlus.setSlide("#"+id);
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
    },
    setSlide : function (elements){
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
    },
    bottomLoad:function(callBack){
        var $winH = $(window).height(),
            $docH = $(document).height(),
            $top,$start,$end,$move,
            isLoad = $(".loading").length;
        document.addEventListener("touchstart",function(e){
            if(e.touches.length > 1){
                return false;
            }
            var t=e.touches[0];
            $start = t.pageY;
            document.addEventListener("touchmove");
        });
        document.addEventListener("touchmove",function(e){
            var t=e.touches[0];
            $top = $(document).scrollTop();
            $docH = $(document).height();
            $end = t.pageY;
            $move = $start-$end;
            isLoad = $(".loading").length;
            if($top+$move+$winH > $docH+30 && !isLoad){
                var maxN = $top+$move+$winH - $docH;
                maxN = maxN >=100 ? 100 : maxN;
                $("section").css("padding-bottom",maxN);
            $(".main section").append('<div class="loading"><i class="icon-loading"></i>加载中</div>');
                setTimeout(function(){
                    isLoad = true;
                $("section").animate({"padding-bottom":0},500,function(){
                    $("section").removeAttr("style");
                    isLoad = false;
                });
                if(callBack)callBack();
                },200);
            }
        });
    },
    newAudio : function (){
        var $this = $(".mod-music"),
            url = $this.data("url"),
            $music= new Audio(url),
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
}
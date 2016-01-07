$(function () {

})
function autoHeight(el,scale){
    var $docW = $(el).width(),
        $elH = parseInt($docW*scale),
        $img = $(el).find(".menu-img");
    $(el).height($elH)
}

function topLoad(callBack){
    var $top,$start,$end,$move;
    document.addEventListener("touchstart",function(e){
        var t=e.touches[0];
        $top = $(document).scrollTop();
        $start = t.pageY;
    });
    document.addEventListener("touchmove",function(e){
        var t=e.touches[0];
        $end = t.pageY;
        $move = $end - $start;
        if($top-$move<=0){
            $(".mod-load").addClass("loading").fadeIn();
        }
    });
    document.addEventListener("touchend",function(e){
        callBack();
    });
}
function bottomLoad(callBack){
    $(window).scroll(function(){
        var scrollTop = $(this).scrollTop();               //滚动条距离顶部的高度
        var scrollHeight = $(document).height();          //当前页面的总高度
        var windowHeight = $(this).height();               //当前可视的页面高度

        if(scrollTop + windowHeight >= scrollHeight){        //距离顶部+当前高度 >=文档总高度 即代表滑动到底部
            $(".mod-load").addClass("loading");
            callBack();
        }
    });
}

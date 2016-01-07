$(function(){
    var utils = new window.Zutils();

    myslide();
    function myslide(){
        var imgBox = $(".main-img");
        utils.loadImg(imgBox.find("img").attr("src"), function(w, h){
            var B = $(".main-img img").height();
            var yeahBox = $(".yeah-box1");
            // yeahBox.animate({"bottom":B + 80 + "px",},10);
            yeahBox.animate({"left":"50%"},700);
            imgBox.delay(500).animate({"bottom":"0"},700);
        }); 
    };

    window.onresize=function(){ 
        var BH = $("body").height();
        var imgBox = $(".main-img");
        utils.loadImg(imgBox.find("img").attr("src"), function(w, h){
            var B = $(".main-img img").height();
            var yeahBox = $(".yeah-box1");
            var yeahBoxp = $(".yeah-boxp");
            var logoImg =  $(".logo-img img");

            if(BH < 900){
                yeahBox.animate({"bottom":B + 40 + "px",},10);
                yeahBoxp.css({
                    "font-size":"18px"
                });
                logoImg.css({
                    "width":"160px",
                    "height":"70px",
                    "padding-left":"240px",
                });
            }else{
                yeahBox.animate({"bottom":B + 80 + "px",},10);
                yeahBoxp.css({
                    "font-size":"24px"
                });
                logoImg.css({
                    "width":"234px",
                    "height":"100px",
                    "padding-left":"193px",
                });
            }        
        });

        $(function(){
            var WW = $("body").width();
            var LB = $(".li-box").width();
            $(".li-box").css({"left":(WW-LB)/2});
        });
    }; 

    
    window.onload=function(){
        var WW = $("body").width();
        var LB = $(".li-box").width();
        $(".li-box").css({"left":(WW-LB)/2});
    };

    // full page
    (function(){
        var footHeight = $(".footer-wrapp").outerHeight(true);
        scrollPage({
            sections: ".page",
            nav: ".page-nav",
            navCurrClass: "rolling-cur",
            btnSelector: ".next-page",
            getTarget: function(nowPage, winHeight){
                return  (nowPage == 2) ? (-(nowPage-1) * winHeight - footHeight) : (-nowPage * winHeight);
            }
        });
    })();

    
    // 轮播
    tradition(4000,900,1920);
    
});
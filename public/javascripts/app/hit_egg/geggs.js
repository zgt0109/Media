$(function(){
    //a.active
	$("a").on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
             $(this).removeClass("active");
        }
    });
    //scene
    $("#scene").animate({
        top:0
    },"fast").animate({
        top:-20
    },"fast").animate({
        top:0
    },"fast",function(){
        $("#shine").animate({
            opacity:0.8
        },"slow",function(){
            $("#egg1").animate({
                left:"-10%",
                opacity:1
            },"fast",function(){
                $("#egg2").animate({
                    bottom:"-10px",
                    opacity:1
                },"fast").animate({
                    bottom:"-20px"
                },"fast").animate({
                    bottom:"-10px"
                },"fast", function(){
                    $("#egg3").animate({
                        right:"5%",
                        opacity:1
                    },"fast",function(){
                        $("#text-index").animate({
                            top:20
                        });
                    });
                });
            });
        });
    });
    //点击egg
//    $(".game-egg a").click(function(){
//        var self=$(this);
//        self.addClass("active").addClass("first");
//        setTimeout(function(){
//            self.removeClass("first").addClass("second");
//            $("#scene-index").delay(1000).fadeOut(function(){
//                var r=self.attr("data-r");
//                if(r==0){
//                    $("#text-success").animate({
//                        top:0
//                    },"fast");
//                }else if(r==1){
//                    $("#text-fail").animate({
//                        top:0
//                    },"fast");
//                }else{
//                    alert("不好意思，您已经砸过了");
//                    $("#scene-index").fadeIn();
//                }
//            });
//        },1000);
//    });


});

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
    var type=$("body").attr("data-type");
    if(type=="1"){
        $("#text-end").animate({
            top:"50%"
        },"fast");
    }else if(type=="2"){
        $("#text-start").animate({
            top:"50%"
        },"fast");
    }else{
        $("#scene-index").fadeIn();
    }
    //领奖
    $(".btn-success, .box-list .btn").click(function(){
        var h=$(document).height();
        $("#pop-form").height(h);
        $("#pop-form").show();
    });
    $("#btn-award").click(function(){
        var self=$(this);
        $("#pop-form").hide();
        popResult(0,"提交成功！",$("#text-success"),$("#scene-index"));
        //popResult(1,"提交失败",$("#text-success"),$("#scene-index"));
        //popResult(1,"手机号码输入有误","",$("#pop-form"));
    });
    //查看获奖列表
    $("#btn-list").click(function(){
        var result=$("#sec-result"),
            h=$(document).height();
        result.height(h).fadeIn();
    });
    //返回主页面
    $(".btn-back").click(function(){
        $("#sec-result").fadeOut();
    });
    $(".pop-bg").click(function(){
        $(".pop").fadeOut();
    });
    //老虎机
    $("#btn-start").click(function(){
      if($(this).text() == '开始' || $(this).text() == '没有中奖, 再来一次'){
    	  $(this).hide();
          if( !$(this).hasClass("active") ){
           $(this).addClass("active");
            submitSlot();
          }
       }
    });
});

function startGame(c,s,selector){
    var p=$(selector),
        h=parseInt(p.height()),
        size=parseInt(p.find("span").length),
        html=p.html(),
        n=(s*c)/h;
    if(!p.hasClass("active")){
        p.addClass("active");
        for(var i=0; i<=n; i++){
            p.append(html);
        }
    }else{
        p.css({"top":0});
    }
    for(var t=0;t<c;t++){
        p.animate({
            top:"-="+s
        },function(){
            var top=-Math.round(p.position().top);
            var span=p.find("span");
            if(top==s*c){
                var result=parseInt(p.attr('data-result'));
                if(result==0){result+=size;}
                var $top=-(parseInt($(span[result]).position().top)-25);
                setTimeout(function(){
                    p.animate({
                        top:$top
                    },"slow");
                },100);

                if ( p.closest('.game-box').attr('id') == 'game-3' ) {
                  // setTimeout(function(){ submitSlot() }, 200);
                  setTimeout(function(){ $('#btn-start').removeClass("active").show()}, 200);
                }

                return false;
            }
        });
    }

}

function submitSlot(){
  // var index1 = $('#game-1 p').data('result');
  // var num1 = $('#game-1 p span').eq(index1).data('id');

  // var index2 = $('#game-2 p').data('result');
  // var num2 = $('#game-2 p span').eq(index2).data('id');

  // var index3 = $('#game-3 p').data('result')
  // var num3 = $('#game-3 p span').eq(index3).data('id');

  $.ajax({
      type: "get",
      url: "/app/slots/slot",
      // data: {element_ids: num1 +','+ num2 +','+ num3},
      success: function(data) {
      }
  });
}

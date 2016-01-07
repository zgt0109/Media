$(function(){
    //a.active
    $("a,.btn").on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
             $(this).removeClass("active");
        }
    });
    $("body").on("click",".J-close",function(){
        hideTips(".alert");
    });
});
function popResult(type,string){
    var h=$(".html").innerHeight();
    var html='';
    if(type==0){
        html+='<div class="pop pop-result result-success"';
    }else{
        html+='<div class="pop pop-result result-fail"';
    }
    html+=' id="pop-result" style="height:'+h+'px"><div class="pop-bd"><div class="box-pop"><span>'+string+'</span></div></div></div>';
    $("body").append(html);
    $(document).on("click",".btn-success",function(){
        var result=$("#pop-result");
        result.fadeOut(function(){
            hidePop(result)
        });
    });
}
//提示信息，自动消失 0表示成功，1表示失败
function alertMessage(type,string){
    var h=$(".html").innerHeight();
    var html='';
    if(type==0){
        html+='<div class="pop pop-result result-success"';
    }else{
        html+='<div class="pop pop-result result-fail"';
    }
    html+=' id="pop-result" style="height:'+h+'px"><div class="pop-bd"><div class="box-pop"><span>'+string+'</span></div></div></div>';
    $("body").append(html);
    setTimeout(function(){
        var result=$("#pop-result");
        result.fadeOut(function(){
            hidePop(result)
        });
    },3000);
}
//打开分享信息
function showShare(){
    var h=$(".html").innerHeight();
    var html='<div class="pop pop-share" style="height:'+h+'px" onclick="hidePop(this)"><div class="pop-bd"><p class="note-share"></p></div></div>';
    $("body").append(html);
}
//隐藏pop
function hidePop(selector){
    $(selector).remove();
}
//我要领奖
// function getSuccess(self,fn){
//     var h=$(".html").innerHeight();
//     self=$(self);
//     var sn=self.attr("data-sn");
//     var html='<div class="pop pop-form" id="pop-form" style="height:'+h+'px"><div class="pop-bd"><div class="box-pop"><div class="hd"><b>恭喜你，中奖了！</b></div><div class="bd"><p><b>你中的是二等奖，</b><br/>兑奖SN码：'+sn+'</p><p>请留下您的手机号码，我们的工作人员会联系发奖。</p><p><span>请输入您的手机号</span><input type="text" class="input"/></p><p><input id="btn-award" class="btn" type="submit" value="提交"/></p></div></div></div></div>';
//     $("body").append(html);
//     $(document).on("touchend click","#btn-award",function(){
//         setTimeout(function(){
//             hidePop("#pop-form");
//         },500)
//     });
//     if(fn){
//         fn();
//     }
// }
function showTips(elements){
    $(elements).fadeIn();
    $(".html").css({"height":"100%","overflow":"hidden"});
}
function hideTips(elements){
    $(elements).fadeOut();
    $(".html").removeAttr("style");
}
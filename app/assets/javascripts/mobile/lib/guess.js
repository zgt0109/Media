//= require jquery
//= require jquery_ujs
//= require mobile/winwemedia01.js
//= require lib/validators
$(function () {
  //   //点击显示二维码
  //   $(document).on("click", ".page-list li.have>.title", function () {
  //     $(".showewm").show().addClass("pop");
  //     setTimeout(function(){
  //       $(".showewm").addClass("show");
  //     },10);
  // });
  // $(document).on("click", ".showewm.show", function () {
  //   $(".showewm").removeClass("show pop").hide();
  // });
  //选择答案
  $(".page-question .answers li").on("click", function () {
      $(".page-question .answers li").removeClass("yes");
      $(this).addClass("yes");
      $('#guess_participation_answer').val($(this).data('key'));
  });
  $(document).on("click","[data-dismiss=modal]",function(){
    $(".popup").fadeOut(function(){
      $(".popup").remove();
    });
  });
});

$(document).on('click', '.reload-guess', function(){
  window.location.reload();
})

function alertTip(options){
  var defaults = {
      title : "系统提示",
      text : "系统提示",
      id : "",
      btnText : "确定"
    },
    opt = $.extend({},defaults,options),
    html ='';
  html = $('<div class="popup"><div class="pop-body"><div class="pop-t">'+opt.title+'</div><div class="pop-m">'+opt.text+'</div><div class="pop-f"><div class="cell"><a href="javascript:;" data-dismiss="modal" class="btn btn-yellow reload-guess">'+opt.btnText+'</a></div></div></div></div>');
  $("body").append(html.fadeIn());
  var height = $(".pop-body").outerHeight();
  $(".pop-body").css("margin-top",-height);
}
function alertForm(options){
  var defaults = {
      title : "系统提示",
      url : "",
      id : "",
      btnCancelText : "取消",
      btnFnText : "确定",
      autoClose: true,
      fn : null
    },
    opt = $.extend({},defaults,options),
    html = '',
    text = '';
  if(opt.url){
    $.get(opt.url,function(result,status){
      if(status == 404){
        text = "加载失败"
      }else{
        text = result;
      }
      html = $('<div class="popup"><div class="pop-body"><div class="pop-t">'+opt.title+'</div><div class="pop-m">'+text+'</div><div class="pop-f"><div class="cell"><a href="javascript:;" data-dismiss="modal" class="btn">'+opt.btnCancelText+'</a></div><div class="cell"><a href="javascript:;" data-fn="modal" class="btn btn-yellow">'+opt.btnFnText+'</a></div></div></div></div>');
      $("body").append(html.fadeIn());
      bodyReset();
    });
  }else{
    text = "没有数据"
    html = $('<div class="popup"><div class="pop-body"><div class="pop-t">'+opt.title+'</div><div class="pop-m">'+text+'</div><div class="pop-f"><div class="cell"><a href="javascript:;" data-dismiss="modal" class="btn">'+opt.btnCancelText+'</a></div><div class="cell"><a href="javascript:;" data-fn="modal" class="btn btn-yellow">'+opt.btnFnText+'</a></div></div></div></div>');
    $("body").append(html.fadeIn());
    bodyReset();
  }
  $(document).on("click","[data-fn=modal]",function(){
    if(opt.fn){
      if(typeof opt.fn == "string"){
        window[opt.fn]();
      }else{
        opt.fn();
      }
    }
    if(opt.autoClose){
      autoHide();
    }
  });
  function autoHide(){
    $(".popup").fadeOut(function(){
      $(".popup").remove();
    });
  }
  function bodyReset(){
    var height = $(".pop-body").outerHeight();
    $(".pop-body").css("margin-top",-height/2);
  }
}

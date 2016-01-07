//= require jquery
//= require mobile/winwemedia01.js
//= require mobile/lib/iscroll
//= require mobile/lib/spin.min.js
$(".J-slide").on("click",function(){
  $(this).parent().toggleClass("active");
});
function showPop(selector){
    var h=$(window).outerHeight(),
      $body = $(selector).find(".pop-body")
    $(selector).show();
    var H=$body.height();
    $body.css({top:(h-H)/2});
    $(window).on("resize",function(){
      h=$(window).outerHeight();
      var H=$body.height();
      $body.css({top:(h-H)/2});
    });
}
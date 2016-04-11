//= require jquery
//= require jquery_ujs
//= require mobile/lib/swipe
//= require mobile/site01
//= require lib/validators
$(function(){
  $(".list").on("click","li",function(){
    if ($(this).data('answered') == 'yes'){
      return false;
    }
    var $list = $(".list"),
      $this = $(this),
      num = $list.attr("data-max") || 1;
    if(1 == num){
      $this.addClass("checked").siblings().removeClass("checked");
    }else{
      if($this.is(".checked")){
        $this.removeClass("checked");
      }else{
        var len = $list.find(".checked").length;
        if(len >=num){
          alert("最多选择"+num+"个答案");
        }else{
          $this.addClass("checked");
        }
      }
    }
  });
});
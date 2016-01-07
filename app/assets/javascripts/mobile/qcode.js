$(function(){
  $(".qcode-img").on("click",function(){
    var $this = $(this),
    $text = $this.siblings(".qcode-text");
    if(!$this.attr("style")){
      $this.animate({"height":"60px","width":"60px"},500);
      $text.text("点二维码可展开");
    }else{
      $this.animate({"height":"150px","width":"150px"},500,function(){
        $this.removeAttr("style");
        $text.text("点二维码可收起");
      });
    }
  });
  $(".qcode-text").on("click",function(){
        var $this = $(this),
            $text = $this.siblings(".qcode-img");
        if(!$text.attr("style")){
            $text.animate({"height":"60px","width":"60px"},500);
            $this.text("点二维码可展开");
        }else{
            $text.animate({"height":"150px","width":"150px"},500,function(){
                $text.removeAttr("style");
                $this.text("点二维码可收起");
            });
        }
    });

  $('a.addgetma').click(function(){
      var src = $(this).attr('data-ma');
      var str = '<a class="showgetma"><img src="'+src+'" /></a>';
      $('.html').append(str);
      $('.showgetma').click(function(){
          $(this).remove();
      });
  });
  $('span.ewm').click(function(){
      var src = $(this).attr('data-ma');
      var str = '<a class="showgetma"><img src="'+src+'" /></a>';
      $('.html').append(str);
      $('.showgetma').click(function(){
          $(this).remove();
      });
  });
});

(function() {
  jQuery(function() {
    if ($('.page').length) {
      $(window).scroll(function() {
        var url;
        url = $('.page .next').attr('href');
        if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 500) {
          $('.page').text("加载更多留言");
          $(".foot-loading").addClass("isloading").fadeIn();
          return $.getScript(url);
        }
      });
      return $(window).scroll();
    }
  });

}).call(this);

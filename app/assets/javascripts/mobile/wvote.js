//= require jquery
//= require jquery_ujs
//= require mobile/lib/iscroll
//= require lib/validators

function load(){
  $(".mod-load").addClass("loading");
  $(".mod-load a").click();
  $(".mod-load a").removeAttr('data-remote');
  $(".mod-load a").attr('href', 'javascript:;');
}

function bottomLoad(callBack){
  $(window).scroll(function(){
    var scrollTop = $(this).scrollTop();               //滚动条距离顶部的高度
    var scrollHeight = $(document).height();           //当前页面的总高度
    var windowHeight = $(this).height();               //当前可视的页面高度
    if(scrollTop + windowHeight >= scrollHeight){      //距离顶部+当前高度 >=文档总高度 即代表滑动到底部
      $(".mod-load").addClass("loading");
      callBack();
    }
  });
}

$(function(){
  $('.focus-on').on('click', function(){
    $('.focus-on').hide();
  });

  // 设置默认头部高度
  var $headerH = $("header").outerHeight();
  $(".body").css("padding-top",$headerH);

  // 显示帮助信息
  var flag = false;
  var $header = $("header"),
      $headerH = $header.height(),
      $documentH = $(window).height(),
      $tips = $(".help-tips"),
      $height = $tips.outerHeight();
    if($height > $documentH){
      $tips.height($documentH - $headerH);
      flag = true ;
    }

  $(".help").on("click",function(){
    if($header.hasClass("box-shadow")){
      $header.removeClass("box-shadow");
      $(".help-tips").animate({height:'toggle'}, "slow",function(){
        if(flag){
          isScroll('#tipsScroll');
          flag = false;
        }
      });
    }else{
      $(".help-tips").animate({height:'toggle'}, "slow",function(){
        $header.addClass("box-shadow");
      });
    }
  });
  // 单选
  $(".J-radio").on("click", "li", function(event){
    if(!$(event.target).is('img')){
      var $this = $(this);
      $this.addClass("check").siblings().removeClass("check");
    }
  });
  // 复选
  $(".J-checkbox").on("click", "li",function(event){
    if(!$(event.target).is('img')){
      var $this = $(this),
      $parent = $this.parent();
      var flag  = $this.hasClass("check");
      if(flag){
        $this.removeClass("check");
      }else if(!flag){
        $this.addClass("check");
      }
      var result = $parent.find(".check").length;
      if(result){
        //$(".J-ok").addClass("btn-violet");
      }else{
        //$(".J-ok").removeClass("btn-violet");
      }
    }
  });
  // 弹窗注册
  $(".J-ok,.J-close").on("click",function(){
    if($('#id_allow').val() == '1'){return false;}
          var user_type = parseInt($('#user_type').val()),
              wx_user_subscribe = eval($('#wx_user_subscribe').val()),
              vip_user = eval($('#vip_user').val()),
              select_count = parseInt($('#get_limit_count').val()), 
              check_count = $("li.check").length;
          if(user_type == 2 && !wx_user_subscribe){
            $('#alert_message').html("仅关注用户可参加投票");
            $('.popft').addClass('popft_focus_on')
            showPop(); 
            return false;
          }
          if(user_type == 3 && !vip_user){
            $('#alert_message').html("仅会员可参加投票");
            showPop();
            return false;
          }
          if($(this).hasClass("btn-violet")){
            if(check_count > select_count){
              $('#alert_message').html("最多可以投" + select_count + "个");
              showPop();
              return false;
            }
            if(check_count <= 0){
              $('#alert_message').html("最少必须投1个");
              showPop(); 
              return false;
            }

            // $('.foot').hide();
            // var height = $(".pop-body").outerHeight();
            // $(".pop-body").css("margin-top",-height/2);
            // $(".popup").fadeIn();
              
            if($('#id_show_user_tel').val() == 'true'){
              $('.foot').hide();
              var height = $(".pop-body").outerHeight();
              $(".pop-body").css("margin-top",-height/2);
              $(".popup").fadeIn();
            }else{
              $('.form-submit').click();
            }
          }else{
            return false;
          }
          
          // $(".html").css(bgColor:rgba(0,0,0,0.5));
        });

        // 错误弹出
        // $(".J-mod-pop").on("click",function(){
        //  $(".mod-pop").show();
        // });

        // 关闭按钮
        $(".popft").on("click", function(){
          $(".pop").hide();
          $(".block").hide();
          if($(this).hasClass('popft_focus_on')){
            $('.focus-on').show();
            $(this).removeClass('popft_focus_on');
          }
        });

        setTimeout(function(){
          autoImg(".J-img","1.3");
        },20);

        $(window).resize(function(){
          autoImg(".J-img","1.3");
        });

        $('.btn.btn-yellow').on('click', function(){
          $(".popup").fadeOut();
          $('.foot').show();
        });

        $(".body").on('click', '.loading', function(){
          //$(".black").show();
        });
        
        $("#slideup").click(function() {
            $(this).text($("#content").is(":hidden") ? "收起" :"详情" );
            $("#content").slideToggle(0);
            $("#content1").slideToggle(0);
        });
    // 加载更多
    bottomLoad(load )
});

function autoImg(el,scale){
  var $this = $(el),
    $width = $this.width(),
    $height = $width/scale;
  $this.height($height);
}

function isScroll(id){
    var scrollBox = new IScroll(id, {
        scrollbars: true,
        mouseWheel: true,
        interactiveScrollbars: true,
        shrinkScrollbars: 'scale',
        fadeScrollbars: true,
        click: true
    });
    var DOM = document.getElementById("tipsScroll");
    DOM.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
}

function addErrorMessage(element, msg){
  $(element).after('<div class="error-tips"><span class="error-icon"></span><span>'+msg+'</span></div>');
}

function showPop(){
  $(".pop").show();
  $(".block").show();  
  $(".block").css("opacity","0.8"); 
}

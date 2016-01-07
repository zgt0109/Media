(function($){
    $.fn.extend({
        // 转场方法
        transitions:function(elements,direction){
            var $this = this,
                $parent = $(elements),
                $parentH,
                dir = {left:0,top:0};
            $this.on("click",function(){
                // element 转场外层dom，direction转场方向 left,right,top,down
                var $tranH = $parent.height(),
                    $tranW = $parent.width();
                switch(direction){
                    case "left":
                        dir.left = $tranW;
                        $parentH = $(".transition-left").height();
                        break;
                    case "right":
                        dir.left = (-$tranW);
                        $parentH = $(".transition-right").height();
                        break;
                    case "top":
                        dir.top = (-$tranH);
                        $parentH = $(".transition-top").height();
                        break;
                    case "down":
                        dir.top = $tranH;
                        $parentH = $(".transition-down").height();
                        break;
                    default:
                        dir.top = 0;
                        dir.left = 0;
                        $parentH = "auto";
                        break;
                }
                // $parent.css({"-webkit-transform":"translate("+ dir.left+"px,"+ dir.top  +"px)","transition-duration":"0.8s"});
                $parent.animate({left:dir.left+"px",top:dir.top  +"px"},800);
                $parent.height($parentH);
            });
        },
        // slider
        slider:function(elements){
            var $this = this;
            $this.find("dl:eq(0)").addClass("active").find("dd").slideDown();
            this.on("click",elements,function(e){
                var $dl = $(e.target).parents("dl"),
                    $dd = $dl.find("dd"),
                    $noread = $dl.find(".noread");
                if($dd.length){
                    $dl.toggleClass("active").siblings().removeClass("active").find("dd").slideUp();
                    $dd.slideToggle("500");
                    $noread.remove();
                }
            });
        },
        // 自动宽高比例
        autoHeight:function(scale) {
            var $this = this,
                $width = $this.eq(0).width(),
                $scale = scale || 1;
            $this.height($width/$scale);
        }
    });
})(jQuery);
$(function(){
    $(".J-reg").transitions(".stage","right");
    $(".J-cancel,.J-submit").transitions(".stage");
    $(".J-psw").transitions(".stage","right");
    $(".J-submit").on("click",function(){
        $(".no-card").removeClass("no-card");
        $(".card-active").removeClass("card-active");
        scaleCard();
    });
    $(".J-slider").slider("dt");
    // 选框
    $(".select").on("click",function(){
        $(".select").removeClass("selected");
        $(this).addClass("selected");
    });
    // 倒计时
    // $(".J-getCode").on("click",function(){
    //     var $this = $(this),
    //         $time = 60;
    //     if(!$this.hasClass("btn-gray")){
    //         $this.addClass("btn-gray").text("重新获取(60)");
    //         showTime();
    //     }
    //     function showTime(){
    //         if($time ==0){
    //             $this.removeClass("btn-gray").text("获取验证码");
    //         }else{
    //             $this.text("重新获取("+$time+")");
    //             setTimeout(showTime,1000);
    //             $time--;
    //         }
    //     }
    // });
    // 弹出键盘，不显示底部导航
    $("input,textarea").on({
        focus:function(){
            $(".footbar").css("position","static");
        },
        blur:function(){
            $(".footbar").removeAttr('style');
        }
    });
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
    
    var dataIndex = window.vcardDataIndex,
        data = window.vcardData,
        cardListInfo = data.cardList,
        cardLevelStyle = data.cardLevel,
        cardNumberStyle = data.cardNumber,
        cardLogoStyle = data.cardLogo;

    function scaleCard(){
        var card = $('.vcard-card'),
            cardWidth = 534,
            cardHeight = 318,
            wp = $('.vcard-wp'),
            wpWidth = wp.width(),
            wpHeight = wpWidth/cardWidth * cardHeight;
            scale = wpWidth/cardWidth;

        card.css({ height: cardHeight, transform: 'scale(' + scale + ')' });
        wp.css({ height: wpHeight });
    }

    // 格式化会员卡
    function formatSingleCard(cardInfo){
        var card = $('.vcard-card'),
            cardLevel = $('.vcard-level', card),
            cardLogo = $('.vcard-logo', card),
            cardNumber = $('.vcard-number', card);

        card.css({'backgroundImage': 'url('+ cardInfo.cardBg +')'});
        cardLevel.html(cardInfo.level).css({ 'fontSize': cardLevelStyle.fontSize, 'left': cardLevelStyle.left, 'top': cardLevelStyle.top, 'color': cardInfo.cardLevelColor});
        cardNumber.html(cardInfo.number).css({ 'fontSize': cardNumberStyle.fontSize, 'left': cardNumberStyle.left, 'top': cardNumberStyle.top, 'color': cardInfo.cardNumberColor});
        cardLogo.css({ 'left': cardLogoStyle.left, 'top': cardLogoStyle.top}).find('img').attr('src', cardLogoStyle.src);
    }

    // 修正错乱样式
    function fixCardStyle(){
        var cardElems = $('.vcard-card .vcard-elem');

        cardElems.each(function(){
            var cardWidth = 534,
                cardHeight = 318,
                self = $(this),
                elemWidth = self.width(),
                elemHeight = self.height(),
                elemLeft = parseInt(self.css('left')),
                elemTop = parseInt(self.css('top'));

            if(elemWidth + elemLeft > cardWidth){
                self.css({'left': cardWidth-elemWidth-10});
            }

            if(elemHeight + elemTop > cardHeight){
                self.css({'top': cardHeight-elemHeight-10});
            }
        });
    }

    scaleCard();
    formatSingleCard(cardListInfo[dataIndex]);
    fixCardStyle();
});
// 成功案例
$(function(){

    var list = $('.yeah-sc5-list'),
        wp = $('.yeah-sc5-wp'),
        items = $('.yeah-sc5-item'),
        items1 = $('.yeah-sc5-type1'),
        items2 = $('.yeah-sc5-type2'),
        items3 = $('.yeah-sc5-type3'),
        wpWidth = items1.width() * items1.length + items2.width() * items2.length;

    wp.width(wpWidth)

    var x = list.offset().left;
    var y = list.offset().top;

    var wx = list.width();
    // var wy = list.height();

    var imgx = wpWidth;
    // var imgy = 540;

    var isIn = false;
    var isMove = false;

    list.on('mouseenter', function(){
        isIn = true;
    });

    list.on('mousemove', function(e){
        if(!isMove){
            if(isIn){
                isIn = false;
                isMove = true;
                wp.stop(true, false).animate({'left': -(imgx-wx)/wx * (e.pageX-x)}, 400, function(){
                    isMove = false;
                });
            }
            else{
                wp.css({'left': -(imgx-wx)/wx * (e.pageX-x)});
                // $(this).scrollTop((imgy-wy)/wy * (e.pageY-y));
            }
        }
    });

    $(window).resize(function(){
        wx = list.width();
        wp.stop(true, false).animate({'left': (wx-imgx)/2});
    }).trigger('resize');


    // 二维码
    $('.yeah-sc5-item').mouseenter(function(){
        $(this).find('.yeah-sc5-qrcode').stop(true, false).fadeIn();
    }).mouseleave(function(){
        $(this).find('.yeah-sc5-qrcode').stop(true, false).fadeOut();
    });

});


// five
$(function(){
    var sc3 = $('.yeah-sc3'),
        nav = $('.yeah-sc3-nav-item'),
        cnt = $('.yeah-sc3-item'),
        curr = 0,
        timer,
        timerSwitch;

    sc3.on('mouseenter', '.yeah-sc3-nav-item', function(){
        var self = $(this),
            index = self.index(),
            activeIndex = $('.yeah-sc3-nav-item.active').index(),
            clickItem = cnt.eq(index),
            clickItemPic = $('.yeah-sc3-item-pic', clickItem),
            clickItemTxt = $('.yeah-sc3-item-txt', clickItem),
            activeItem = cnt.eq(activeIndex),
            activeItemPic = $('.yeah-sc3-item-pic', activeItem),
            activeItemTxt = $('.yeah-sc3-item-txt', activeItem);

        if(self.hasClass('active')) return false;

        clearTimeout(timerSwitch);
        timerSwitch = setTimeout(function(){
            curr = index;
            nav.removeClass('active').eq(index).addClass('active');

            if($('html').hasClass('cssanimations')){
                clickItem.removeClass('hide').addClass('show');
                activeItem.removeClass('show').addClass('hide');
            }else{
                cnt.removeClass('showCompatibility').addClass('hideCompatibility');
                clickItem.removeClass('hideCompatibility').addClass('showCompatibility');
            }
        }, 300);
        
    })

    nav.eq(curr).trigger('mouseenter');

    $('.yeah-sc3-nav-list').on('mouseenter', function(){
        clearInterval(timer);
    }).on('mouseleave', function(){
        timer = setInterval(function(){
            var next = curr + 1;
            next = next > (nav.length-1) ? 0 : next;

            nav.eq(next).trigger('mouseenter');
        }, 2000);
    }).trigger('mouseleave');
});


// three
$(function(){

    var items = $('.yeah-sc4-item');

    items.on('mouseenter', function(){
        $('.yeah-sc4-item.magnify').removeClass('magnify').addClass('shrink');
        $(this).removeClass('shrink').addClass('magnify');
    });

    $('.yeah-sc4-list').on('mouseleave', function(){
        items.eq(1).trigger('mouseenter');
    });

    items.eq(1).trigger('mouseenter');

});
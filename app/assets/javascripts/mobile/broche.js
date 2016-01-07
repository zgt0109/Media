//= require jquery
//= require jquery_ujs


$(function(){
    var strx = 0;
    var endx = 0;
    var num = 0;
    var maxnum= $('#img .col').length;
    var turning = 'no';
    $('#img .col').eq(0).show().siblings().hide();
    var col= $('#img .col');
    var boxw = $('#img').width();
    $('#img').on('touchend',function(event){
        if(turning=="no"){
            turning='yes';
        }else{
            return false;
        }
        endx = event.originalEvent.changedTouches[0].pageX;
        if((endx-strx)<-50){
            var clo = $('#img .col').eq(num).clone();
            $('.showright .l,.showright .r').append(clo);
            num++;
            if(num>=maxnum){
                num = 0;
            }
            $('.showright').show();
            $('#img .col').eq(num).show().siblings().hide();
            $('#img .poi p').eq(num).addClass('active').siblings().removeClass('active');
            $('#img .col').eq(num).find('span.til').css({'top':60,'opacity':0});
            $('#img .col').eq(num).find('span.int').css({'opacity':0});
            $('.showright .l').animate({'margin-left':-(boxw/2)},function(){
                $('.showright .l').html('');
                $('.showright .l').css('margin-left',0);
            })
            $('.showright .r').animate({'margin-right':-(boxw/2)},function(){
                $('.showright .r').html('');
                $('.showright .r').css('margin-right',0);
                $('.showright').hide();
                $('#img .col').eq(num).find('span.til').animate({'top':20,'opacity':1},function(){
                    turning='no';
                })
                $('#img .col').eq(num).find('span.int').delay(300).animate({'opacity':1})
            })

        }else if((endx-strx)>50){
            $('.showleft .r').css('margin-right',-(boxw/2));
            $('.showleft .l').css('margin-left',-(boxw/2));
            num--;
            if(num<0){
                num = maxnum-1;
            }
            var clo = $('#img .col').eq(num).clone();
            $('.showleft .l,.showleft .r').append(clo);
            $('#img .showleft .col span,#img .showright .col span').hide();
            $('.showleft,.showleft .col').show();
            $('#img .col').eq(num).find('span').css({'top':60,'opacity':0});
            $('#img .col').eq(num).find('til').css({'opacity':0});
            $('#img .poi p').eq(num).addClass('active').siblings().removeClass('active');
            $('.showleft .l').animate({'margin-left':0},function(){
                $('.showleft .l').html('');
                $('.showleft .l').css('margin-left',-(boxw/2));
            })
            $('.showleft .r').animate({'margin-right':0},function(){
                $('.showleft .r').html('');
                $('.showleft .r').css('margin-right',-(boxw/2));
                $('#img .col').eq(num).show().siblings().hide();
                $('#img .col').eq(num).find('span.til').animate({'top':20,'opacity':1},function(){
                    turning='no';
                })
                $('#img .col').eq(num).find('span.int').delay(300).animate({'opacity':1})
                $('.showleft').hide();
            })
        }
    }).on('touchstart',function(event){
            if(turning=="yes"){
                return false;
            }
            strx = event.originalEvent.targetTouches[0].pageX;
        }).on('touchmove',function(){
            event.preventDefault();
        })
    $("$img").trigger("touchend")
});
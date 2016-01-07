/**
 * Created by pan on 14-7-7.
 */

//= require mobile/lib/jquery
//= require mobile/lib/jquery.slimscroll
//= require mobile/winwemedia01
//= require mobile/game/main
//= require lib/validators
//= require_self

var myInterval = null;
stop = 0;
$(function () {
    $('.reload').on('click', function () {
        window.location.reload();
    });
    $('[data-toggle="tab"]').click(function (e) {
        var $self = $(this);
        if (!$self.hasClass('active')) {
            $self.toggleClass('active').siblings().toggleClass('active');
            var $target = $($(this).data('target'));
            $target.show().siblings().hide();
        }
    });
    $('a.bgcover').click(function (e) {
        //$('.pop,.bgcover').hide();
    })

     $('a[data-title]').click(function(){
        var title =  $(this).attr('data-title'), inhtml = $('.getpri .showpri'), pribox = $('.getpri'), bgcover = $('a.bgcover'), acid =$(this).attr('data-id');
        $('#acid').val(acid);
        inhtml.html(title);
        pribox.show();
        bgcover.show();
    });

    var loopSpeed = 50;

    $('.shake-pause').on('click', function () {

        clearTimeout(myInterval);
    });
    $('.J-shake').on('click', function () {
        loopSpeed = 50;
        circle(true);
    });

    var yyyoff="no";

    function circle(slow) {

        if (slow) {
            loopSpeed += 10;
        }
        $('.shake-slid').animate({left: "-=120px"}, loopSpeed, function () {
            var $self = $(this);
            var offleft = $self.css('left');
            if (parseInt(offleft) <= -1138) {
                $self.css({left: 1022})
            }
        });
        myInterval = setTimeout(function(){
            circle(true)
        }, loopSpeed);
    }


    var shakebox = $('#shakebox ul');
    var shakeli =shakebox.find('li');
    var lolena = shakeli.length;
    shakebox.css('width',lolena*2*160);
    var clo = shakeli.clone();
    shakebox.append(clo);
    var maxlen = lolena*160;
    var start = 0;
    var maxlenend = 0;
    var done = -10;
    var truedone = 0;

    function getpride(num, prize){
        var inhtml = $('.getpri .showpri');
        var pribox = $('.getpri');
        var bgcover = $('a.bgcover');
        if(num==7 || num<0){
            start = 0;
            maxlenend =0;
            done = -10;
            truedone = 0;
            yyyoff="no";
        }
        switch (num){
            case 7://未中奖
                yyyoff = 'no';
                start=0;
                truedone = 0;
                done = -10;
                break;
            case -1://明天再来
                $('.tomorrow').show();
                bgcover.show();
                break;
            case -2://次数用完
                $('.nochange').show();
                bgcover.show();
                break;
            default:
               inhtml.html(prize);
               pribox.show();
               bgcover.show();
               break;
        }
    }

    function goend(){
        shakebox.animate({'left':-start},10,function(){
            if(start<maxlenend){
                start+=10;
                goend();
            }else{
                shakebox.animate({'left':'-=280px'},2000,"swing",function(){
                    getpride(truedone, prize);
                })
            }
        })
    }

    function gostart(){
        start+=10;
        if(start>maxlen){
            start = 0;
            shakebox.css('left',0);
            goend();
        }else{
            shakebox.animate({'left':-start},10,function(){
                gostart();
            })
        }
    }
    function goth(){
        start+=10;
        if(start>maxlen){
            start = 0;
        }
        shakebox.animate({'left':-start},10,function(){
            if(done>=0){
                if(done<=2){
                    maxlenend = (4+done)*160;
                }else{
                    maxlenend = (done-3)*160;
                }
                gostart();

            }else{
                goth()
            }
        })
    }

    if ('ondevicemotion' in window) {
        window.addEventListener('devicemotion', deviceMotionHandler, false);
    }
    else {
        alert("抱歉，您的终端不能摇.");
    }
    var SHAKE_THRESHOLD = 1000;
    var last_update = 0;
    var x;
    var y;
    var z;
    var last_x;
    var last_y;
    var last_z;
    var count = 0;
    var cur_count;
    var last_count;
    var circleTime1;
    var flag = 1;

    function deviceMotionHandler(eventData) {
        var acceleration = eventData.accelerationIncludingGravity;
        var curTime = new Date().getTime();
        var diffTime = curTime - last_update;
        if (diffTime > 100) {
            last_update = curTime;

            x = acceleration.x;
            y = acceleration.y;
            z = acceleration.z;

            var speed = Math.abs(x + y + z - last_x - last_y - last_z) / diffTime * 10000;
            if (speed > SHAKE_THRESHOLD) {
                count++;
                if (flag) {

                    if(activity_not_underway){
                        return false;
                    }

                    if(simulate == 'simulate'){
                        return false;
                    }
                    if(wx_user_not_exists){
                        showTips(".J-guanzhu");
                        return false;
                    }

                    if(vip_user_not_exists){
                        showTips(".J-register");
                        return false;
                    }

                    if(stop == 1 ){
                      return false;
                    }

                    stop = 1;

                    $.ajax({
                      type: "post",
                      contentType: "application/json",
                      url: check_wave_url,
                      dataType: 'json',
                      success: function (data) {
                        if(data.error_msg){
                            alert(data.error_msg);
                            return false;
                        }else{
                            stop = 0;
                            if(yyyoff=="yes"){
                                return false;
                            }
                             yyyoff = "yes";

                            $('.strimg').hide();
                            $('.shake-circle').css('opacity',1);
                            flag = 0;
                            loopSpeed = 50;
                            goth();
                            setTimeout(function() {
                              $.ajax({
                              type: "post",
                              contentType: "application/json",
                              url: get_prize_url,
                              dataType: 'json',
                              success: function (data) {
                                truedone = data.status
                                prize = data.prize
                                if (data.acid){
                                    $('#acid').val(data.acid);
                                }else{
                                    $('#acid').val('');
                                }
                                done=truedone;
                              },
                              error: function(e){
                              }
                            });
                            }, 3000)
                        }
                      }
                    })
                }
                if (circleTime1) {
                    clearTimeout(circleTime1);
                }
                circleTime1 = setTimeout(function () {
                    flag = 1;
                    clearTimeout(myInterval);
                }, 3000);
            }



            last_x = x;
            last_y = y;
            last_z = z;
        }
    }


    if ($.fn.slimScroll) {
        $('.tab-content').slimScroll({
            height: '180px',
            touchScrollStep: 50,
            alwaysVisible: true,
            railVisible: true,
            railColor: "#cba164",
            railOpacity: "1",
            opacity: "1",
            size: "4px"
        });
        $('.myprize-list').slimScroll({
            height: '220px',
            touchScrollStep: 50,
            alwaysVisible: true,
            railVisible: true,
            railColor: "#cba164",
            railOpacity: "1",
            opacity: "1",
            size: "4px"
        });
    }
});

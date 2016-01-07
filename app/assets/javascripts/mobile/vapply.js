//= require mobile/lib/jquery
//= require mobile/lib/iscroll
//= require mobile/lib/swiper
$(function () {
    $(".swiper-slide").eq(0).find(".fddown").addClass("fadeInDown").end().find(".fdup").addClass("fadeInUp");;
    // if(can_apply){
    window.mySwipe = $('#mySwipe').Swipe({
            callback: function (pos) {
                //文字设置
                if(can_apply){
                      if (pos == 0) {
                        $(".arrow-left").html("报名状态");
                        $(".arrow-right").html("立刻报名")
                     }
                      if (pos == 1) {
                            $(".arrow-left").html("活动说明")
                            $(".arrow-right").html("报名状态")
                        }
                       if (pos == 2) {
                            $(".arrow-left").html("立刻报名")
                            $(".arrow-right").html("活动说明")
                        }
                }else{
                    if (pos == 0) {
                        $(".arrow-left").html("报名状态").addClass("arr_act").removeClass('nolink');
                        $(".arrow-right").html("立刻报名").removeClass("arr_act").addClass('nolink');
                    }
                    if (pos == 3) {
                        $(".arrow-left").html("立刻报名").removeClass("arr_act").addClass('nolink');
                        $(".arrow-right").html("活动说明").addClass("arr_act").removeClass('nolink');
                    }

                }


                //高度设置
                var h1 = $(".swiper-slide").eq(pos).height();
                if (h1 < $("html").height()) {
                    $("body").height("100%")
                }
                else {
                    $("body").height(h1)
                }
                $(".apply_input").blur();

                 $(".swiper-slide").removeClass("acitve").eq(pos).addClass("acitve");

                $(".swiper-slide").eq(pos).find(".fddown").addClass("fadeInDown");
                $(".swiper-slide").eq(pos).find(".fdup").addClass("fadeInUp");
                $(".swiper-slide").eq(pos).find(".fdinx").addClass("flipInX");
                $(".pagination span").removeClass("swiper-active-switch").eq(pos).addClass("swiper-active-switch");

                clearTimeout(timer)
                var timer=setTimeout(function(){
                    $(".swiper-slide").not(".acitve").find(".fdinx").removeClass("flipInX").end().find(".fddown").removeClass("fadeInDown").end().find(".fadeInUp").removeClass("fadeInUp");

                },300)

                //
         }

    }).data('Swipe');
// }

    $('.arrow-left').on('click', function (e) {
        var apply_text = $(this).text();
        if(can_apply || apply_text !="立刻报名"){
            e.preventDefault()
            mySwipe.prev()
        }
    })
    $('.arrow-right').on('click', function (e) {
        var apply_text = $(this).text();
        if(can_apply || apply_text !="立刻报名"){
            e.preventDefault()
            mySwipe.next()
        }
    })


    if (!$("div").hasClass("noForm")){
        //form_myScroll
        var myScroll;
        myScroll = new IScroll('#scroll-wrap');
        $("#scroll-wrap").addClass("tab_h1")
    }


     //form_click
    // $(".apply_input").each(function(){
    //     var tips = $(this).attr("data-tip");
    //     $(".apply_input").focus(function(){
    //         if(this.value==this.defaultValue||this.value==tips){
    //             this.value=''
    //             $(this).removeClass("wrong").addClass("color6")
    //         }

    //     })
    //     $(".apply_input").blur(function(){
    //         if(/^\s*$/.test(this.value)){
    //             this.value=this.defaultValue;
    //             $(this).removeClass("wrong").removeClass("color6")
    //         }
    //     })
    // })

    // $("body").on("click", ".apply_btn", function () {
    //     // check()
    // })
})



// function check(){
//     $(".apply_input").each(function() {
//         var tips = $(this).attr("placeholder");
//          if(!$(this).val() || $(this).val()== tips){
//           $(this).val(tips).removeClass("color6").addClass("wrong");
//            return false;
//          }
//          //提交成功
//         return true;
//     });
// }

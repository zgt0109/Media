/*
 * =require v5.1/modernizr.custom.58376
 * =require v5.1/global
 * =require_self
 */

$(function(){
    // banner
    (function(){
        var win = $(window),
            ban = $('.fxt-ban'),
            items = $('.fxt-ban-item'),
            sizeAnimateArr = [],
            sizeAnimateStep = 16;

        // 计算运动需要的数据
        items.each(function(i){
            var self = $(this),
                img = self.find('.fxt-ban-img'),
                width = img.width(),
                height = img.height(),
                left = 0,
                bottom = parseInt(img.css('bottom'));

            sizeAnimateArr[i] = {
                before: {
                    width: width,
                    height: height,
                    left: left,
                    bottom: bottom
                },
                after: {
                    width: width + sizeAnimateStep,
                    height: height + sizeAnimateStep,
                    left: left - sizeAnimateStep/2,
                    bottom: bottom - sizeAnimateStep/2
                }
            }
        });


        // banner 光环相关方法
        function halo(circle1, circle2){
            circle2.stop(true, false).fadeIn(600);

            circle1.stop(true, false).delay(300).fadeIn(600, function(){
                circle1.stop(true, false).fadeOut(600);
                circle2.stop(true, false).delay(300).fadeOut(600);
            });
        }
        function haloCancel(circle1, circle2){
            circle1.stop(true, false).fadeOut(600);
            circle2.stop(true, false).delay(300).fadeOut(600);
        }

        // 绑定hover事件
        ban.on('mouseenter', '.fxt-ban-item', function(e){
            var self = $(this),
                img = self.find('.fxt-ban-img'),
                index = items.index(self),
                circle2 = self.find('.fxt-ban-dot2'),
                circle1 = self.find('.fxt-ban-dot1');

            img.stop(true, false).animate({
                width: sizeAnimateArr[index].after.width,
                height: sizeAnimateArr[index].after.height,
                left: sizeAnimateArr[index].after.left,
                bottom: sizeAnimateArr[index].after.bottom
            }, 200);

            clearInterval(this.timer);
            halo(circle1, circle2);
            this.timer = setInterval(function(){
                halo(circle1, circle2);
            }, 1600);

        }).on('mouseleave', '.fxt-ban-item', function(e){
            var self = $(this),
                img = self.find('.fxt-ban-img'),
                index = items.index(self),
                circle2 = self.find('.fxt-ban-dot2'),
                circle1 = self.find('.fxt-ban-dot1');

            img.stop(true, false).animate({
                width: sizeAnimateArr[index].before.width,
                height: sizeAnimateArr[index].before.height,
                left: sizeAnimateArr[index].before.left,
                bottom: sizeAnimateArr[index].before.bottom
            }, 200);

            haloCancel(circle1, circle2);
            clearInterval(this.timer);

        });

        // scroll to
        ban.on('click', '.fxt-ban-item', function(e){
            var id = '#' + $(this).data('scroll'),
                offsetTop = $(id).offset().top;

            $('html, body').animate({
                scrollTop: offsetTop - 80
            })

        })

    })();

    
    // 表单
    (function(){
        // 表单提示
        $(".m-input-text input").Ztip();

        // select联动
        address_select_fxt();

        function address_select_fxt() {
            $('.m-select').each(function() {
                var self = $(this),
                    province = self.find('.fxt_province'),
                    city = self.find('.fxt_city'),
                    district = self.find('.fxt_district');

                province.change(function() {
                    var province_id = $(this).val();
                    var get_url = "/addresses/cities?province_id=" + province_id;
                    
                    city.empty();
                    district.empty();

                    $.get(get_url, function(data) {
                        for (var i = 0; i < data.citys.length; i++) {
                            city.append("<option value='" + data.citys[i][1] + "'>" + data.citys[i][0] + "</option>");
                        }

                        city.filter('option:eq(0)').selected = true;
                        
                        // 更新模拟select UI
                        $.updateSelectSimulation(city.index(".m-select-real"));
                        city.change();
                    });
                });

                city.change(function() {

                    var city_id = $(this).val();
                    var get_url = "/addresses/districts?city_id=" + city_id;

                    district.empty();

                    $.get(get_url, function(data) {
                        for (var i = 0; i < data.districts.length; i++) {
                            district.append("<option value='" + data.districts[i][1] + "'>" + data.districts[i][0] + "</option>");
                        }

                        if (data.districts.length == 0) {
                            district.append("<option value='-1'></option>");
                        }

                        district.filter('option:eq(0)').selected = true;

                        // 更新模拟select UI
                        $.updateSelectSimulation(district.index(".m-select-real"));
                    });

                });

            });
        }

    })();


    // 视差滚动
    (function(){

        var w = $(window),
            d = $(document);

        function parallax(elem, step, eventNameSpace){
            var img = elem,
                imgHeight = img.height(),
                imgInitOffsetTop = img.offset().top,
                imgOffsetTop = imgInitOffsetTop,
                parallaxStep = step;

            w.on('resize.'+eventNameSpace, function(){
                // imgOffsetTop = imgInitOffsetTop - (w.height() - imgHeight) * 1;
                imgOffsetTop = imgInitOffsetTop - (w.height() - imgHeight) * 0.5;

                w.triggerHandler('scroll.'+eventNameSpace);
            }).triggerHandler('resize.'+eventNameSpace);

            w.on('scroll.'+eventNameSpace, function(){
                var scrollTop = w.scrollTop();
                img.css({
                    marginBottom: ( imgOffsetTop - scrollTop ) * (1 - parallaxStep)
                });
            }).triggerHandler('scroll.'+eventNameSpace);
        }

        // parallax($('.parallax1'), 0.3, 'xx1');
        // parallax($('.parallax2'), 0.3, 'xx2');
        // parallax($('.parallax3'), 0.3, 'xx3');

    })();


    // 视差滚动2
    // (function(){

    //     var w = $(window),
    //         d = $(document);

    //     function parallax(elem, step, eventNameSpace){
    //         var img = elem,
    //             imgInitOffsetTop = img.offset().top,
    //             imgHeight = img.height(),
    //             imgBoundaryUp  = imgOffsetTop = imgInitOffsetTop,
    //             imgBoundaryDown  = imgBoundaryUp + imgHeight,                
    //             parallaxStep = step;

    //         w.on('scroll.'+eventNameSpace, function(){
    //             var scrollTop = w.scrollTop();

    //             img.css({
    //                 // marginBottom: -(imgBoundaryDown - scrollTop - (w.height()+imgHeight) * 0) * parallaxStep
    //                 marginBottom: -(imgBoundaryDown - scrollTop - (w.height()+imgHeight) * 0.5) * parallaxStep
    //             });

    //         }).triggerHandler('scroll.'+eventNameSpace);
    //     }

    //     parallax($('.parallax1'), 0.3, 'xx1');
    //     parallax($('.parallax2'), 0.3, 'xx2');
    //     parallax($('.parallax3'), 0.3, 'xx3');

    // })();


    // 按钮effect
    (function(){
        $('.fxt').on('mouseenter', '.fxt-btn', function(){
            $(this).find('.fa').stop(true, false).animate({left: 4}, 180).animate({left: -2}, 200).animate({left: 0}, 100);
        });
    })();

    // 消费者 effect
    (function(){
        $('.fxt-section5-list').on('mouseenter', '.fxt-section5-item', function(){
            $(this).find('.fxt-section5-pic').stop(true, false)
                .animate({marginTop: 2}, 180)
                .animate({marginTop: -2}, 200)
                .animate({marginTop: 0}, 100);
        });
    })();


    // to top
    (function(){
        var toTop = $('#to-top'),
            isShow = false,
            topArrow = $('.to-top-arrow'),
            topTxt = $('.to-top-txt');

        $(window).scroll(function(){
            if($(window).scrollTop() < 300){
                toTop.stop(true, false).fadeOut();
            }else{
                toTop.stop(true, false).fadeIn();
            }
        });

        toTop.on('click', function(){
            $('html, body').animate({
                scrollTop: 0
            })
        }).on('mouseenter', function(){
            topArrow.stop(true, false).fadeOut();
            topTxt.stop(true, false).fadeIn();
        }).on('mouseleave', function(){
            topArrow.stop(true, false).fadeIn();
            topTxt.stop(true, false).fadeOut();
        })

    })();

});

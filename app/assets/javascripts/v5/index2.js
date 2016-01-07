$(function(){
    // index_banner
    (function(){
        var div = $(".i-ban"),
            ul = $(".i-ban-scroll"),
            li = $(".i-ban-item"),
            wid = li.outerWidth(true),
            hei = li.outerHeight(true),
            len = li.length,
            btns = $(".i-btns-item"),
            btn = $(".btn", div),
            curr = 0,
            oldCurr = 0,
            timer = null,
            slider = function(){
                if(curr == oldCurr) return false;
                var direction = curr > oldCurr ? 1 : -1;

                var item = li.eq(curr).css({display: "block", left: direction*wid});

                btns.removeClass("active").eq(curr).addClass("active");

                ul.stop(true, false).animate({left: -direction*wid}, 500, function(){
                    $(this).css({left: 0});
                    item.css({left: 0}).siblings("li").hide();
                });

                oldCurr = curr;
            },
            slideAuto = function(){
                timer = setInterval(function(){
                    curr = (++curr > len-1) ? 0 : curr;
                    slider();
                }, 5000);
            };

        $(".i-btns").on("click", ".i-btns-item", function(){
            curr = $(this).index();
            slider();
        });



        div.on("mouseleave", function(){
            slideAuto();
        }).on("mouseenter", function(){
            clearInterval(timer);
        });

        li.eq(curr).fadeIn(500);
        btns.eq(curr).addClass("active");
        if(len != 1){
            slider();
            slideAuto();
        }

    })();

    // index_notice
    (function(){
        
        var div = $(".i-notice-wrapp"),
            ul = $(".i-notice-scroll", div),
            li = $(".i-notice-item", ul),
            len = li.length,
            hei = li.outerHeight(true),
            curr = 0,
            timer = null,
            slideAuto = function(){
                timer = setInterval(function(){
                    curr = (++curr > len-1) ? 0 : curr;
                    ul.stop(true, false).animate({
                        top: -curr * hei
                    });
                }, 3000);
            };

        $(".i-notice").on("mouseleave", function(){
            slideAuto();
        }).on("mouseenter", function(){
            clearInterval(timer);
        });
        slideAuto();

    })();

    // index_cooperation
    (function(){
        var div = $(".i-coop"),
            ul = $("ul", div),
            li = $("li", ul),
            len = li.length,
            hei = li.outerHeight(true),
            grunpCellLen = 4,
            groupLen = Math.ceil(len / grunpCellLen),
            btn = $(".i-coop-arrow");

        var curr = 0,
            timer = null,
            slider = function(){
                ul.stop(true, false).animate({
                    top: -curr * hei
                });
            },
            slideAuto = function(){
                timer = setInterval(function(){
                    curr = (++curr > groupLen-1) ? 0 : curr;
                    slider();
                }, 10000);
            };

            btn.eq(0).on("click", function(){
                curr = (--curr < 0) ? groupLen-1 : curr;
                slider();
            });
            btn.eq(1).on("click", function(){
                curr = (++curr > groupLen-1) ? 0 : curr;
                slider();
            });

            div.on("mouseleave", function(){
                slideAuto();
            }).on("mouseenter", function(){
                clearInterval(timer);
            });
            slideAuto();

    })();

    // index_experience
    (function(){
        var div = $(".i-exp-btns"),
            li = $(".i-exp-btns-dot"),
            arrow = $(".i-exp-arrow"),
            divWidth = div.width(),
            liWidth = li.width(),
            liLength = li.length;

        var divBody = $(".i-exp-list"),
            ulBody = $("ul", divBody),
            liBody = $("li", ulBody),
            liBodyWidth = liBody.outerWidth(true);

        var curr = 0,
            oldCurr = -1,
            timer = null,
            slider = function(){
                if(curr == oldCurr) return false;
                var direction = curr > oldCurr ? 1 : -1;

                var item = liBody.eq(curr).css({display: "block", left: direction*liBodyWidth});

                li.removeClass("hover").eq(curr).addClass("hover");

                ulBody.stop(true, false).animate({left: -direction*liBodyWidth}, 500, function(){
                    $(this).css({left: 0});
                    item.css({left: 0}).siblings("li").hide();
                });

                oldCurr = curr;
            };
            slideAuto = function(){
                timer = setInterval(function(){
                    curr = (++curr > liLength-1) ? 0 : curr;
                    slider();
                }, 3000);
            };

        div.css({
            left: -divWidth/2
        });

        // 绑定按钮单击事件
        div.on("click", ".i-exp-btns-dot", function(){
            curr = $(this).index();
            slider();
        });

        // arrow
        arrow.eq(1).on("click", function(){
            curr = (++curr > liLength-1) ? 0 : curr;
            slider();
        });
        arrow.eq(0).on("click", function(){
            curr = (--curr < 0) ? liLength-1 : curr;
            slider();
        });

        // 定时器
        $(".i-exp-center").on("mouseenter", function(){
            clearInterval(timer);
        }).on("mouseleave", function(){
            slideAuto();
        });
        slideAuto();

        // 初始化
        slider();

    })();

    // index_o2o
    (function(){
        var item = $(".i-o2o-item");

        item.eq(0).on("mouseenter", function(){
            item.eq(1).removeClass("i-o2o-hover");

            item.eq(0).stop(true, false).animate({
                left: 90,
                top: 79
            }, function(){
                $(this).css({"z-index": 100});
            }).animate({
                left: 130,
                top: 94
            });

            item.eq(1).stop(true, false).animate({
                right: 90,
                top: 79
            }, function(){
                $(this).css({"z-index": "auto"});
            }).animate({
                right: 130,
                top: 64
            });
        }).on("mouseleave", function(){
            item.eq(1).addClass("i-o2o-hover");

            item.eq(0).stop(true, false).animate({
                left: 90,
                top: 79
            }, function(){
                $(this).css({"z-index": "auto"});
            }).animate({
                left: 130,
                top: 64
            });

            item.eq(1).stop(true, false).animate({
                right: 90,
                top: 79
            }, function(){
                $(this).css({"z-index": 100});
            }).animate({
                right: 130,
                top: 94
            });
        });
    })();

    // index_cases
    (function(){
        $(".i-cases-wrapp").on("mouseenter", ".i-cases-item", function(){
            var self = $(this);
            self.find(".i-cases-mask").stop(true, false).stop(true, false).fadeIn(400);
            self.find(".i-cases-qrcode").stop(true, false).animate({
                opacity: 1,
                top: 81
            }, 400);
            self.find(".i-cases-dsp").stop(true, false).animate({
                bottom: 0
            }, 400);
        }).on("mouseleave", ".i-cases-item", function(){
            var self = $(this);
            self.find(".i-cases-mask").stop(true, false).stop(true, false).fadeOut(400);
            self.find(".i-cases-qrcode").stop(true, false).animate({
                opacity: 1,
                top: -131
            }, 400);
            self.find(".i-cases-dsp").stop(true, false).animate({
                bottom: -70
            }, 400);
        });
    })();


});
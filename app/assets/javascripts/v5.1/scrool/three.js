// JavaScript Document
(function() {
    $(function() {
        var a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y;
        k = $(".js-title-1");
        d = $(".js-sub-title-1");
        l = $(".js-title-2");
        e = $(".js-sub-title-2");
        m = $(".js-title-3");
        f = $(".js-sub-title-3");
        n = $(".js-title-4");
        g = $(".js-sub-title-4");
        o = $(".js-title-5");
        h = $(".js-sub-title-5");
        p = $(".js-title-6");
        i = $(".js-sub-title-6");
        q = $(".js-title-7");
        j = $(".js-sub-title-7");
        k.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInUp",
                shuffle: true
            }
        });
        d.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInUp",
                shuffle: true
            }
        });
        l.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        e.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        m.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        f.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        n.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        g.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        o.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        h.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        p.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        i.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        q.textillate({
            autoStart: false,
            "in": {
                effect: "fadeInDown",
                shuffle: true
            }
        });
        j.textillate({
            autoStart: false,
            "in": {
                effect: "fadeIn",
                sync: true
            }
        });
        w = [k, l, m, n, o, p, q];
        v = [d, e, f, g, h, i, j];
        u = [false, false, false, false, false, false, false];

        t = window.location.hash.slice(1);
        if (t !== "") {
            for (s = y = 0; y <= 6; s = ++y) {
                if (parseInt(t) === s + 1 && !u[s]) {
                    w[s].textillate("in");
                    v[s].textillate("in");
                    u[s] = true
                }
            }
        } else {
            w[0].textillate("in");
            v[0].textillate("in");
            u[0] = true
        }
        if (!Modernizr.touch) {
            $(".containers-wrap").onepage_scroll({
                sectionContainer: "section.container",
                easing: "ease",
                animationTime: 1e3,
                pagination: true,
                updateURL: true,
                responsiveFallback: false,
                beforeMove: function(a) {
                    if (parseInt(a) <= 1) {
                        $(".onepage-pagination").removeClass("onepage-pagination_white")
                    } else {
                        $(".onepage-pagination").addClass("onepage-pagination_white")
                    }
                    if (parseInt(a) === 6 && $(".js-chat").hasClass("open")) {
                        $(".js-chat").removeClass("open");
                        $(".containers-wrap").moveTo(7)
                    }
                    if (parseInt(a) === 7) {
                        return $(".js-logo").addClass("logo_gray")
                    } else {
                        return $(".js-logo").removeClass("logo_gray")
                    }
                },
                afterMove: function(a) {
                    var b, c;
                    c = [];
                    for (s = b = 0; b <= 6; s = ++b) {
                        if (parseInt(a) === s + 1 && !u[s]) {
                            w[s].textillate("in");
                            v[s].textillate("in");
                            c.push(u[s] = true)
                        } else {
                            c.push(void 0)
                        }
                    }
                    return c
                },
                loop: false,
                keyboard: true,
                direction: "vertical",
                end: function(index){
                    if(index != 1){
                        var sec = $(".containers-wrap .active"),
                            flag = sec.length;
                        if(flag){
                            sec.removeClass("active");
                            $(".containers-wrap").parent().animate({"margin-top":"-260px"},1000);
                        }else{
                            $(".containers-wrap>section").last().addClass("active");
                            $(".containers-wrap").parent().animate({"margin-top":"0"},1000);
                        }
                    }
                }
            })
        }

    })
}).call(this);
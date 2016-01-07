/**
 * Created by pan on 14-5-20.
 */
;
(function (e) {
    e.scroll = function (t) {
        var n = {
            scrollName: "scrollTop",
            speed: 200,
            topDistance: 50,
            animation: "fade",
            animationInSpeed: 100,
            animationOutSpeed: 100,
            text: "",
            img: true
        };
        var r = e.extend({}, n, t),
            i = "#" + r.scrollName;
        e("<a/>", {
            id: r.scrollName,
            href: "#top",
            title: r.text
        }).appendTo("body");
        if (!r.img) {
            e(i).text(r.text);
        }
        e(i).css({display: "none", position: "fixed", "z-index": "2147483647"});
        e(window).scroll(function () {
            switch (r.animation) {
                case "fade":
                    e(e(window).scrollTop() > r.topDistance ? e(i).fadeIn(r.animationInSpeed) : e(i).fadeOut(r.animationOutSpeed));
                    break;
                case "slide":
                    e(e(window).scrollTop() > r.topDistance ? e(i).slideDown(r.animationInSpeed) : e(i).slideUp(r.animationOutSpeed));
                    break;
                default :
                    e(e(window).scrollTop > r.topDistance ? e(i).show(0) : e(i).hide(0))
            }
        });
        e(i).click(function (t) {
            e("html,body").animate({
                scrollTop: 0
            }, r.speed);
            t.preventDefault()
        });
    }
})(jQuery);
jQuery.scroll();
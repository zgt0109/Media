//= require jquery
//= require mobile/lib/iscroll
//= require_self

$(function () {
    $("body").on("click", ".scrollUp", function () {
        screenScroll("up");
    }).on("click", ".scrollDown", function () {
            screenScroll("down");
        });
});
function screenScroll(direction) {
    var $docmentH = $(document).height(),
        $stage = $("#stage"),
        $children = $stage.children("section"),
        $first = $children.eq(0),
        $center = $children.eq(1),
        $last = $children.eq(2),
        $len = $children.length;
    if ($len > 2) {
        if (direction == "down") {
            $stage.css({"-webkit-transform": "translate(0," + (-$docmentH) + "px)", "transition-duration": "0.8s"});
            $(".list-input").blur();
            setTimeout(function () {
                $first.attr("class", "transition-bottom").appendTo($stage);
                $center.attr("class", "transition-top");
                $last.removeAttr("class");
                $stage.css({"-webkit-transform": "translate(0,0)", "transition-duration": "0s"});
            }, 800);
        } else if (direction == "up") {
            $stage.css({"-webkit-transform": "translate(0," + $docmentH + "px)", "transition-duration": "0.8s"});
            $(".list-input").blur();
            setTimeout(function () {
                $first.removeAttr("class");
                $center.attr("class", "transition-bottom");
                $last.attr("class", "transition-top");
                $first.before($last);
                $stage.css({"-webkit-transform": "translate(0,0)", "transition-duration": "0s"});
            }, 800);
        }
    } else {
        if (direction == "down") {
            $(".list-input").blur();
            $stage.css({"-webkit-transform": "translate(0," + (-$docmentH) + "px)", "transition-duration": "0.8s"});
            setTimeout(function () {
                $first.attr("class", "transition-top");
                $center.removeClass();
                $stage.css({"-webkit-transform": "translate(0,0)", "transition-duration": "0s"});
            }, 800);
        } else if (direction == "up") {
            $(".list-input").blur();
            $stage.css({"-webkit-transform": "translate(0," + $docmentH + "px)", "transition-duration": "0.8s"});
            setTimeout(function () {
                $first.removeClass();
                $center.attr("class", "transition-bottom");
                $stage.css({"-webkit-transform": "translate(0,0)", "transition-duration": "0s"});
            }, 800);
        }
    }
}
function list(id) {
    var scrollList = new IScroll(id, {
        scrollbars: true,
        mouseWheel: true,
        interactiveScrollbars: true,
        shrinkScrollbars: 'scale',
        fadeScrollbars: true,
        click: true
    });
}
function setColor(o) {
    $(".html").css({background: o.background||"#D4DCF1"});
    $(".body,.time,.scroll i").css({color: o.color||"#283070"});
    $(".list-box .btn-reg").css({background: o.color||"#283070"})
}

document.addEventListener('touchmove', function (e) {
    e.preventDefault();
}, false);
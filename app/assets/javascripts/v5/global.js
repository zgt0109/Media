// slimScroll
(function(f){jQuery.fn.extend({slimScroll:function(g){var a=f.extend({width:"auto",height:"250px",size:"4px",color:"#000",position:"right",distance:"1px",start:"top",opacity:0.4,alwaysVisible:!1,disableFadeOut:!1,railVisible:!1,railColor:"#333",railOpacity:0.2,railDraggable:!0,railClass:"slimScrollRail",barClass:"slimScrollBar",wrapperClass:"slimScrollDiv",allowPageScroll:!1,wheelStep:20,touchScrollStep:200,borderRadius:"7px",railBorderRadius:"7px"},g);this.each(function(){function u(d){if(r){d=d||
window.event;var c=0;d.wheelDelta&&(c=-d.wheelDelta/120);d.detail&&(c=d.detail/3);f(d.target||d.srcTarget||d.srcElement).closest("."+a.wrapperClass).is(b.parent())&&m(c,!0);d.preventDefault&&!k&&d.preventDefault();k||(d.returnValue=!1)}}function m(d,f,g){k=!1;var e=d,h=b.outerHeight()-c.outerHeight();f&&(e=parseInt(c.css("top"))+d*parseInt(a.wheelStep)/100*c.outerHeight(),e=Math.min(Math.max(e,0),h),e=0<d?Math.ceil(e):Math.floor(e),c.css({top:e+"px"}));l=parseInt(c.css("top"))/(b.outerHeight()-c.outerHeight());
e=l*(b[0].scrollHeight-b.outerHeight());g&&(e=d,d=e/b[0].scrollHeight*b.outerHeight(),d=Math.min(Math.max(d,0),h),c.css({top:d+"px"}));b.scrollTop(e);b.trigger("slimscrolling",~~e);v();p()}function C(){window.addEventListener?(this.addEventListener("DOMMouseScroll",u,!1),this.addEventListener("mousewheel",u,!1)):document.attachEvent("onmousewheel",u)}function w(){s=Math.max(b.outerHeight()/b[0].scrollHeight*b.outerHeight(),D);c.css({height:s+"px"});var a=s==b.outerHeight()?"none":"block";c.css({display:a})}
function v(){w();clearTimeout(A);l==~~l?(k=a.allowPageScroll,B!=l&&b.trigger("slimscroll",0==~~l?"top":"bottom")):k=!1;B=l;s>=b.outerHeight()?k=!0:(c.stop(!0,!0).fadeIn("fast"),a.railVisible&&h.stop(!0,!0).fadeIn("fast"))}function p(){a.alwaysVisible||(A=setTimeout(function(){a.disableFadeOut&&r||x||y||(c.fadeOut("slow"),h.fadeOut("slow"))},1E3))}var r,x,y,A,z,s,l,B,D=30,k=!1,b=f(this);if(b.parent().hasClass(a.wrapperClass)){var n=b.scrollTop(),c=b.parent().find("."+a.barClass),h=b.parent().find("."+
a.railClass);w();if(f.isPlainObject(g)){if("height"in g&&"auto"==g.height){b.parent().css("height","auto");b.css("height","auto");var q=b.parent().parent().height();b.parent().css("height",q);b.css("height",q)}if("scrollTo"in g)n=parseInt(a.scrollTo);else if("scrollBy"in g)n+=parseInt(a.scrollBy);else if("destroy"in g){c.remove();h.remove();b.unwrap();return}m(n,!1,!0)}}else{a.height="auto"==g.height?b.parent().height():g.height;n=f("<div></div>").addClass(a.wrapperClass).css({position:"relative",
overflow:"hidden",width:a.width,height:a.height});b.css({overflow:"hidden",width:a.width,height:a.height});var h=f("<div></div>").addClass(a.railClass).css({width:a.size,height:"100%",position:"absolute",top:0,display:a.alwaysVisible&&a.railVisible?"block":"none","border-radius":a.railBorderRadius,background:a.railColor,opacity:a.railOpacity,zIndex:90}),c=f("<div></div>").addClass(a.barClass).css({background:a.color,width:a.size,position:"absolute",top:0,opacity:a.opacity,display:a.alwaysVisible?
"block":"none","border-radius":a.borderRadius,BorderRadius:a.borderRadius,MozBorderRadius:a.borderRadius,WebkitBorderRadius:a.borderRadius,zIndex:99}),q="right"==a.position?{right:a.distance}:{left:a.distance};h.css(q);c.css(q);b.wrap(n);b.parent().append(c);b.parent().append(h);a.railDraggable&&c.bind("mousedown",function(a){var b=f(document);y=!0;t=parseFloat(c.css("top"));pageY=a.pageY;b.bind("mousemove.slimscroll",function(a){currTop=t+a.pageY-pageY;c.css("top",currTop);m(0,c.position().top,!1)});
b.bind("mouseup.slimscroll",function(a){y=!1;p();b.unbind(".slimscroll")});return!1}).bind("selectstart.slimscroll",function(a){a.stopPropagation();a.preventDefault();return!1});h.hover(function(){v()},function(){p()});c.hover(function(){x=!0},function(){x=!1});b.hover(function(){r=!0;v();p()},function(){r=!1;p()});b.bind("touchstart",function(a,b){a.originalEvent.touches.length&&(z=a.originalEvent.touches[0].pageY)});b.bind("touchmove",function(b){k||b.originalEvent.preventDefault();b.originalEvent.touches.length&&
(m((z-b.originalEvent.touches[0].pageY)/a.touchScrollStep,!0),z=b.originalEvent.touches[0].pageY)});w();"bottom"===a.start?(c.css({top:b.outerHeight()-c.outerHeight()}),m(0,!0)):"top"!==a.start&&(m(f(a.start).position().top,null,!0),a.alwaysVisible||c.hide());C()}});return this}});jQuery.fn.extend({slimscroll:jQuery.fn.slimScroll})})(jQuery);

// jquery.mousewheel
!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):"object"==typeof exports?module.exports=a:a(jQuery)}(function(a){function b(b){var g=b||window.event,h=i.call(arguments,1),j=0,l=0,m=0,n=0,o=0,p=0;if(b=a.event.fix(g),b.type="mousewheel","detail"in g&&(m=-1*g.detail),"wheelDelta"in g&&(m=g.wheelDelta),"wheelDeltaY"in g&&(m=g.wheelDeltaY),"wheelDeltaX"in g&&(l=-1*g.wheelDeltaX),"axis"in g&&g.axis===g.HORIZONTAL_AXIS&&(l=-1*m,m=0),j=0===m?l:m,"deltaY"in g&&(m=-1*g.deltaY,j=m),"deltaX"in g&&(l=g.deltaX,0===m&&(j=-1*l)),0!==m||0!==l){if(1===g.deltaMode){var q=a.data(this,"mousewheel-line-height");j*=q,m*=q,l*=q}else if(2===g.deltaMode){var r=a.data(this,"mousewheel-page-height");j*=r,m*=r,l*=r}if(n=Math.max(Math.abs(m),Math.abs(l)),(!f||f>n)&&(f=n,d(g,n)&&(f/=40)),d(g,n)&&(j/=40,l/=40,m/=40),j=Math[j>=1?"floor":"ceil"](j/f),l=Math[l>=1?"floor":"ceil"](l/f),m=Math[m>=1?"floor":"ceil"](m/f),k.settings.normalizeOffset&&this.getBoundingClientRect){var s=this.getBoundingClientRect();o=b.clientX-s.left,p=b.clientY-s.top}return b.deltaX=l,b.deltaY=m,b.deltaFactor=f,b.offsetX=o,b.offsetY=p,b.deltaMode=0,h.unshift(b,j,l,m),e&&clearTimeout(e),e=setTimeout(c,200),(a.event.dispatch||a.event.handle).apply(this,h)}}function c(){f=null}function d(a,b){return k.settings.adjustOldDeltas&&"mousewheel"===a.type&&b%120===0}var e,f,g=["wheel","mousewheel","DOMMouseScroll","MozMousePixelScroll"],h="onwheel"in document||document.documentMode>=9?["wheel"]:["mousewheel","DomMouseScroll","MozMousePixelScroll"],i=Array.prototype.slice;if(a.event.fixHooks)for(var j=g.length;j;)a.event.fixHooks[g[--j]]=a.event.mouseHooks;var k=a.event.special.mousewheel={version:"3.1.12",setup:function(){if(this.addEventListener)for(var c=h.length;c;)this.addEventListener(h[--c],b,!1);else this.onmousewheel=b;a.data(this,"mousewheel-line-height",k.getLineHeight(this)),a.data(this,"mousewheel-page-height",k.getPageHeight(this))},teardown:function(){if(this.removeEventListener)for(var c=h.length;c;)this.removeEventListener(h[--c],b,!1);else this.onmousewheel=null;a.removeData(this,"mousewheel-line-height"),a.removeData(this,"mousewheel-page-height")},getLineHeight:function(b){var c=a(b),d=c["offsetParent"in a.fn?"offsetParent":"parent"]();return d.length||(d=a("body")),parseInt(d.css("fontSize"),10)||parseInt(c.css("fontSize"),10)||16},getPageHeight:function(b){return a(b).height()},settings:{adjustOldDeltas:!0,normalizeOffset:!0}};a.fn.extend({mousewheel:function(a){return a?this.bind("mousewheel",a):this.trigger("mousewheel")},unmousewheel:function(a){return this.unbind("mousewheel",a)}})});

// render template
function renderTpl(callback){
    var tpls = $(".tpl");
    var tplsLength = tpls.length;
    var tplsCount = 0;

    tpls.each(function(){
        var self = $(this);
        $.ajax({
            url: self.data("src"),
            type: "GET",
            dataType: "text",
            async: false    // fix: 同步加载模块
        }).done(function(data){
            tplsCount++;
            self.replaceWith(data);
            if(tplsCount == tplsLength){
                // dosomething
                callback && callback()
            }
        });
    });
}


$(function(){
    // render template
    renderTpl();

    //son menu
    (function(){
        var li = $(".header nav li");
        li.each(function(){
            var self = $(this);
            var son = self.find(".nav-son");

            if(son.length){
                var item = son.find(".nav-item");
                var width = item.outerWidth(true);
                var len = item.length;
                var selfWidth = self.width();
                var sonWidth = width * len;

                self.on("mouseenter", function(){
                    son.show().stop(true, false).animate({
                        top: 56,
                        opacity: 1
                    });
                }).on("mouseleave", function(){
                    son.stop(true, false).animate({
                        top: 76,
                        opacity: 0
                    }, function(){
                        son.hide();
                    });
                });
            }
        });
    })();

    // set son menu flexible
    (function(){
        var isScrollDown = false;
        var header = $(".header");
        var logoDiv = $("h1", header);
        var logoImg = $("img", header);
        var nav = $("nav", header);
        var navSon = $(".nav-son", nav);
        var link = $(".header-link", header);
        var linkA = $("a", link);

        $(document).on("mousewheel", function(e, delta){
            if(delta < 0){
                // down
                if(!isScrollDown){
                    isScrollDown = true;
                    // header
                    header.stop(true, false).animate({
                        height: 40
                    });
                    // logo
                    logoDiv.stop(true, false).animate({
                        top: 10
                    });
                    logoImg.stop(true, false).animate({
                        height: 22
                    });
                    // nav
                    nav.stop(true, false).animate({
                        top: 2
                    });
                    // nav son
                    navSon.css({
                        "margin-top": -18
                    });
                    // header-link-a
                    linkA.css({
                        "line-height": "28px"
                    });
                    // header-link
                    link.stop(true, false).animate({
                        top: 6
                    });
                    
                }
            }else{
                // up
                if(isScrollDown){
                    isScrollDown = false;
                    // header
                    header.stop(true, false).animate({
                        height: 80
                    });
                    // logo
                    logoDiv.stop(true, false).animate({
                        top: 18
                    });
                    logoImg.stop(true, false).animate({
                        height: 47
                    });
                    // nav
                    nav.stop(true, false).animate({
                        top: 24
                    });
                    // nav son
                    navSon.css({
                        "margin-top": 0
                    });
                    // header-link-a
                    linkA.css({
                        "line-height": "35px"
                    });
                    // header-link
                    link.stop(true, false).animate({
                        top: 24
                    });
                    
                }
            }
        });
    })();

    // slideBar
    (function(){
        var timeAnimate,
            $sliderBar = $(".toolsbar");
        var $animation = function(time){
                timeAnimate = setTimeout(function(){
                    $sliderBar.animate({"right":"-141px"},500);
                },time);
            }
        $animation(3000);
        $sliderBar.on({
            "mouseenter":function(){
                clearTimeout(timeAnimate);
                $sliderBar.stop().animate({"right":"0"},500);
            },
            "mouseleave":function(){
                $animation(1000);
            }
        });
    })();

});


;(function(){
    $.dialog = function(options){
        var defaults = {
            htmlString: "",
            callback:  null,
            closeCallback: null
        };
        var o = $.extend(defaults, options);
        var html = '<div class="dialog">\
                        <div class="dialog-bg"></div>\
                        <div class="dialog-layer">\
                            <div class="dialog-layer-cnt"></div>\
                            <div class="dialog-layer-close"></div>\
                        </div>\
                    </div>';
        var dialog = $(html);
        var dialogClose, dialogBg, dialogBox;
        var hide = function(){
            dialogBox.slideUp(400);
            dialogBg.fadeOut(400, function(){
                dialog.remove();
            });
        };
        var show = function(){
            dialogBox.hide().slideDown(400);
            dialogBg.hide().fadeIn(400);
        };

        dialog.appendTo("body");
        dialogClose = dialog.find(".dialog-layer-close");
        dialogBg = dialog.find(".dialog-bg");
        dialogBox = dialog.find(".dialog-layer");

        dialogClose.click(function(){
            hide();
        })

        show();
        $.isFunction(o.callback) && o.callback();
    };

    $.alert = function(options){
        var defaults = {
            titString: "",
            htmlString: "",
            callback:  null,
            closeCallback: null
        };
        var o = $.extend(defaults, options);
        var html = '<div class="alert">\
                        <div class="alert-bg"></div>\
                        <div class="alert-layer">\
                            <div class="alert-layer-tit">{{tit}}</div>\
                            <div class="alert-layer-cnt">{{content}}</div>\
                            <div class="alert-layer-close"></div>\
                        </div>\
                    </div>';
        var alert = $(html.replace('{{content}}', o.htmlString).replace('{{tit}}', o.titString));
        var alertClose, alertBg, alertBox;
        var hide = function(){
            alertBox.slideUp(400);
            alertBg.fadeOut(400, function(){
                alert.remove();
            });
        };
        var show = function(){
            alertBox.hide().slideDown(400);
            alertBg.hide().fadeIn(400);
        };

        alert.appendTo("body");

        alertClose = alert.find(".alert-layer-close");
        alertBg = alert.find(".alert-bg");
        alertBox = alert.find(".alert-layer");

        alertBox.css({
            marginTop: -alertBox.height() / 2
        })

        alertClose.click(function(){
            hide();
            $.isFunction(o.closeCallback) && o.closeCallback();
        })

        show();
        $.isFunction(o.callback) && o.callback();
    };
})();
$(function(){
	sendCode();
	modPop(dd);
	goTop();
	categoryFilter();
	indexSwipe("banner",false,0);
	autoHeight(".banner",400/720);
	addNum();
	slide();
	selectAttr();
	share();
	vcScroll("#order-title");
	vcScroll("#order-titles");
});
function sendCode(){
	$(document).on("click",".ver-btn .input",function(){
		var $this = $(this),
			flag = $this.is(".disabled"),
			time = 60;
		if(!flag){
			setTime();
		}
		function setTime(){
			var msg = "秒后重发";
			$this.addClass("disabled").val(time+msg);
			if(time > 0){
				setTimeout(setTime,1000);
				time--;
			}else{
				$this.val("获取验证码").removeClass("disabled");
			}
		}
	});
}
function modPop(fn){
	$(document).on("click","[data-rel=popover]",function(){
		var $this = $("[data-rel=popover]"),
			$type = $this.data("type") || "string",
			$html = $this.data("value"),
			$btn = $this.data("btn").split(","),
			$btnNum = $btn.length,
			html = $('<div class="mod-pop"><div class="mod-body"></div></div>'),
			body = $(html).find(".mod-body"),
			text = $('<div class="mod-text"></div>'),
			btn = '<div class="mod-btn">',
			winHeight = $(window).height(),
			modHeight;
		if($type == "html"){
			$(text).html($html);
		}else{
			$(text).text($html);
		}
		if($btnNum == 1){
			btn += '<div class="mod-cell cancel">'+$btn[0]+'</div>';
		}else{
			btn += '<div class="mod-cell cancel">'+$btn[0]+'</div><div class="mod-cell ok">'+$btn[1]+'</div>';
		}
		btn+='</div>'
		body.append(text,$(btn));
		$("body").append(html);
		$(html).fadeIn();
		modHeight = body.height();
		body.css("top",(winHeight - modHeight)/2)
	});
	$(document).on("click",".cancel",function(){
		$(".mod-pop").fadeOut(function(){
			$(this).remove();
		});
	});
	$(document).on("click",".ok",function(){
		$(".mod-pop").fadeOut(function(){
			$(this).remove();
			fn();
		});
	});
}
function slide(){
	$("[data-toggle]").on("click",function(){
		var $this =$(this),
			$cont = $this.next(".p-cont");
		$this.parent().toggleClass("active");
		$cont.slideToggle();
	});
}
function goTop(){
	$(".gotop").on("click",function(){
		$("body").animate({scrollTop:0},500);
	});
}
function categoryFilter(){
	var $select = $(".select-head a"),
		$selBox = $(".mod-pop"),
		$main = $selBox.find(".mod-select");
	$select.on("click",function(){
		var $this = $(this);
		if(!$this.is(".active")){
			$this.addClass("active");
			$selBox.fadeIn();
			$main.slideDown();
		}else{
			$this.removeClass("active");
			$main.slideUp(function(){
				$selBox.fadeOut();
			});
		}
	});
	$main.on("click","a",function(){
		var $this = $(this),
			$val = $this.text();
		$this.addClass("active").siblings().removeClass("active");
		$select.removeClass("active").find("span").text($val);
		$main.slideUp(function(){
			$selBox.fadeOut();
		});
	});
	$selBox.on("click",function(e){
		if(!$(e.target).is(".mod-select,.mod-select *")){
			$select.removeClass("active");
			$main.slideUp(function(){
				$selBox.fadeOut();
			});
       }
	});
}
//幻灯片
function indexSwipe(id,nav,time){
    if(nav){
        setSlide("#"+id);
    }
    var mySwipe = new Swipe(document.getElementById(id),{
        speed:500,
        auto:time || false,
        callback: function(){
            var lis = this.index;
            $("#"+id+" .sub-slide a").removeClass("active").eq(lis).addClass("active");
        }
    });
    var prev = $("#"+id).siblings(".slide-prev"),
        next = $("#"+id).siblings(".slide-next");
    prev.on("click",function(){
        mySwipe.prev();
    });
    next.on("click",function(){
        mySwipe.next();
    });
}
function setSlide(elements){
    var lis = $(elements),
        len = lis.children().children("li").length,
        box= '<div class="sub-slide">',
        li = '<a href="javascript:;"></a>';
    for(var i = 0;i<len;i++){
        if(i==0){
            box += '<a href="javascript:;" class="active"></a>'
        }else{
            box += li;
        }
    }
    box +='</div>';
    lis.append(box);
}
function autoHeight(el,scale){
    var $docW = $(el).width(),
        $elH = parseInt($docW*scale),
        $img = $(el).find(".menu-img");
    $(el).height($elH).css({"line-height":$elH+"px"});
}
function addNum(){
    $(".add-num").on("click",".sub",function(){
        var $this = $(this).parent();
            $text = $this.find(".text span"),
            $val = parseInt($text.text()),
            $add = $this.find(".add");
        if($val > 0){
            $add.removeClass("disabled");
            $val = ($val-1).toString();
            $text.text($val);
        }
        if($val == 0){
            $(this).addClass("disabled");
        }
    });
    $(".add-num").on("click",".add",function(){
        var $this = $(this).parent();
            $text = $this.find(".text span"),
            $val = parseInt($text.text()),
            $maxNum = $text.attr("data-max"),
            $sub = $this.find(".sub");
        if($val<$maxNum){
            $val = ($val+1).toString();
            $text.text($val);
            $sub.removeClass("disabled");
        }
        if($val ==$maxNum){
            $(this).addClass("disabled");
        }
    });
}
function selectAttr(){
	$(document).on("click",".product-tags a",function(){
		var $this = $(this);
		$this.addClass("active").siblings().removeClass("active");
	});
}
function share(){
	var $cont = $(".share-box");
	$(document).on("click",".J-share",function(){
		$cont.slideDown();
	});
	$(document).on("click",".J-share-cancel,.share-main a",function(){
		$cont.slideUp();
	});
}
function vcScroll (id) {
    var myScroll = new IScroll(id, {
        scrollX: true,
        scrollY: false,
        mouseWheel: true,
        scrollbars: false,
        mouseWheel: true,
        interactiveScrollbars: true,
        shrinkScrollbars: 'scale',
        fadeScrollbars: true,
        click: true
    });
    var dom = $(id).get(0);
    dom.addEventListener('touchmove',function(e){e.preventDefault();},false);
}
function dd(){
	alert("fn")
}
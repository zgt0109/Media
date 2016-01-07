window.addEventListener("DOMContentLoaded", function(){
	btn = document.getElementById("plug-btn");
	btn.onclick = function(){
		var divs = document.getElementById("plug-phone").querySelectorAll("div");
		var className = className=this.checked?"on":"";
		for(i = 0;i<divs.length; i++){
			divs[i].className = className;
		}
	}
}, false);
$(function(){
    $("a, .btn").on({
        touchstart:function(){
            $(this).addClass("active");
        },
        touchend:function(){
             $(this).removeClass("active");
        },
        touchmove:function(){
        }
    });
	//点击加载更多
	$(".loading").on("click",function(){
		$(this).html("加载中...").addClass("isloading");
	});
	//显示更多
	$(".btn-show").on("click",function(){
		var self=$(this),
			p=self.parent(".fr").find("p.hide");
		if(self.hasClass("show")){
			self.html("显示更多").removeClass("show");
			p.hide();
		}else{
			self.html("隐藏").addClass("show");
		p.show();
		}
	});
    //新
    $(".btn-list").click(function(){
        var h=$(".html").height();
//        var sh=window.screen.availHeight-$(".pop-list .hd").height()*3;
//        $(".pop-list .pop-bd").height(h);
//        //$(".pop-list .bd").height(sh);
//        $(".pop-list .bd").height("30%");
        //$(".pop-list .pop-bd").height(h);
        $(".pop-list").height(h).fadeIn();
    });
	//分类
	$(".ico-list").on("click",function(){
        var h=$(document).height();
        $(".pop-nav").height(h);
		$(".pop-nav").show();
		$(".pop-nav .pop-bd").addClass("on");
	});
	$(".pop-nav .hd, .pop-nav .pop-bg").on("click",function(){
		$(".pop-nav").hide();
	});
	$(".pop-nav .pop-bd dt").on("click",function(){
		var self=$(this),
				parent=self.parents(".bd"),
				dt=parent.find("dt");
		if(self.hasClass("active")){
			dt.removeClass("active");
			parent.find("dl").removeClass("active");
			dt.find(".ico").removeClass("ico-angle-down").addClass("ico-angle-right");
		}else{
			parent.find("dl").removeClass("active");
			dt.removeClass("active");
			dt.find(".ico").removeClass("ico-angle-down").addClass("ico-angle-right");
			self.find(".ico").removeClass("ico-angle-right").addClass("ico-angle-down");
			self.parent("dl").andSelf().addClass("active");
		}	
	});
	$(".pop-nav dd a").on("click",function(){
		var self=$(this),
			dd=self.parent("dd");
		dd.find("a").removeClass("active");
		self.addClass("active");
		$(".pop-nav").fadeOut();
	});
    //新分类
    $(".pop-list .hd").click(function(){
        $(".pop-list").fadeOut();
    });
    $(".pop-list dt").click(function(){
        var self=$(this),
            dl=self.parents("dl");
        if(dl.hasClass("active")){
           $(".pop-list dl").removeClass("active"); 
        }else{
            $(".pop-list dl").removeClass("active");
            dl.addClass("active");
        }
        
    });
	//欢迎页面
	setTimeout(function(){
		$("#pageShow").animate({
			"left": "-=50px",
			opacity:0.9
		}, "slow").animate({
			"left": "+=50px",
			opacity:0.9
		}, "slow").animate({
			"left": "-=30px",
			opacity:0.8
		}, "slow").animate({
			"left": "+=30px",
			opacity:0.8
		}, "slow").animate({
			"left": "-=100%",
			opacity:0
		}, "slow");
	},2000);

    //发送给朋友 & 分享到朋友圈
    $(".btn-share").on("click",function(){
        var h=$(document).height();
        $(".pop-share").height(h);
        $(".pop-bg").height(h);
		$(".pop-share").show();
	});
	$(".pop-share").on("click",function(){
		$(".pop-share").hide();
	});
    //关闭弹出层
    $(".btn-close, .pop-bg").click(function(){
        var self=$(this),
            pop=self.parents(".pop");
        pop.fadeOut();
    });
    //btn-up
    document.addEventListener("touchstart",function(e){
        var t=e.touches[0],
            y=t.pageY;
        $("body").attr("data-y",y);
    });
    document.addEventListener("touchmove",function(e){
        var t=e.touches[0],
            startY=parseInt($("body").attr("data-y")),
            pageY=t.pageY;
        if(startY>=300){
            $(".btn-up").fadeIn();
        }else{
            $(".btn-up").fadeOut();
        }
    });
    document.addEventListener("touchend",function(e){
        //var t=e.touches[0];
        //console.log(t);
    });
});
//点击展开
function openFold(self, selector){
	var parent=self.parent();
	selector=parent.find(selector);
	if(parent.hasClass("active")){
		parent.removeClass("active");
		selector.slideUp()
	}else{
		parent.prevAll().removeClass("active");
		parent.nextAll().removeClass("active");
		parent.addClass("active");
		selector.slideDown()
	}
}
//通用提示框
function popResult(type,string,current,prev){
    var result=$("#pop-result"),
        span=result.find("span");
    if(type==0){
        result.addClass("result-success");
    }else{
        result.addClass("result-fail");
    }
    span.html(string);
    result.show();
    setTimeout(function(){
        result.fadeOut(function(){
            if(current!=""&&prev!=""){
                current.animate({
                    top:"-200%"
                },"fast",function(){
                    prev.fadeIn();
                });
            }else if(prev!=""){
                prev.fadeIn();
            }
        });
    },3000);
}
//弹出菜单1
function navPop1(idName,input){
    window.addEventListener("DOMContentLoaded", function(){
//        btn = document.getElementById(input);
        var btn= (input == '#navLine-navPop') ? $(input).find("b").find("i"): $(input).children();
        var divs=$(idName).find("div");
        btn.click(function(){
            divs.toggleClass("on");
        });
        divs.click(function(){
            $(input).toggleClass("active");
            divs.toggleClass("on");
        });
//        btn.onclick = function(){
////            var divs = document.getElementById(idName).querySelectorAll("div");
////            var className = className=this.checked?"on":"";
////            for(i = 0;i<divs.length; i++){
////                divs[i].className = className;
////            }
//        }
    }, false);
}
//点击给制定的selector添加制定的class
function toggleToClass(selector,className){
    $(selector).toggleClass(className);
}
//btn-up
function showBtnUp(h){
    window.addEventListener("scroll",function(e){
        var t = document.documentElement.scrollTop || document.body.scrollTop;
        if(t>=h){
            $(".btn-up").fadeIn();
        }else{
            $(".btn-up").fadeOut();
        }
    });
}
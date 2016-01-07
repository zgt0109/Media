window.addEventListener("DOMContentLoaded", function(){
	btn = document.getElementById("plug-btn");
	if(btn){
		btn.onclick = function(){
			var divs = document.getElementById("plug-phone").querySelectorAll("div");
			var className = className=this.checked?"on":"";
			for(i = 0;i<divs.length; i++){
				divs[i].className = className;
			}
		}
	}
}, false);
$(function(){
	$("a").on("click", function(){
		$(this).addClass("active");
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
	//分类
	$(".ico-list").on("click",function(){
        var h=$(document).height();
        $(".pop-nav").height(h);
        $(".pop-bg").height(h);
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
	//欢迎页面
	setTimeout(function(){
		/*$("#pageShow").animate({
			opacity:"toggle",
			//top:"-100%",
			top:"-100%out",
			height: "linear"
		},"linear");*/
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
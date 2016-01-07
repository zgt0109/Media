$(function(){
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
	$(".ico-list").on("click",function(){
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
			self.parent("dl").andSelf().removeClass("active");
			self.find(".ico").removeClass("icon-angle-down").addClass("icon-angle-right");
		}else{
			parent.find("dl").removeClass("active");
			dt.removeClass("active");
			dt.find(".ico").removeClass("icon-angle-down").addClass("icon-angle-right");
			self.find(".ico").removeClass("icon-angle-right").addClass("icon-angle-down");
			self.parent("dl").andSelf().addClass("active");
		}
		
	});
	$(".pop-nav dd a").on("click",function(){
		var self=$(this),
			dd=self.parent("dd");
		dd.find("a").removeClass("active");
		self.addClass("active");
		$(".pop-nav").hide();
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

});

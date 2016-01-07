	$(function(){
	fixIndexNavScroll(".nav");
	fixIndexNav(".nav");
	var bodyH=document.body.scrollHeight,
		screenH=document.body.clientHeight,
		mainH=0;
	if(bodyH<=screenH){
		mainH=screenH-148;
		$(".contxt").css("height",mainH);
	}
	var timer=setInterval(function(){
		showFlash("next");
	},8000);
	$(".flashpage a").click(function(){
		var self=$(this),
			next=parseInt(self.attr("id").replace("flashpage",""));
		showFlash(next);
	});
	resizeForLogin();
	$(window).resize(function(){
		resizeForLogin();
	});
  $(".nav a").click(function(){
    $(".nav a").removeClass("current");
    $(this).addClass("current");
    var href=$(this).attr("href"),
		url=href.replace("#","");
		pageScroll(url);
		//window.location.href=href;
  });
  var url=window.location.hash.replace("#",".");
  if(url&&url!=""){
    $(".nav a").removeClass("current");
    $(url).addClass("current");
    pageScroll(url);
  }else{
    $(".nav a").removeClass("current");
    $(".index-website").addClass("current");
    window.scrollTo(0,0);
  }
});
function resizeForLogin(){
	var width=$(window).width(),
		left=$(".box-cont").offset().left;
	if(left<150){
		$(".box-login").addClass("login-small");
	}else{
		$(".box-login").removeClass("login-small");
	}
}

function fixIndexNavScroll(selector){
	$(document).scroll(function(){
		fixIndexNav(selector);
	});
}

function fixIndexNav(selector){
	var scrollH=$(document).scrollTop();
	if(scrollH>370){
		$(selector).addClass("fixed-top");
	}else{
		$(selector).removeClass("fixed-top");
	}
}
function showFlash(next){
	var currentDiv=$(".flash-li.current"),
		currentPage=$(".flashpage a.current"),
		current=parseInt(currentDiv.attr("id").replace("flash",""));
	
	if(next=="next"){next=(current+1)%4;}
	
	currentTop=(current%2-1)*312;
	currentLeft=(current%2)*960;
	if(current==1){
		currentLeft=currentLeft*(-1);
	}
	if(current==2){
		currentTop=currentTop*(-1);
	}
	currentDiv.animate({
		top:currentTop,
		left:currentLeft,
	},"slow","swing",function(){
		
	});
	
	currentDiv.removeClass("current");
	currentPage.removeClass("current");
	$("#flashpage"+next).addClass("current");
	$("#flash"+next).animate({
		top:0,
		left:0,
	},"fast","swing",function(){
		$("#flash"+next).addClass("current");
	});
}

function pageScroll(url){
	url=url.replace(".","");
	var height=$(document).height();
		switch(url)
		{
			case "index-website":
				window.scrollTo(0,355);
				break;
			case "index-member":
				window.scrollTo(0,600);
				break;
			case "index-mark":
				window.scrollTo(0,878);
				break;
			case "index-bussiness":
				window.scrollTo(0,1156);
				break;
			case "index-trade":
				window.scrollTo(0,1434);
				break;
			case "index-custom":
				window.scrollTo(0,1715);
				break;
			case "index-weibo":
				window.scrollTo(0,1990);
				break;
		}
}
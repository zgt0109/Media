$blank = /^(|\s+)$/; //空格
$regEmail = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w{2,3})*$/; //邮箱格式


$(function(){
	$(".btn").on(function(){
		$(this).addClass("active");
	});
	$(".page a").on("touchstart",function(){
		$(".page a").removeClass("current");
		$(this).addClass("current");
	});
	//点击加载更多
	$(".loading").on("click",function(){
		$(this).html("加载中...").addClass("isloading");
	});
	
});


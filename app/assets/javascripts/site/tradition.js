function tradition(jgtime,ydtime,imgwidth){
	var nowimg = 0;	
	$(".main-box .main-ul li").eq(0).clone().appendTo(".main-box .main-ul");

	// ******定时器********
	var timer = setInterval(mythings,jgtime);

	$(".main-box").mouseenter(
		function(){
			clearInterval(timer);
		}
	);

	$(".main-box").mouseleave(
		function(){
			clearInterval(timer);
			timer = setInterval(mythings,jgtime);
		}
	);
	//******定时器*******

	function mythings(){
		if(!$(".main-ul").is(":animated")){
			if(nowimg < $(".main-box .main-ul li").length - 2){
				nowimg = nowimg + 1;
				moveTo();	
			}else{
				nowimg = 0;
				$(".main-box .main-ul").animate(
					{
						"left":-imgwidth * ($(".main-box .main-ul li").length - 1),
					}
					,ydtime
					,function(){
						$(".main-box .main-ul").css("left","0");
					}
				);
				$(".circle-grounp .circle-ul li").eq(nowimg).addClass("cur").siblings().removeClass("cur");
			}
		}
	}
	
	$(".circle-grounp .circle-ul li").click(
		function(){
			if(!$(".main-ul").is(":animated")){
				nowimg = $(this).index();
				moveTo();
			}
		}
	);

	function moveTo(){
		
		$(".main-box .main-ul").animate(
			{
				"left":nowimg * -imgwidth
			}
		,ydtime);

		$(".circle-grounp .circle-ul li").eq(nowimg).addClass("cur").siblings().removeClass("cur");
	}
}
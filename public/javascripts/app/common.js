$blank = /^(|\s+)$/; //空格
$regEmail = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w{2,3})*$/; //邮箱格式


$(function(){
	$(".input-operate").on("touchstart",function(){
		$(this).addClass("active");
		
	});
	$(".input-operate").on("touchend",function(){
		$(this).removeClass("active");
		
	});
	$("#input-minus").on("click",function(){
		var self=$(this),
			minus=parseInt(self.attr("data-min")),
			input=$("#input-number"),
			value=parseInt(input.val());
		if(value&&value!==""&&value>minus){
			input.val(value-1);
		}else{
			input.val(minus);
			self.addClass("disable");
		}
		$("#input-add").removeClass("disable");
	});
	$("#input-add").on("click",function(){
		var self=$(this),
			max=parseInt(self.attr("data-max")),
			input=$("#input-number"),
			value=parseInt(input.val());
		if(value&&value!==""&&value<max){
			input.val(value+1);
		}else{
			input.val(max);
			self.addClass("disable");
		}
		$("#input-minus").removeClass("disable");
	});
	$("#input-number").on("keyup",function(){
		var self=$(this),
			max=parseInt(self.attr("data-max")),
			minus=parseInt(self.attr("data-min")),
			value=parseInt(self.val());
			self.val(self.val().replace(/\D/g, ''));
		if(value>max){
			self.val(max);
		}else if(value<minus){
			self.val(minus);
		}
	});
	$("#btn-order").on("click",function(){
		$("#pop-order").show();
	});
	$(".pop .btn").on("click",function(){
		$(".pop").hide();
	});
});


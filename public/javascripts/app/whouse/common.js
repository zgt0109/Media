$blank = /^(|\s+)$/; //空格
$regEmail = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w{2,3})*$/; //邮箱格式
$is_error = false;

$(function(){
	//点击查看所有户型
	$(".more").on("click",function(){
		var self=$(this),
		target=self.attr("id");
		$("."+target).find(".box-more").toggleClass("hide");

	});
	//提交评论
	$("#btn-comment").on("click",function(){
		if(validate_fields()){
			post_comment();
		}
	});

	$('#house_comment_name').on("focus",function(){
		if($('#house_comment_name').hasClass('error')){
			$('#house_comment_name').val('');
			$('#house_comment_name').removeClass('error');
			$is_error = false;
		}
	});
	$('#house_comment_mobile').on("focus",function(){
		if($('#house_comment_mobile').hasClass('error')){
			$('#house_comment_mobile').val('');
			$('#house_comment_mobile').removeClass('error');
			$is_error = false;
		}
	});
	$('#house_comment_content').on("focus",function(){
		if($('#house_comment_content').hasClass('error')){
			$('#house_comment_content').val('');
			$('#house_comment_content').removeClass('error');
			$is_error = false;
		}
	});

	//flashshow
	if($("#defaultFlash").length > 0){
		setInterval(function(){
			var flashArr=$(".flashCont a"),
			length=flashArr.length;
			var current=parseInt($("#defaultFlash .current").attr("id").replace("defaultflash","")),
			currentDiv=$("#defaultflash"+current),
			next=(current+1)%length,
			nextDiv=$("#defaultflash"+next);
			currentDiv.animate({
				left:"-100%"
			},"fast","ease-in",function(){
				currentDiv.removeClass("current");
				currentDiv.removeAttr("style");
			});
			nextDiv.animate({
				left:"0"
			},"fast","ease-in-out",function(){
				nextDiv.addClass("current");
			});
		},3000);
	}

	//相册
	$("body").hammer().on("swipeleft",".flashCont a",function(e){
		var flashArr=$(".flashCont a"),
		length=flashArr.length;
		var current=parseInt($("#flashshow .current").attr("id").replace("flashshow","")),
		currentDiv=$("#flashshow"+current),
		next=(current+1)%length,
		nextDiv=$("#flashshow"+next);
		currentDiv.animate({
			left:"-100%"
		},"fast","ease-in",function(){
			currentDiv.removeClass("current");
			currentDiv.removeAttr("style");
		});
		nextDiv.animate({
			left:"0"
		},"fast","ease-in-out",function(){
			nextDiv.addClass("current");
		});
	});
	$("body").hammer().on("swiperight",".flashCont a",function(e){
		var flashArr=$(".flashCont a"),
		length=flashArr.length;
		$(".flashCont a").css("left","-100%");
		$(".flashCont a.current").css("left","0");
		var current=parseInt($("#flashshow .current").attr("id").replace("flashshow","")),
		currentDiv=$("#flashshow"+current),
		next=current-1;
		if(next<0){
			next=next+length;
		}
		var nextDiv=$("#flashshow"+next);
		currentDiv.animate({
			left:"100%"
		},"fast","ease-in",function(){
			currentDiv.removeClass("current");
			currentDiv.removeAttr("style");
		});
		nextDiv.animate({
			left:"0"
		},"fast","ease-in-out",function(){
			nextDiv.addClass("current");
		});
	});

});

function validate_fields(){
	var _name = $('#house_comment_name').val(), _mobile = $('#house_comment_mobile').val(), _content = $('#house_comment_content').val();
	if($is_error){
		return false
	}else if(!(_name && _name.replace($blank, ''))){
		$is_error = true;
		$('#house_comment_name').val('请输入姓名');
		$('#house_comment_name').addClass('error');
		return false
	}else if(_name.length == 1){
		$is_error = true;
		$('#house_comment_name').val('姓名太短');
		$('#house_comment_name').addClass('error');
		return false;
	}else if(!(_mobile && _mobile.replace($blank, ''))){
		$is_error = true;
		$('#house_comment_mobile').val('请输入手机号码');
		$('#house_comment_mobile').addClass('error');
		return false;
	}else if(!(/^1[3|4|5|8][0-9]\d{8}$/.test(_mobile))){
		$is_error = true;
		$('#house_comment_mobile').val('手机号码格式不正确');
		$('#house_comment_mobile').addClass('error');
		return false;
	}else if(!(_content && _content.replace($blank, ''))){
		$is_error = true;
		$('#house_comment_content').val('请输入回复内容');
		$('#house_comment_content').addClass('error');
		return false
	}/*else if(_content.length <= 1){
		$is_error = true;
		$('#house_comment_content').val('回复内容太短');
		$('#house_comment_content').addClass('error');
		return false;
	}*/else {
		if(!$is_error)return true;
	}
	return false
}
var time,
	speed = 1050,
	enabled = true,
	rotateRun;
var temp = 0;
function rotate(el,num){
	var $this = $(el),
		num = num*50;
	$this.addClass("cur").siblings().removeClass("cur");
	$this = $this.next("li").length>0 ? $this.next("li") : $this.parent().find("li:eq(0)");
	if(time <= 0){
		if(speed<1000){
			speed = speed*1.25;
			run(speed);
		}
		else{
			enabled = true;
			$("#goT").mouseup();
			$("#user-list ul li:eq(1)").addClass("cur");
			$(".btn-start").removeClass("btn-rotation");
			clearTimeout(rotateRun);
		}
	}else{
		if(speed > 50){
			temp += speed;
			speed =speed*0.75;
		}else{
			time -= speed;
			speed = 50;
		}
		run(speed);
	}
	function run(speed){
		rotateRun = setTimeout(function(){
			rotate($this);
		},speed);
	}
}
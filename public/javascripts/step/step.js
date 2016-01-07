$(function(){
	var bodyH=document.body.scrollHeight,
		screenH=document.body.clientHeight,
		mainH=0;
	if(bodyH<=screenH){
		mainH=screenH-46;
		$(".body").css("height",mainH);
	}
	
});
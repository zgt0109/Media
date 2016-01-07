$(function(){
	$(".J-toggle").on("click",function(){
		var $this = $(this),
			$ul = $this.parent().next();
		$this.toggleClass("close");
		if($this.hasClass("close")){
			$ul.animate({"height":"246px"},1000);
		}else{
			$ul.animate({"height":"738px"},1000);
		}
	})
});
$(function(){
	var offsetH3 = $(".section3").offset().top-$(".header").height()-150;
	$(window).scroll(function() {
		if(  $(document).scrollTop() > offsetH3 ){
			$('.section3').addClass('animate_start');
		}else{
			$('.section3').removeClass('animate_start');
		}
	});

	var offsetH4 = $(".section4").offset().top-$(".header").height()-150;
	$(window).scroll(function() {
		if(  $(document).scrollTop() > offsetH4 ){
			$('.section4').addClass('animate_start');
		}else{
			$('.section4').removeClass('animate_start');
		}
	});
});
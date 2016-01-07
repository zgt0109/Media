 $(function(){


        initLottery()




	function initLottery(){
        initSwipe();




	}

	function initSwipe(){
		var isInitSwipe = $('#swipe li').length > 1;
		if(isInitSwipe){

			$('#swipe').swipe({
				cur: config.swipeCur,
				dir: config.swipeDir,
				success: function(){



					// $('.f-hide').removeClass('f-hide');
				}
			});
		}else{
			$('#swipe li').eq(0).fadeIn()
		}
	}


	
	
	
});
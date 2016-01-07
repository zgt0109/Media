$( function () {

	$('#edit_fight_paper_validate').click(function(event){
		for(var i = 0; i<selectedValues.length; i++){
			if(selectedValues[i].contains('')){
				showTip('warning','必须设置所有题目才能保存.')
				event.preventDefault();
				return false;
			}
		}
	});

	$('.save-question').click(function(event){
		var selects = $(this).parents('form').find('select');
		var select_vals = $.map(selects, function(item, index) {
			return $(item).val();
		});
		if($(this).closest('li').prev().find('#fight_paper_read_time').val() == ""){
			event.preventDefault();
			showTip('warning','请先设置前一天题目');
		}else if ( select_vals.indexOf('') > -1 ) {
			event.preventDefault();
			showTip('warning','必须设置所有题目才能保存');
		} else {
			$.each(select_vals, function(index, val) {
				if ( select_vals.indexOf(val) != index ) {
					event.preventDefault();
					showTip('warning','题目不能重复');
				};
			});
		}
	});

	$('.answer_b').change(function(event){
		if($(this).val() && $(this).val().replace(/^\s*$/, '')){
			$('.answer_c').attr('disabled',false);
			if($('.answer_c').val() && $('.answer_c').val().replace(/^\s*$/, '')){
				$('.answer_d').attr('disabled',false);
				if($(".correct_answer option[value='C']").length == 0)$(".correct_answer").append("<option value='C'>C</option>");
				if($('.answer_d').val() && $('.answer_d').val().replace(/^\s*$/, '')){
					$('.answer_e').attr('disabled',false);
					if($(".correct_answer option[value='D']").length == 0)$(".correct_answer").append("<option value='D'>D</option>");
					if($('.answer_e').val() && $('.answer_e').val().replace(/^\s*$/, '')){
						if($(".correct_answer option[value='E']").length == 0)$(".correct_answer").append("<option value='E'>E</option>");
					}
				}
			}
		}else{
			$('.answer_c').attr('disabled',true);
			$('.answer_d').attr('disabled',true);
			$('.answer_e').attr('disabled',true);
			$(".correct_answer option[value='C']").remove();
			$(".correct_answer option[value='D']").remove();
			$(".correct_answer option[value='E']").remove();
		}
	});

	$('.answer_c').change(function(event){
		if($(this).val() && $(this).val().replace(/^\s*$/, '')){
			$('.answer_d').attr('disabled',false);
			if($(".correct_answer option[value='C']").length == 0 )$(".correct_answer").append("<option value='C'>C</option>");
			if($('.answer_d').val() && $('.answer_d').val().replace(/^\s*$/, '')){
				$('.answer_e').attr('disabled',false);
				if($(".correct_answer option[value='D']").length == 0 )$(".correct_answer").append("<option value='D'>D</option>");
				if($('.answer_e').val() && $('.answer_e').val().replace(/^\s*$/, '')){
					if($(".correct_answer option[value='E']").length == 0 )$(".correct_answer").append("<option value='E'>E</option>");
				}
			}
		}else{
			$('.answer_d').attr('disabled',true);
			$('.answer_e').attr('disabled',true);
			$(".correct_answer option[value='C']").remove();
			$(".correct_answer option[value='D']").remove();
			$(".correct_answer option[value='E']").remove();
		}
	});

	$('.answer_d').change(function(event){
		if($(this).val() && $(this).val().replace(/^\s*$/, '')){
			$('.answer_e').attr('disabled',false);
			if($(".correct_answer option[value='D']").length == 0 )$(".correct_answer").append("<option value='D'>D</option>");
			if($('.answer_e').val() && $('.answer_e').val().replace(/^\s*$/, '')){
				if($(".correct_answer option[value='E']").length == 0 )$(".correct_answer").append("<option value='E'>E</option>");
			}
		}else{
			$('.answer_e').attr('disabled',true);
			$(".correct_answer option[value='D']").remove();
			$(".correct_answer option[value='E']").remove();
		}
	});

	$('.answer_e').change(function(event){
		if($(this).val() && $(this).val().replace(/^\s*$/, '')){
			if($(".correct_answer option[value='E']").length == 0 )$(".correct_answer").append("<option value='E'>E</option>");
		}else{
			$(".correct_answer option[value='E']").remove();
		}
	});

});

function initSelectOption(){
	if($('.answer_b').val() && $('.answer_b').val().replace(/^\s*$/, '')){
		$('.answer_c').attr('disabled',false);
		if($('.answer_c').val() && $('.answer_c').val().replace(/^\s*$/, '')){
			$('.answer_c').attr('disabled',false);
			$('.answer_d').attr('disabled',false);
			if($('.answer_d').val() && $('.answer_d').val().replace(/^\s*$/, '')){
				$('.answer_d').attr('disabled',false);
				$('.answer_e').attr('disabled',false);
				if($('.answer_e').val() && $('.answer_e').val().replace(/^\s*$/, '')){
					//$('.answer_e').attr('disabled',false);
				}else{
					$(".correct_answer option[value='E']").remove();
				}
			}else{
				$(".correct_answer option[value='D']").remove();
				$(".correct_answer option[value='E']").remove();
			}
		}else {
			$(".correct_answer option[value='C']").remove();
			$(".correct_answer option[value='D']").remove();
			$(".correct_answer option[value='E']").remove();
		}
	}else{
		$(".correct_answer option[value='C']").remove();
		$(".correct_answer option[value='D']").remove();
		$(".correct_answer option[value='E']").remove();
	}
}

Array.prototype.contains = function(opt){
	var i = this.length;
	while(i--){
		if(this[i] === opt){
			return true
		}
	}
	return false
}

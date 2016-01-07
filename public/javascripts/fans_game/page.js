function load_page_1() {
	$("#c1").css("display", "block");
	$("#c2").css("display", "block");
	$("#c2").addClass("imgElementClick");
	$("#c3").css("display", "block");
	$("#c4").css("display", "block")
}

function load_page_2() {
	$("#c1").css("display", "block");
	$("#c2").css("display", "none");
	$("#c3").css("display", "none");
	$("#c4").css("display", "none");
	$("#c29").css("display", "block");
	$("#c29").addClass("imgElementClick");
	$("#c18").addClass("imgElementClick");
	$("#c19").addClass("imgElementClick");
	$("#c30").css("display", "block");
	$("#c21").css("display", "block");
	$("#c25").css("display", "block");
	$("#c13").css("display", "block");
	$("#c14").css("display", "block");
	$("#c14_").css("display", "block");
	$("#c16").css("display", "block");
	$("#c17").css("display", "block");
	$("#c5").css("display", "block");
	$("#c6").css("display", "block")
}
var baozi_max = 50;
var eat_max_time = 15;
var first_eat = true;
var finish_eat = false;
var eat_count = 0;
var anim_count = 0;
var animArr_1 = ["#c28", "#c26", "#c27", "#c26", "#c27"];
var animArr_2 = ["#c34", "#c31", "#c32", "#c33", "#c35"];
var animArr_3 = ["#c35m", "#c34m", "#c31m", "#c32m", "#c33m"];

function tmpFn() {
	if (anim_count > 4) {
		anim_count = 0
	}
	if (anim_count == 2 || anim_count == 4) {
		eat_count++;
		$("#c14_").html("x " + eat_count)
	}
	if (eat_count > baozi_max * 0.33 && eat_count < baozi_max * 0.66) {
		$("#c6").css("display", "none");
		$("#c7").css("display", "block")
	} else {
		if (eat_count > baozi_max * 0.66) {
			$("#c7").css("display", "none");
			$("#c8").css("display", "block")
		}
	}
	animArr_1.forEach(function(a) {
		$(a).css("display", "none")
	});
	$(animArr_1[anim_count]).css("display", "block");
	animArr_2.forEach(function(a) {
		$(a).css("display", "none")
	});
	$(animArr_2[anim_count]).css("display", "block");
	animArr_3.forEach(function(a) {
		$(a).css("display", "none")
	});
	$(animArr_3[anim_count]).css("display", "block");
	anim_count++
}


var chat = "";
$(document).on("click touchstart", "#c2", function(a) {
	a.preventDefault();
	a.stopPropagation();
	load_page_2()
});
$(document).on("click touchstart", "#c29", function(a) {
	a.preventDefault();
	a.stopPropagation();
	if (first_eat == true) {
		$("#c17").animate({
			width: 0
		}, eat_max_time * 1000, winORlose);
		first_eat = false
	}
	$("#c25").css("display", "none");
	tmpFn()
});
$(document).on("click touchstart", "#c19", function(a) {
	a.preventDefault();
	a.stopPropagation();
	$("#container").html("");
	window.location.reload();
});

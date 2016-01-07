//= require jquery
//= require jquery_ujs

// JavaScript Document
  $(function(){
    $(".close").click(function(){
		  $(".index-descript").slideToggle();
		  $(".index-details").slideDown("slow");
		})
    $(".index-footer").click(function(){
		  $(".index-details").slideToggle();
		  $(".index-descript").slideDown("slow");
		})
  })
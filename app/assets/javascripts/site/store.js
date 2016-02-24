$(function(){  
    // full page
    (function(){
        var footHeight = $(".footer-wrapp").outerHeight(true);
        scrollPage({
            sections: ".page",
            nav: ".page-nav",
            navCurrClass: "rolling-cur",
            btnSelector: ".next-page",
            getTarget: function(nowPage, winHeight){
                return  (nowPage == 5) ? (-(nowPage-1) * winHeight - footHeight) : (-nowPage * winHeight);
            }
        });
    })();   
});
window.onload = function(){
    function size(){
      var ele = document.getElementById("container"),
          height = document.documentElement.clientHeight,

          fontsize = height / 9.4;
      ele.style.fontSize = fontsize + "px";
    }
    size();
    window.onresize = function(){
      size();
    }
}

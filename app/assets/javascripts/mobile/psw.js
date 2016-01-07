var vcPsw = function(){
    $(".password-box .psw").on({
        "keydown":function(e){
            var $this = $(this),
                $len = $this.val().length,
                $ul = $this.prev("ul"),
                e = e || event;
            if($len>=6 &&e.keyCode != 8){
                return false;
            }
            $ul.find("li").text("");
            $ul.find("li:lt("+$len+")").text("•");
        },
        "keyup":function(){
            var $this = $(this),
                $len = $this.val().length,
                $ul = $this.prev("ul"),
                $btn = $this.next(".J-psw");
            $ul.find("li").text("");
            $ul.find("li:lt("+$len+")").text("•");
            if($len>=6 && $btn.length){
                $this.blur();
                $btn.trigger("click");
            }
        }
    });
};
$(function(){
    vcPsw();
});

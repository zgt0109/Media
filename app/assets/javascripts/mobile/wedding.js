//= require jquery
//= require jquery_ujs
//= require mobile/winwemediaV01
//= require mobile/lib/swipe
//= require lib/validators

$("#guest_submit").click(function(){
    if($("#wedding_guest_username").val() == ''){
        alert("姓名不能为空!");
        $("#wedding_guest_username").focus();
        return false;
    }else if($("#wedding_guest_people_count").val() == ''){
        alert("人数不能为空！");
        $("#wedding_guest_people_count").focus();
        return false;
    }else if( !validate_people_count($("#wedding_guest_people_count").val()) ){
        alert("人数只能是正数字！");
        $("#wedding_guest_people_count").focus();
        return false;
    }else{
        $("guest_form").submit();
    }

})

function validate_people_count(count){
    if (count == undefined) {
        return false;
    }
    var count_reg = /^[0-9]*$/;
    if (count_reg.test(count)){
        return true;
    };
    return false;

}

// 手机号码正则表达式
function test_mobile_number(mobile_number) {
    if (mobile_number == undefined) {
        return false;
    }
    var mobile_reg = /^\d{11}$/;
    if (mobile_reg.test(mobile_number)){
        return true;
    };
    return false;
}

var playbox = (function(){
    var _playbox = function(){
        var that = this;
        that.box = null;
        that.player = null;
        that.src = null;
        that.on = false;
        //
        that.autoPlayFix = {
            on: true,
            evtName: ("ontouchstart" in window)?"touchend":"click"
        }

    }
    _playbox.prototype = {
        init: function(box_ele){
            this.box = "string" === typeof(box_ele)?document.getElementById(box_ele):box_ele;
            this.player = this.box.querySelectorAll("audio")[0];
            this.src = this.player.src;
            this.init = function(){return this;}
            this.autoPlayEvt(true);
            return this;
        },
        play: function(){
            if(this.autoPlayFix.on){
                this.autoPlayFix.on = false;
                this.autoPlayEvt(false);
            }
            this.on = !this.on;
            if(true == this.on){
                this.player.src = this.src;
                this.player.play();
            }else{
                this.player.pause();
                this.player.src = null;
            }
            if("function" == typeof(this.play_fn)){
                this.play_fn.call(this);
            }
        },
        handleEvent: function(evt){
            this.play();
        },
        autoPlayEvt: function(important){
            if(important || this.autoPlayFix.on){
                document.body.addEventListener(this.autoPlayFix.evtName, this, false);
            }else{
                document.body.removeEventListener(this.autoPlayFix.evtName, this, false);
            }
        }
    }
    //
    return new _playbox();
})();

playbox.play_fn = function(){
    $("#playbox").toggleClass('close');

}



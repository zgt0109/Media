//= require jquery
//= require plugins
//= require vendor/modernizr-2.6.2.min
//= require_self



//倒计时
function countDown(secs,fn){
    for (var i = secs; i >= 0; i--) {
        (function(index) {
            setTimeout(function(){
                if(fn){
                    fn(index);
                }
            }, (secs - index) * 1000);
        })(i);
    };
}

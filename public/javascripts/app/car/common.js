$(function(){

});
//点击表单后
function focusForm(header,footer,fn1,fn2){
    $("input[type!=radio],input[type!=checkbox]").focus(function(){
        if(header&&header!=""){
            $(header).css({"position":"absolute"});
        }
        if(footer&&footer!=""){
            $(footer).css({"position":"absolute"});
        }
        if(fn1){
            fn1()
        }
    });
    $("input[type!=radio],input[type!=checkbox]").focusout(function(){
        if(header&&header!=""){
            $(header).css({"position":"fixed"});
        }
        if(footer&&footer!=""){
            $(footer).css({"position":"fixed"});
        }
        if(fn2){
            fn2();
        }
    });
}
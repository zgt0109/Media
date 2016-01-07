//辅助函数
function Trim(str,is_global)
{
    var result;
    result = str.replace(/(^\s+)|(\s+$)/g,"");
    if(is_global.toLowerCase()=="g") result = result.replace(/\s/g,"");
    return result;
}
function clearBr(key)
{
    key = Trim(key,"g");
    key = key.replace(/<\/?.+?>/g,"");
    key = key.replace(/[\r\n]/g, "");
    return key;
}

//获取随机数
function getANumber()
{
    var date = new Date();
    var times1970 = date.getTime();
    var times = date.getDate() + "" + date.getHours() + "" + date.getMinutes() + "" + date.getSeconds();
    var encrypt = times * times1970;
    if(arguments.length == 1){
        return arguments[0] + encrypt;
    }else{
        return encrypt;
    }
    
}
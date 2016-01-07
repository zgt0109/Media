/*
*名称:图片上传本地预览插件 v1.1
*作者:周祥
*时间:2013年11月26日
*介绍:基于JQUERY扩展,图片上传预览插件 目前兼容浏览器(IE 谷歌 火狐) 不支持safari
*插件网站:http://jquery.decadework.com 
*作者QQ：200592114
*参数说明: Img:图片ID;Width:预览宽度;Height:预览高度;ImgType:支持文件类型;Callback:选择文件显示图片后回调方法;
*使用方法: 
<div>
<img id="ImgPr" width="120" height="120" /></div>
<input type="file" id="up" />
把需要进行预览的IMG标签外 套一个DIV 然后给上传控件ID给予uploadPreview事件
$("#up").uploadPreview({ Img: "ImgPr", Width: 120, Height: 120, ImgType: ["gif", "jpeg", "jpg", "bmp", "png"], Callback: function () { }});
*/
eval(function (p, a, c, k, e, r) { e = function (c) { return (c < 62 ? '' : e(parseInt(c / 62))) + ((c = c % 62) > 35 ? String.fromCharCode(c + 29) : c.toString(36)) }; if ('0'.replace(0, e) == 0) { while (c--) r[e(c)] = k[c]; k = [function (e) { return r[e] || e } ]; e = function () { return '[1-9a-df-hj-zA-F]' }; c = 1 }; while (c--) if (k[c]) p = p.replace(new RegExp('\\b' + e(c) + '\\b', 'g'), k[c]); return p } ('o.fn.p({uploadPreview:9(1){7 5=2,q=$(2);1=o.p({a:"ImgPr",r:s,t:s,h:["gif","jpeg","jpg","bmp","png"],u:9(){}},1||{});5.j=9(b){7 8=null;3(4.c!=k){8=4.c(b)}d 3(4.v!=k){8=4.v.c(b)}d 3(4.w!=k){8=4.w.c(b)}x 8};q.change(9(){3(2.l){3(!RegExp("\\.("+1.h.y("|")+")$","i").test(2.l.toLowerCase())){alert("选择文件错误,图片类型必须是"+1.h.y("，")+"中的一种");2.l="";x false}3($.browser.msie){try{$("#"+1.a).z(\'6\',5.j(2.A[0]))}catch(e){7 6="";7 f=$("#"+1.a);7 g=f.m("g")[0];5.select();3(top!=self){4.m.n.body.focus()}d{5.blur()}6=n.B.createRange().text;n.B.empty();f.hide();f.m("g").css({\'filter\':\'progid:C.D.E(sizingMethod=scale)\',\'width\':1.r+\'F\',\'height\':1.t+\'F\'});g.filters.item("C.D.E").6=6}}d{$("#"+1.a).z(\'6\',5.j(2.A[0]))}1.u()}})}});', [], 42, '|opts|this|if|window|_self|src|var|url|function|Img|file|createObjectURL|else||obj|div|ImgType||getObjectURL|undefined|value|parent|document|jQuery|extend|_this|Width|100|Height|Callback|URL|webkitURL|return|join|attr|files|selection|DXImageTransform|Microsoft|AlphaImageLoader|px'.split('|'), 0, {}));
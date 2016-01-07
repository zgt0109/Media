(function(_flex){
    if(!_flex) window.flex = {};
    window.flex.utils = utils;
    function utils(){};
    // load images
    // eg: utils.loadImg(url, function(w, h){ some code });
    utils.prototype.loadImg = function(url, callback) {
        var img = new Image();

        img.src = url;
        if (img.complete) {
            callback(img.width, img.height, null);
        } else {
            img.onload = function () {
                callback(img.width, img.height, null);
                img.onload = null;
            };
        };
        img.onerror = function(){
            callback(0, 0, "error");
        };
    };
    //load a group of images and return an array with images' size
    // eg: utils.loadImgGroup(urlArr, function(allImgArray){ some code });
    utils.prototype.loadImgGroup = function(urlArr, callback){
        var _this = this;
        var len = urlArr.length;
        var loadNum = 0;
        var allImgArray = [];
        for(var i=0; i<len; i++){
            (function(i){
                _this.loadImg(urlArr[i], function(w, h, msg){
                    loadNum++;
                    allImgArray[i] = {w:w, h:h, msg: msg};
                    if(loadNum == len)
                    {
                        callback(allImgArray);
                    }
                });
            })(i);
        }
    };
    // data format
    // eg: utils.dateFormat("yyyy-MM-dd hh:mm:ss")
    utils.prototype.dateFormat = function(format){
        var _date = new Date();
        var o = {
            "M+" :_date.getMonth() + 1, // month
            "d+" :_date.getDate(), // day
            "h+" :_date.getHours(), // hour
            "m+" :_date.getMinutes(), // minute
            "s+" :_date.getSeconds(), // second
            "q+" :Math.floor((_date.getMonth() + 3) / 3), // quarter
            "S" :_date.getMilliseconds() // millisecond
        }
        
        if (/(y+)/i.test(format)) {
            format = format.replace(RegExp.$1, (_date.getFullYear() + "")
                    .substr(4 - RegExp.$1.length));
        }
        
        for ( var k in o) {
            if (new RegExp("(" + k + ")").test(format)) {
                format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k]
                        : ("00" + o[k]).substr(("" + o[k]).length));
            }
        }

        return format;
    };
    // get url params
    // eg: utils.getQueryString(id);
    utils.prototype.getQueryString = function(name){
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    };

    // baidu map
    utils.prototype.setBaiduMap = function(id, mapx, mapy, mapTit, mapAddr, mapTel){
        var a = mapx,
            b = mapy;
        var map = new BMap.Map(id);            // 创建Map实例
        var point = new BMap.Point(a, b);    // 创建点坐标

        map.centerAndZoom(point, 19); // 初始化地图,设置中心点坐标和地图级别。
        map.enableScrollWheelZoom();     
        // map.panBy(-210,0)
        
        var marker = new BMap.Marker(new BMap.Point(a, b));  // 创建标注
        map.addOverlay(marker);              // 将标注添加到地图中
        if(mapTit && mapAddr && mapTel)
        {
            var sContent ="<div style='margin:0;line-height:1.8;font-size:14px;color:#626776;'><div style='font-weight:bold;'>"+mapTit+"</div><div style='margin-top:4px;'>"+mapAddr+"</div><div>电话：<span style='color:#f50426;'>"+mapTel+"</span></div></div>" + 
            "</div>";
            var infoWindow = new BMap.InfoWindow(sContent);      // 创建信息窗口对象
            // marker.setAnimation(BMAP_ANIMATION_BOUNCE); //跳动的动画
            //绑定标记单击事件
            marker.addEventListener("click", function(){          
               this.openInfoWindow(infoWindow);
               //图片加载完毕重绘infowindow
               document.getElementById('imgDemo').onload = function (){
                   infoWindow.redraw();   //防止在网速较慢，图片未加载时，生成的信息框高度比图片的总高度小，导致图片部分被隐藏
               }
            }); 
            map.openInfoWindow(infoWindow,point); //开启信息窗口
        }
        
    }

})(window.flex);
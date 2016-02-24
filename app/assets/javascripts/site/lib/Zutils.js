;(function(Zutils){
    !Zutils && (window.Zutils = Zutils = function(){});


    /*============================== Array ====================================*/

    // desp: 拷贝数组(不支持深度拷贝)****返回数组
    // usage: array.zCopy();
    Array.prototype.zCopy = function(fn){
        return this.concat();
        // return this.splice(0);
    };

    // desp: 遍历数组
    // usage: array.zEach(function(key, value, array){ some code... });
    Array.prototype.zEach = function(fn){
        for(var i = 0, l = this.length; l; fn && fn(i, this[i], this), i++, --l);
    };

    // desp: 获取数组最小/大值
    // usage: array.zMin();
    Array.prototype.zMin = function(){
        return Math.min.apply(null, this);
    };
    Array.prototype.zMax = function(){
        return Math.max.apply(null, this);
    };

    // desp: 将数组填充为同一个值
    // usage: array.zFill(val);
    Array.prototype.zFill = function(val){
        this.zEach(function(k, v, arr){
            arr[k] = val;
        });
        return this;
    };

    // desp: 从数组中取获取n个随机元素组成一个数组****返回数组
    // usage: array.zGetRandomArray(n);
    Array.prototype.zGetRandomArray = function(n){
        var arr = this.concat();
        var tmp = [];
        while(n){
            var r = Math.floor(Math.random() * arr.length);
            tmp.push(arr[r]);
            arr.splice(r, 1);
            n--;
        }
        return tmp;
    };

    // desp: 打乱数组****返回地址
    // usage: array.zShuffle();
    Array.prototype.zShuffle = function(){
        for (var r, tmp, l = this.length; l; r = parseInt(Math.random() * l), tmp = this[--l], this[l] = this[r], this[r] = tmp);
        return this;
    };

    // desp: 把array中值为val的元素与索引为ind的元素交换****返回地址
    // usage: array.zExchange(ind, val);
    Array.prototype.zExchange = function(ind, val){
        var tmp = this[ind];
        this.zEach(function(k, v, arr){
            if(v == val)
            {
                arr[ind] = v;
                arr[k] = tmp;
            }
        });
        return this;
    }

    

    /*============================== Date ====================================*/

    // desp: date format****返回地址
    // usage: date.("yyyy-MM-dd hh:mm:ss");
    Date.prototype.zFormat = function(format){
        var _date = this;
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



    /*============================== Math ====================================*/

    // desp: 获取任意范围的随机数
    // usage: zRandom(min, max);
    Math.zRandom = function(min, max){
        return min + Math.random() * (max-min);
    };



    /*============================== Zutils ====================================*/

    // desp: load images
    // usage: zutils.loadImg(url, function(w, h){ some code });
    Zutils.prototype.loadImg = function(url, callback) {
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

    // desp: load a group of images and return an array with images' size
    // usage: zutils.loadImgGroup(urlArr, function(allImgArray){ some code });
    // depends: zutils.loadImg
    Zutils.prototype.loadImgGroup = function(urlArr, callback){
        var _this = this;
        var len = urlArr.length;
        var loadNum = 0;
        var allImgArray = [];
        for(var i=0; i<len; i++){
            (function(i){
                _this.loadImg(urlArr[i], function(w, h, msg){
                    loadNum++;
                    allImgArray[i] = {w:w, h:h, msg:msg};
                    if(loadNum == len)
                    {
                        callback(allImgArray);
                    }
                });
            })(i);
        }
    };

    // desp: get url params
    // usage: zutils.getQueryString(id);
    Zutils.prototype.getQueryString = function(name){
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    };

    // desp: baidu map
    // usage: zutils.setBaiduMap(id, mapx, mapy, mapTit, mapAddr, mapTel);
    // depends: baiduMap API2.0
    Zutils.prototype.setBaiduMap = function(id, mapx, mapy, mapTit, mapAddr, mapTel){
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
    
})(window.Zutils);
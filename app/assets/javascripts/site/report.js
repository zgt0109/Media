// define waterfall flow
(function(){
    var utils = new Zutils();
    var waterFallFlow = window.waterFallFlow = function(ajaxUrl, ajaxMaxPage){
        this.ajaxUrl = ajaxUrl;
        this.ajaxMaxPage = ajaxMaxPage;
        this.ajaxPage = 1;
        this.colWidth = 390 + 15;
        this.colLen = 3;
        this.total = 0;
        this.container = $(".rep-list");
        this.loading = $(".rep-loading");
        this.colNewestHeight = new Array(this.colLen); // 记录所有列最后一行的高度

        this.tpl = '<div class="rep-list-item">\
                        <a href="{{link}}" target="_blank"><img src="{{img}}" alt="" /></a>\
                        <div class="rep-list-wrapp">\
                            <div class="rep-list-tit"><a href="{{link}}" target="_blank">{{title}}</a></div>\
                            <div class="rep-list-desp">{{desp}}</div>\
                            <div class="rep-list-detail"><a class="rep-c-3396d1" href="{{link}}" target="_blank">阅读详情&nbsp;&gt;</a></div>\
                        </div>\
                    </div>';

        this.isAjax = false;
    };
    waterFallFlow.prototype.init = function(){
        // 初始化this.colNewestHeight && this.colNewestTop
        for(var i = 0; i < this.colLen; this.colNewestHeight[i] = 0, i++);

        this.load();
        this.bindRequestEvent();
    };
    waterFallFlow.prototype.render = function(tpl, data){
        var self = this;
        var imgList = [];
        var htmlString = "";
        var waterFallList = null;

        $.each(data.datalist, function(key, val){
            var tpl = self.tpl;
            imgList.push(val.img);
            $.each(val, function(key2, val2){
                var exp = new RegExp("{{"+key2+"}}", "gi");
                tpl = tpl.replace(exp, val2);
            });

            htmlString += tpl;
        });

        self.layout(htmlString, imgList);
    };
    waterFallFlow.prototype.layout = function(htmlString, imgList){
        var self = this;
        var colHeightArr = self.colNewestHeight;
        var colLen = self.colLen;
        var colWidth = self.colWidth;

        utils.loadImgGroup(imgList, function(arrImgSize){
            var waterFallList = $(htmlString);
            self.container.append(waterFallList);

            waterFallList.each(function(i){
                // 如果图片加载失败则删除图片
                // if(arrImgSize[i].msg == "error"){
                //     $(this).find("img").remove();
                // }

                // 获取三列高度中的最小高度
                var minHeight = colHeightArr.zMin();
                var currItem = waterFallList.eq(i);
                var currHeight = currItem.show().outerHeight(true);
                currItem.hide();
                self.total++;
                console.log(i, currHeight)
                // 找到最小高度的索引值，并填充
                $.each(colHeightArr, function(key, val){
                     if(val == minHeight){
                        currItem.css({
                                "left": key * colWidth,
                                "top": minHeight
                            },1000
                        );

                        colHeightArr[key] += currHeight;

                        return false; // 避免数组的每项都与最想想相等，遇到一个则不再循环
                    }
                });
            });

            self.container.height(colHeightArr.zMax());
            waterFallList.fadeIn(800, function(){
                self.isAjax = false;
            });
            self.loading.fadeTo(400, 0);
        });
    };
    waterFallFlow.prototype.load = function(){
        var self = this;
        self.ajaxPage++;
        if(self.ajaxPage > self.ajaxMaxPage){
            this.loading.text("没有更多数据").css({"background": "none"});
        }else{
            $.ajax({
                url: self.ajaxUrl + "&page=" + self.ajaxPage,
                dataType: "json"
            }).done(function(data, sign, xhr){
                self.render(self.tpl, data);
            }).fail(function(x, y, z){
                console.error("数据加载失败");
            });
        }        
    };
    waterFallFlow.prototype.bindRequestEvent = function(){
        var self = this;
        var w = $(window);
        var d = $(document);
        var wHeight = w.height();

        w.resize(function(){
            wHeight = w.height();
        }).scroll(function(){
            var dHeight = d.height();
            var dTop = d.scrollTop();
            if(dHeight - dTop == wHeight){
                if(!self.isAjax){
                    self.isAjax = true;

                    self.loading.fadeTo(400, 1);
                    self.load();
                }
            }
        });
    };    
})();




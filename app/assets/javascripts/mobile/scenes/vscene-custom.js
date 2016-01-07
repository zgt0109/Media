(function(w, d, config){
    var defaults = {
            "start": 0,
            "direction": "vertical",  // vertical/horizontal
            "lottery": false,
            "music": false,  //音乐文件路径
            "loading": {
                "bgColor": "#fff",
                "loadingSrc": false
            }
        },
        config = $.extend({},defaults,config);
    var pages = window.pages = function(){
        this.wSize = [$(w).width(), $(w).height()];
        this.moveStart = [0, 0];
        this.moveDist = [0, 0];
        this.moveNow = [0, 0];
        this.stage = $("#stage");
        this.sections = $(".page", this.stage);
        this.len = this.sections.length;
        this.blank = "/assets/img/vscene/blank.gif";

        // 配置
        this.direction = config.direction; // vertical/horizontal
        this.directionObj = {horizontal: 0, vertical: 1};  // 定义字符串与0、1的映射
        this.directionNum = this.directionObj[this.direction]; // 根据this.direction对应到0、1
        this.scaling = 0;  // 当前页缩小的比例
        this.flexible = 0;  // 弹性范围

        // 当前操作元素的索引
        this.curr = config.start;
        this.prev = 0;
        this.next = 0;
        // 音乐加载动画计时器
        this.musicTimer = null;
        // 实例化工具库
        this.utils = new flex.utils();
        // 初始化场景
        this.init();
    };

    // init
    pages.prototype.init = function(){
        var _this = this;
        // show the arrows
        _this.setArrow();

        // loading
        _this.loading(function(){
            // init prev and next
            _this.updatePrevNext();
            // display the preinstall
            _this.sections.eq(_this.curr).show();

            // show lottery
            if(config.lottery){
                _this.lottery(function(){
                    // bind touch event
                    _this.unBind();
                    _this.bindTouchEvent();
                    _this.sections.eq(_this.curr).addClass("loaded");
                });
            }else{
                // bind touch event
                _this.unBind();
                _this.bindTouchEvent();
                _this.sections.eq(_this.curr).addClass("loaded");
                _this.showSections(0);
            }
            _this.renderPage();
            // set music
            if(config.music){
                _this.setMusic();
            }
        });
    };

    pages.prototype.renderPage = function(){
      var oBody = $("body"),
          nWidth = oBody.width(),
          nHeight = oBody.height(),
          nLeft = nTop = 0,
          scale = 1;
      nWidth / nHeight >= 320 / 486 ? (scale = nHeight / 486, nLeft = (nWidth / scale - 320) / 2) : (scale = nWidth / 320, nTop = (nHeight / scale - 486) / 2);
      var i = 320 / nWidth,
          j = 486 / nHeight,
          k = Math.max(i, j);
      k = k > 1 ? k : 160 * k, k = parseInt(k);
      $(".page section").css({"margin-top":nTop,"margin-left":nLeft});
      $("#eqMobileViewport").attr("content", "width=320, initial-scale=" + scale + ", maximum-scale=" + scale + ", user-scalable=no");
    }


    // images loading
    pages.prototype.loading = function(callback){
        if(!config.loading){
            if(callback) callback();
            return false;
        };
        var _this = this;
        var $loading = $("<div id='loading'></div>"),
            $loadingImg = $('<div class="loadingImg"></div>');
        // var loadingImg = $(".loadingImg", loading);
        var imgGroup = [];

        // push lottery的图片到imgGroup
        if(config.lottery) imgGroup.push(config.lottery);

        // show loading
        if(config.loading.bgSrc){
            $loading.css({"background-image": "url("+ config.loading.bgSrc +")"});
            imgGroup.push(config.loading.bgSrc);
        }
        if(config.loading.bgColor){
            $loading.css({"background-color": config.loading.bgColor});
        }
        if(config.loading.loadingSrc){
            $loadingImg.css({"background-image": "url("+ config.loading.loadingSrc +")"});
            imgGroup.push(config.loading.loadingSrc);
        }
        $loading.append($loadingImg);
        $("body").append($loading);
        // load all images in imgGroup
        // imgGroup = imgGroup.slice(0, 7);   // 加载部分文件，减少加载时间
        _this.utils.loadImgGroup(imgGroup, function(){
            $loading.hide().remove();
            if(callback) callback();
        });
    };
    // lottery涂抹
    pages.prototype.lottery = function(callback){
        var _this = this,
            $lotter = $("<div id='lottery'></div>");
        $("body").append($lotter);
        // 初始化lottery
        $lotter.lottery({
            success:function(){
                _this.showSections(500);
            },
            coverType: 'image',
            cover: config.lottery,
            width: $(window).width(),
            height: $(window).height(),
            //cbdelay: 300,
            callback: function(percent){
                if(percent > 50)
                {
                    $lotter.fadeOut(800,function(){
                        $lotter.remove();
                    });
                    if(callback) callback();
                }
            }
        });
    };
    // show sections
    pages.prototype.showSections = function(time){
        setTimeout(function(){
            $(".html").addClass("commonFadeIn");
        },time);
    };
    // update prev and next
    pages.prototype.updatePrevNext = function(){
        var temp1 = temp2 = this.curr;
        this.prev = --temp1 < 0 ? this.len-1 : temp1;
        this.next = ++temp2 > this.len-1 ? 0 : temp2;
    };
    // show arrwo
    pages.prototype.setArrow = function(){
        var $html = $(".html"),
            btn;
        if(config.direction == "vertical"){
            btn = $('<div class="vBtn"></div>');
        }else{
            btn = $('<div class="hBtn hBtnL"></div><div class="hBtn hBtnR"></div>');
        }
        $html.append(btn);
    };
    // show music tips
    // 0->"loading", 1->"on", 2->"off"
    pages.prototype.showMusicTips = function(typeId, callback){
        var _this = this;
        var tips = $("#music").children(".tips");
        var type = ["loading", "on", "off"];
        var dot = [".", "..", "..."];
        var i = 0;
        tips.text(type[typeId]);
        if(typeId == 0){
            _this.musicTimer = setInterval(function(){
                tips.text("loading" + dot[i]);
                i = ++i > 2 ? 0 : i;
            }, 500);
        }
        tips.fadeIn(400);
        if(callback) callback();
    };
    // hide music tips
    pages.prototype.hideMusicTips = function(delay, callback){
        var _this = this;
        var tips = $("#music").children(".tips");
        // 清除可能的loading动画
        clearInterval(_this.musicTimer);
        tips.delay(delay).fadeOut(400, function(){
            if(callback) callback();
        });
    };
    // set music
    pages.prototype.setMusic = function(){
        var _this = this;
        var $music = $('<div class="off" id="music"><em class="icon"></em><div class="tips"></div></div>');
        var isMusicLoaded = false;
        var isWaittingPlay = false;
        var isPlaying = false;
        var tips = $music.find(".tips");
        var audio = new Audio;
        // 判断是否支持mpeg格式的音乐
        if (audio != null && audio.canPlayType && audio.canPlayType("audio/mpeg")){
            // 显示播放按钮
            $(".html").append($music);
            // 配置播放属性
            $(audio).prop({
                loop: true,
                preload: "auto",
                src: config.music,
                type: "audio/mpeg"
            });

            // 开关
            function musicOff(){
                $music.attr("class","off");
                isPlaying = false;
                audio.pause()
                _this.showMusicTips(2, function(){
                    _this.hideMusicTips(400);
                });
            }
            function musicOn(){
                $music.attr("class", "on");
                isPlaying = true;
                audio.play();
                _this.showMusicTips(1, function(){
                    _this.hideMusicTips(400);
                });
            }
            $music.on("touchstart", function(e){
                var e = e || event;
                if(isMusicLoaded){  // 音频可以流畅播放的点击
                    isPlaying ? musicOff() : musicOn();
                }
                else{  // 音频不能流畅播放的点击
                    if(isWaittingPlay){  //取消等待播放
                        isWaittingPlay = false;
                        _this.hideMusicTips(400);
                    }else{  //开始等待播放
                        isWaittingPlay = true;
                        _this.showMusicTips(0);
                    }
                }
                // 阻止冒泡到stage上
                e.stopPropagation();
            });
            // 音频能够播放时触发事件
            audio.addEventListener('canplaythrough', function (e) {
                isMusicLoaded = true;
                // 如果在等待播放，则开始播放音乐
                if(isWaittingPlay){
                    _this.hideMusicTips(0, function(){
                        musicOn();
                    });
                }
            }, false);
            // 自动播放
            $music.trigger("touchstart");
            // 手机设备不能自动播放，上需要触控才能触发的播放
            $(d).one("touchstart", function(){
                musicOn();
            });
        }
    };
    // remove map touch event
    pages.prototype.unBind = function(){
        var _this = this,
            _map = $(".map-content");
        _map.on("touchstart touchmove",function(){
            return false;
        });
    }
    // bind touch event
    pages.prototype.bindTouchEvent = function(){
        var _this = this;
        var _stage = _this.stage;
        var _sections = _this.sections;
        var _curr, _prev, _next;
        var prevSwitch = nextSwitch = 0;
        var XorY = _this.directionNum ? "Y" : "X";
        var moveDist = 0;
        var wSize = _this.wSize[_this.directionNum];
        _stage.on("touchstart", function(e){
            var touches = e.originalEvent.targetTouches;
            var touch = touches[0];
            // 不是单指触控则结束操作
            if(touches.length != 1) return false;
            // 更新相关屏
            _curr = _sections.eq(_this.curr);
            _prev = _sections.eq(_this.prev);
            _next = _sections.eq(_this.next);
            _curr.css({"-webkit-transition": "none"});
            _prev.css({"-webkit-transition": "none"});
            _next.css({"-webkit-transition": "none"});
            // 记录start的touch坐标，并取消过度属性
            _this.moveStart = [touch.pageX, touch.pageY];
        }).on("touchmove", function(e){
            var touches = e.originalEvent.targetTouches;
            var touch = touches[0];
            // 获取当前坐标，获取移动的位移
            _this.moveNow = [touch.pageX, touch.pageY];
            _this.moveDist = [_this.moveNow[0]-_this.moveStart[0], _this.moveNow[1]-_this.moveStart[1]];
            // 更新moveDist
            moveDist = _this.moveDist[_this.directionNum];
            // 计算偏移量和缩放
            var scaleRoate = 1 - Math.abs(moveDist/wSize) * _this.scaling;
            var shiftingCurr = moveDist * _this.scaling/2
            var shiftingPrev = wSize * -1 + moveDist;
            var shiftingNext = wSize + moveDist;
            // 移动curr
            _curr.css({
                "-webkit-transform": "translate" + XorY + "(" + shiftingCurr + "px) scale(" + scaleRoate + ")",
                "z-index": 20
            });
            // 移动prev、next
            if(moveDist > 0){
                if(!prevSwitch){
                    prevSwitch = 1;
                    nextSwitch = 0;

                    _next.css({
                        "-webkit-transform": "translate" + XorY + "("+(wSize)+"px)",
                        "display": "none",
                        "z-index": 10
                    });
                    _prev.css({
                        "display": "block",
                        "z-index": 30
                    });
                    // 检测touchmove时各个page的层级
                    // _curr.append("<p style='font-size: 20px;'>" + _curr.css("z-index") + _prev.css("z-index") + "</p>");
                }
                _prev.css({
                    "-webkit-transform": "translate" + XorY + "(" + shiftingPrev + "px)"
                });
            }
            else{
                if(!nextSwitch){
                    nextSwitch = 1;
                    prevSwitch = 0;

                    _prev.css({
                        "-webkit-transform": "translate" + XorY + "(" + (wSize * -1) + "px)",
                        "display": "none",
                        "z-index": 10
                    });
                    _next.css({
                        "display": "block",
                        "z-index": 30
                    });
                }

                _next.css({
                    "-webkit-transform": "translate" + XorY + "(" + shiftingNext + "px)"
                });
            }

            // 阻止document默认滚动行为
            e.preventDefault();
        }).on("touchend", function(e){
            var touches = e.originalEvent.targetTouches;
            var touch = touches[0];

            // 不是单指触控则结束操作，如果是单指操作，则touchend的targetTouches为0
            if(touches.length > 0) return false;

            var flexible = wSize * _this.flexible;
            var scaleRoate = 1 - _this.scaling;
            var shiftingCurr;

            var scaleRoateRecovery = 1;
            var shiftingCurrRecovery = 0;
            var shiftingPrevRecovery = wSize * -1;
            var shiftingNextRecovery = wSize;

            // 重置开关
            prevSwitch = nextSwitch = 0;

            // 排除没有touchmove的情况
            if(moveDist != 0)
            {
                // 将prev、next运动到目标位置，在弹性范围内则回复到初始状态，否则切换到下一屏
                if(Math.abs(moveDist) > flexible)
                {
                    if(moveDist > 0){
                        shiftingCurr = wSize * _this.scaling/2;

                        _this.curr = --_this.curr < 0 ? _this.len-1 : _this.curr;

                        _prev.css({
                            "-webkit-transform": "translate" + XorY + "(0px)",
                            "-webkit-transition": "0.3s ease-out"
                        });
                    }
                    else if(moveDist < 0){
                        shiftingCurr = wSize * -1 * _this.scaling/2;

                        _this.curr = ++_this.curr > _this.len-1 ? 0 : _this.curr;

                        _next.css({
                            "-webkit-transform": "translate" + XorY + "(0px)",
                            "-webkit-transition": "0.3s ease-out"
                        });
                    }
                    // 将curr运动到目标位置
                    _curr.css({
                        "-webkit-transform": "translate" + XorY + "(" + shiftingCurr + "px) scale(" + scaleRoate + ")",
                        "-webkit-transition": "0.3s ease-out"
                    });

                    // 更新 prev、next
                    _this.updatePrevNext();
                    // console.log("before:"+_this.curr)
                }
                else{
                    if(moveDist > 0){
                        shiftingCurr = wSize * _this.scaling/2;

                        _prev.css({
                            "-webkit-transform": "translate" + XorY + "(" + shiftingPrevRecovery + "px)",
                            "-webkit-transition": "0.3s ease-out"
                        });
                    }
                    else if(moveDist < 0){
                        shiftingCurr = wSize * -1 * _this.scaling/2;

                        _next.css({
                            "-webkit-transform": "translate" + XorY + "(" + shiftingNextRecovery + "px)",
                            "-webkit-transition": "0.3s ease-out"
                        });
                    }
                    // 将curr运动到目标位置
                    _curr.css({
                        "-webkit-transform": "translate" + XorY + "(" + shiftingCurrRecovery + "px) scale(" + scaleRoateRecovery + ")",
                        "-webkit-transition": "0.3s ease-out"
                    });
                }
                // 重置初始位置和偏移量
                moveDist = 0;
                setTimeout(function(){
                    // console.log("after:"+_this.curr)
                    _sections.eq(_this.curr).addClass("loaded").siblings(".page").removeClass("loaded");
                }, 300);
            }
        });
    };
})(window, document, config);
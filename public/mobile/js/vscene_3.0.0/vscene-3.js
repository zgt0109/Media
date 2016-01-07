(function(w, d, config){
    var pages = window.pages = function(){
        this.wSize = [$(w).width(), $(w).height()];
        this.moveStart = [0, 0];
        this.moveDist = [0, 0];
        this.moveNow = [0, 0];
        this.stage = $("#stage");
        this.sections = null;
        this.len = 0;
        this.blank = "../assets/img/vscene-2/blank.gif";

        // 配置
        this.direction = config.direction; // vertical/horizontal
        this.directionObj = {horizontal: 0, vertical: 1};  // 定义字符串与0、1的映射
        this.directionNum = this.directionObj[this.direction]; // 根据this.direction对应到0、1
        this.scaling = 0.2;  // 当前页缩小的比例
        this.flexible = 0.2;  // 弹性范围

        // 当前操作元素的索引
        this.curr = config.start;
        this.prev = 0;
        this.next = 0;

        // 音乐加载动画计时器
        this.musicTimer = null;

        // 实例化工具库
        this.utils = new flex.utils();
    };

    // init
    pages.prototype.init = function(){
        var _this = this;

        // set scene size
        _this.scale();

        // show the arrows
        _this.setArrow();

        // loading
        _this.loading(function(){
            // create sections
            _this.createSections();
            // init prev and next
            _this.updatePrevNext();
            // display the preinstall
            _this.sections.eq(_this.curr).show();

            // show lottery
            if(config.lottery.has){
                _this.lottery(function(){
                    // bind touch event
                    _this.bindTouchEvent();
                    _this.sections.eq(_this.curr).removeClass("active");
                    _this.showSections();
                });
            }else{
                // bind touch event
                _this.bindTouchEvent();
                _this.sections.eq(_this.curr).removeClass("active");
                _this.showSections();
            }

            // set music
            if(config.music.has){
                _this.setMusic();
            }
        });
    };

    // images loading
    pages.prototype.loading = function(callback){
        var _this = this;
        var loading = $("#loading");
        var loadingImg = $(".loadingImg", loading);
        var imgGroup = [];
        var scenes = config.scenes;

        // push lottery的图片到imgGroup
        if(config.lottery.has) imgGroup.push(config.lottery.src);

        // push所有.page里面的图片到imgGroup
        for(var i=0, lenList=scenes.length; i<lenList; i++){
            var scene = scenes[i],
                elems = scene.elems;
            // push当前section的背景到imgGroup
            if(scene.backgroundImage && (scene.backgroundImage != 'none') )
            {
                imgGroup.push(scene.backgroundImage);
            }

            // push每个section里面的图片到imgGroup
            for(var j=0, imgList=elems.length; j<imgList; j++)
            {
                var elem = elems[j];
                if(elem.type === "img" && elem.props.src)
                {
                    imgGroup.push(elem.props.src);
                }
            }
        }
        // show loading
        if(config.loading.bgSrc){
            loading.css({"background-image": "url("+ config.loading.bgSrc +")"});
        }
        if(config.loading.bgColor){
            loading.css({"background-color": config.loading.bgColor});
        }
        if(config.loading.loadingSrc){
            loadingImg.css({"background-image": "url("+ config.loading.loadingSrc +")"});
        }

        // 如果有图片
        if(imgGroup.length > 0){
            // load all images in imgGroup
            // imgGroup = imgGroup.slice(0, 7);   // 加载部分文件，减少加载时间
            _this.utils.loadImgGroup(imgGroup, function(xxxx){
                loading.fadeOut(1000);
                if(callback) callback();
            });
        }else{
            loading.fadeOut(1000);
            if(callback) callback();
        }


    };

    // lottery涂抹
    pages.prototype.lottery = function(callback){
        var win = $(window),
            winWidth = win.width(),
            winHeight = win.height(),
            winRatio = winWidth / winHeight,
            lottery = $('#lottery'),
            lotteryWidth,
            lotteryHeight,
            lotteryRatio,
            scale = 1,
            canvasWidth, canvasHeight,
            callbackFlag = 1; //当lottery还没渐隐完时，用户可能在涂抹面积完成的情况下继续涂抹，会造成回调函数多次执行，这里设置一个状态

        this.utils.loadImg(config.lottery.src, function(w, h, msg){
            if(msg !== 'error'){
                lotteryWidth = w,
                lotteryHeight = h,
                lotteryRatio = lotteryWidth / lotteryHeight;

                if(winRatio > lotteryRatio){
                    scale = winWidth / lotteryWidth;
                    canvasWidth = winWidth;
                    canvasHeight = scale * lotteryHeight;
                }else{
                    scale = winHeight / lotteryHeight;
                    canvasWidth = scale * lotteryWidth;
                    canvasHeight = winHeight;
                }

                // 设置lottery的大小
                lottery.css({ width: canvasWidth, height: canvasHeight });

                // 初始化lottery
                lottery.lottery({
                    coverType: 'image',
                    cover: config.lottery.src,
                    width: canvasWidth,
                    height: canvasHeight,
                    //cbdelay: 300,
                    callback: function(percent){
                        if(percent > 35)
                        {
                            if(callbackFlag){
                                $(this).parent().fadeOut(400);
                                if(callback) callback();
                                callbackFlag = 0;
                            }
                        }
                    },
                    success: function(){
                        // console.log("success")
                    }
                });
            }else{
                lottery.hide();
                if(callback) callback();
            }
        })

    };

    // 缩放页面使内容能够完整展示
    pages.prototype.scale = function(callback){
        var win = $(window),
            winWidth = win.width(),
            winHeight = win.height(),
            winRatio = winWidth / winHeight,
            sceneWidth = config.sceneSize.width,
            sceneHeight = config.sceneSize.height,
            sceneRatio = sceneWidth / sceneHeight,
            scale = 1;

        if(winRatio > sceneRatio){
            scale = winHeight / sceneHeight;
        }else{
            scale = winWidth / sceneWidth;
        }

        $('#viewport').attr('content', 'width=' + sceneWidth +', initial-scale=' + scale + ', maximum-scale=' + scale + ', user-scalable=no');
    };

    // show sections
    pages.prototype.showSections = function(){
        $(".pages").addClass("commonFadeIn");
    };

    // withCurrConfig为布尔值，说明元素用当前的配置对象渲染还是模板配置渲染
    // function formatElemWith(currElem, excludeArray, withCurrConfig)
    pages.prototype.formatStyle = function(currElem, excludeArray, props){
        var map = window.vsceneMap,
            mapAction = vsceneMap.mapAction,
            mapUnit = vsceneMap.mapUnit,
            excludeArray = excludeArray || [],
            isScene = currElem.hasClass('page'),
            currElemWrapp;

        if(!isScene){  //当前元素是elem
            currElemWrapp = currElem.find('.xscene-elem-wrapp');
        }

        $.each(props, function(key, value){
            var mapActionType = mapAction[key],
                value = mapUnit[key] ? (value + mapUnit[key]) : value;  // 增加对应属性的单位

            // 排除不需要设置的属性
            if($.inArray(key, excludeArray) === -1){
                if(mapActionType === 'html'){
                    currElemWrapp.html(value);
                }else if(mapActionType === 'text'){
                    currElemWrapp.text(value);
                }else if(mapActionType === 'addClass'){
                    currElem.addClass(value);
                }else if(mapActionType === 'image'){
                    currElemWrapp.html('<img class="xscene-img-img" src="' + value + '" alt="">');
                }else if(mapActionType === 'cssBgImage'){
                    if(value !== 'none'){
                        value = 'url(' + value + ')';
                    }
                    currElem.css('backgroundImage', value);
                }else{ //css, attr
                    currElem[mapActionType](key, value);
                    if(key === 'animationName'){
                        if(value === 'none'){
                            currElem.addClass('noEffect');
                        }else{
                            currElem.addClass(value);
                        }
                    }
                }
            }

        });
    };

    // 设置跳转
    pages.prototype.location = function(elem){
        elem.on('click', function(e){
            e.stopPropagation();
            var link = elem.attr('data-href'),
                videoSrc = elem.attr('data-video');

            if(elem.attr('data-href-type') != 'none'){
                if(link)
                    window.location.href = link;
            }
            if(videoSrc){
                var modal = '<div class="modal">\
                                <div class="modal-head"><i class="icon-close"></i></div>\
                                <div class="modal-content">'
                                + videoSrc +
                                '</div>\
                            </div>';
                $("body").append(modal);
                $(".modal-head").on("click",function(){
                    $(".modal").remove();
                })
            }
        });


    };

    // create scenes
    pages.prototype.createSections = function(){
        var _this = this,
            scenes = config.scenes,
            scenesLen = scenes.length,
            i = 0;

        // create scene
        for(i = 0; i < scenesLen; i++){
            var scene = scenes[i];
                elems = scene.elems,
                elemsLen = elems.length,
                sceneObj = $('<section class="page"><div class="page-wp"></div></section>').appendTo(".pages"),
                sceneWpObj = sceneObj.find('.page-wp').css({ width: config.sceneSize.width, height: config.sceneSize.height }),
                j = 0;

            _this.formatStyle(sceneObj, ['elems', 'name', 'tplid'], scene);
            _this.location(sceneObj);

            // create elements
            for(j = 0; j < elemsLen; j++){
                var elem = elems[j],
                    elemType = elem.type,
                    elemPorps = elem.props,
                    elemObj = $('<div class="xscene-elem"><div class="xscene-elem-wrapp"></div></div>').appendTo(sceneWpObj).addClass("xscene-" + elemType),
                    elemWrappObj = elemObj.find(".xscene-elem-wrapp");

                _this.formatStyle(elemObj, [], elemPorps);
                _this.location(elemObj);
            }

        }

        // 填充 this.sections 和 this.len
        this.sections = $(".page", this.stage).addClass('active');
        this.len = this.sections.length;
    };

    // update prev and next
    pages.prototype.updatePrevNext = function(){
        var temp1 = temp2 = this.curr;
        this.prev = --temp1 < 0 ? this.len-1 : temp1;
        this.next = ++temp2 > this.len-1 ? 0 : temp2;
    };

    // show arrwo
    pages.prototype.setArrow = function(){
        $("html").addClass(config.direction);
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
        var isMusicLoaded = false;
        var isWaittingPlay = false;
        var isPlaying = false;
        var music = $("#music");
        var tips = music.children(".tips");
        var audio = new Audio;
        // 判断是否支持mpeg格式的音乐
        if (audio != null && audio.canPlayType && audio.canPlayType("audio/mpeg")){
            var source = document.createElement("source");

            // 显示播放按钮
            music.show();

            // 配置播放属性
            $(source).prop({
                loop: true,
                preload: "auto",
                src: config.music.src,
                type: "audio/mpeg"
            });
            // chrome下只能用source添加音频并且要指定type，在audio上添加src在chrome上不能播放，但能在ie上播放
            audio.appendChild(source);

            // 开关
            function musicOff(){
                music.attr("class", "off");
                isPlaying = false;
                audio.pause()
                _this.showMusicTips(2, function(){
                    _this.hideMusicTips(400);
                });
            }
            function musicOn(){
                music.attr("class", "on");
                isPlaying = true;
                audio.play();
                _this.showMusicTips(1, function(){
                    _this.hideMusicTips(400);
                });
            }

            music.on("touchstart", function(e){
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

                // console.log("music can play through");

                // 如果在等待播放，则开始播放音乐
                if(isWaittingPlay){
                    _this.hideMusicTips(0, function(){
                        musicOn();
                    });
                }
            }, false);

            // 自动播放
            music.trigger("touchstart");
            // 手机设备不能自动播放，上需要触控才能触发的播放
            $(d).one("touchstart", function(){
                musicOn();
            });
            $(".xscene-video").on("click",function(){
                musicOff();
            });
        }
    };

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

        // 如果只有一页则不滑动
        if(_sections.length < 2) return false;

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
                    _sections.addClass("active").eq(_this.curr).removeClass("active");
                }, 300);
            }

        });
    };
})(window, document, config);
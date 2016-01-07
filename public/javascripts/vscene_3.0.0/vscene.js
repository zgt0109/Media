// 创建xsceneDesp存储整个场景的数据
;(function(obj){
    if(!obj.xsceneDesp) obj.xsceneDesp = [];
})( window.xconfig = window.xconfig ? window.xconfig : {} );

$(function(){
    // 全局配置
    var xutils = window.xutils;
    var xconfig = window.xconfig;
    var xpanelsControls = xconfig.xpanelsControls;
    var xpanelsControlsDefined = xconfig.xpanelsControlsDefined;
    var xelemModule = xconfig.xelemModule;
    var xsceneDespTpl = xconfig.xsceneDespTpl;
    var xsceneDesp = xconfig.xsceneDesp;
    var xsceneTplHtml = xconfig.xsceneTplHtml;
    var xsceneTplList = xconfig.xsceneTplList;
    var xsceneTplData = xconfig.xsceneTplData;

    // 页面管理
    var xleftClass = '.xleft',
        xpageAddClass = '.xpage-add',
        xpageSaveClass = '.xpage-save',
        xpageListClass = '.xpage-list',
        xpagesPageClass = '.xpage-page',
        xpagesPageInputClass = '.xpage-page-input',
        xpagesEditClass = '.xpage-edit',
        xpagesCopyClass = '.xpage-copy',
        xpagesDeleteClass = '.xpage-delete',
        xpagesClass = '.xpage-item',
        xpagesActiveClassName = 'xpage-active',
        xpagesActiveClass = '.' + xpagesActiveClassName,
        xleft = $(xleftClass),
        xpageAdd = $(xpageAddClass),
        xpageSave = $(xpageSaveClass),
        xpageList = $(xpageListClass),
        xpages = $(xpagesClass),
        xpagesTpl = '<li class="xtransition xpage-item">\
                        <span class="xpage-page">{{pagesNumber}}</span>\
                        <span class="xpage-icon xpage-edit xcursor-pointer"></span>\
                        <span class="xpage-icon xpage-copy xcursor-pointer"></span>\
                        <span class="xpage-icon xpage-delete xcursor-pointer"></span>\
                    </li>',
        xpagesCurr = $(xpagesActiveClass).index(), // 当前所在页的索引
        xpagesLen = xpages.length, // 有多少页
        xpagesSortStartIndex = 0,
        xpagesSortStopIndex = 0;
    // 页面设置
    var xsceneSettingItemsClass = '.xscene-setting-item',
        xsceneSettingItems = $(xsceneSettingItemsClass);
    // 右侧
    var xrightClass = '.xright',
        xpanelClass = '.xpanel',
        xpanelTabClass = '.xpanel-tab',
        xpanelHeadClass = '.xpanel-head',
        xpanelHeadListClass = '.xpanel-head-list',
        xpanelHeadItemClass = '.xpanel-head-item',
        xpanelMainClass = '.xpanel-main',
        xpanel = $(xpanelClass),
        xpanelTab = $(xpanelTabClass),
        xpanelTabHeadTpl = '<li class="xpanel-head-item xcursor-pointer xtransition"></li>',
        xpanelTabMainTpl = '<div class="xpanel-main"></div>',
        xpanelTabTpl = '<div class="xpanel-tab xborder xradius">\
                            <div class="xpanel-head xclearfix">\
                                <ul class="xpanel-head-list xclearfix"></ul>\
                            </div>\
                        </div>';
    // droppable状态classes
    var droppableActiveClassName = 'xscene-droppable-active',
        droppableHoverClassName = 'xscene-droppable-hover';
    // 控件
    var xwidgetClass = '.xwidget',
        xwidgetsClass = '.xwidget-item',
        xwidgetsHelperWrapp = '.xwidget-helper-wrapp',
        xwidgets = $(xwidgetsClass);
    // 场景
    var xsceneViewClass = '.xscene-view',
        xsceneClassName = 'xscene-scene',
        xsceneClass = '.' + xsceneClassName,
        xsceneActiveClassName = 'xscene-scene-active',
        xsceneActiveClass = '.' + 'xscene-scene-active',
        xsceneSettingListClass = '.xscene-setting-list',
        xsceneSettingItemClass = '.xscene-setting-item',
        xsceneSettingBgClass = '.xscene-setting-bg',
        xsceneSettingTplClass = '.xscene-setting-tpl',
        xsceneSettingQrcodeClass = '.xscene-setting-qrcode',
        xsceneView = $(xsceneViewClass),
        xsceneScene = $(xsceneClass),
        xsceneViewWidth = 320,
        // xsceneViewHeight = 570;
        xsceneViewHeight = 486;
    // 页面元素
    var xelemClass = '.xscene-elem',
        xelemActiveClassName = 'xscene-elem-active',
        xelemActiveClass = '.' + xelemActiveClassName,
        xelemDeleteClass = '.xscene-elem-close',
        // 元素的基本class
        xelemClassesBase = xelemModule.xelemClassesBase,
        // 元素的公共子元素
        xelemChildrenPublic = xelemModule.xelemChildrenPublic,
        // 元素的种类class与其包含的子元素，顺序与控件的位置一致
        xelemDefault = xelemModule.xelemDefault;

    // 页面设置面板是否存在，用于元素控制面板和页面控制面板间的切换判断
    var isSettingPanelExist = false;

    // ueditor的全局实例对象
    var editorLivingGlobal = null;




/* ============================== 操作页面start ==================================== */

    // 左侧所有按钮的事件绑定(包括：页面的复制、页面的删除，页面标题的编辑、页面的增加、场景的保存)
    xleft
        .on('click', xpagesDeleteClass, function(e){
            e.stopPropagation();

            var self = $(this);

            $.xmodal({
                msg: '确定删除本页吗？',
                btns: ['确定', '取消'],
                fnBtns: [function(){
                    var nowItem = self.closest(xpagesClass);
                    var nowIndex = nowItem.index();

                    // 对配置对象中对应的页面对象进行删除
                    xsceneDesp.splice(nowIndex, 1);

                    // 删除页面和对应的导航
                    if(nowIndex === xpagesCurr){
                        if(xpagesLen === 1){
                            $(xsceneClass).eq(nowIndex).fadeOut(400, function(){
                                $(this).remove();
                                xpagesCurr = -1;
                            });
                        }else if(nowIndex < xpagesLen-1){
                            $(xpagesClass).eq(nowIndex + 1).trigger('click', [function(){
                                $(xsceneClass).eq(nowIndex).remove();
                            }]);

                            xpagesCurr = nowIndex;
                        }else if(nowIndex = xpagesLen-1){
                            $(xpagesClass).eq(nowIndex - 1).trigger('click', [function(){
                                $(xsceneClass).eq(nowIndex).remove();
                            }]);

                            nowIndex = xpagesLen-1; // 也可不要，因为在trigger('click')中已经更新了
                        }

                        nowItem.remove();
                        resetSceneSettingButton();
                    }else{
                        $(xsceneClass).eq(nowIndex).remove();
                        nowItem.remove();
                        xpagesCurr = $(xpagesActiveClass).index();
                    }

                    // 记录剩下的页面个数
                    xpagesLen--;

                }, null]
            });


        })
        .on('blur', xpagesPageInputClass, function(e){
            e.stopPropagation();

            var self = $(this),
                itemMain = self.closest(xpagesPageClass),
                item = itemMain.parent();

            itemMain.empty().text(self.val());
            xsceneDesp[ item.index() ].name = self.val();
        })
        .on('keydown', xpagesPageInputClass, function(e){
            if(e.keyCode==13){
                $(this).trigger('blur');
            }
        })
        .on('click', xpagesEditClass, function(e){
            e.stopPropagation();

            var item = $(this).closest(xpagesClass),
                itemMain = item.find(xpagesPageClass),
                itemText = $.trim(itemMain.text()),
                itemInput = $('<input type="text" class="xpage-page-input">').val(itemText);

            itemMain.empty()
            itemInput.appendTo(itemMain).trigger('focus');

        })
        .on('click', xpageAddClass, function(e){
            xpagesLen++;

            var nowIndex = xpagesLen-1;

            // 向配置对象中添加对应的页面对象
            xsceneDesp.push($.extend(true, {}, xsceneDespTpl.scene));

            // 添加page导航
            var pagesTpl = xpagesTpl.replace('{{pagesNumber}}', xsceneDespTpl.scene.name);
            $(pagesTpl).appendTo(xpageList);

            // 添加scene
            var currScene = $('<div class="xscene-scene"></div>').appendTo(xsceneView);
            // 格式化当前页面
            formatElemWith(currScene , ['elems', 'name', 'tplid'], false);
            // 设置拖拽
            setDroppable(currScene);
            // 激活为当前页
            $(xpagesClass)
                .eq(nowIndex).trigger('click')
                .find(xpagesEditClass).trigger('click');

        })
        .on('click', xpagesCopyClass, function(e){
            e.stopPropagation();

            xpagesLen++;

            var nowIndex = xpagesLen-1;

            var item = $(this).closest(xpagesClass),
                itemIndex = item.index(),
                itemInput = item.find(xpagesPageInputClass).trigger('blur'),
                itemName = $.trim(item.find(xpagesPageClass).text()),
                aimScene = $(xsceneClass).eq(itemIndex),
                aimElemIndex = aimScene.find(xelemActiveClass).index(),
                aimConfigObj = xsceneDesp[itemIndex],
                currConfigObj = $.extend(true, {}, aimConfigObj);

            // 向配置对象中添加对应的页面对象
            xsceneDesp.push(currConfigObj);

            // 添加page导航
            var pagesTpl = xpagesTpl.replace('{{pagesNumber}}', itemName + '-copy');
            $(pagesTpl).appendTo(xpageList);

            // 添加scene
            var currScene = $('<div class="xscene-scene"></div>').appendTo(xsceneView);
            // 填充被复制的元素
            currScene.html(aimScene.html());
            // 格式化当前页面
            formatElemWith(currScene , ['elems', 'name', 'tplid'], true);
            // 设置拖拽
            setDroppable(currScene);
            currScene.find(xelemClass).each(function(){
                setDraggable($(this), currScene);
            });
            // 激活为当前页
            $(xpagesClass)
                .eq(nowIndex).trigger('click')
                .find(xpagesEditClass).trigger('click');
            // 激活当前元素
            currScene
                .find(xelemClass).removeClass(xelemActiveClassName)
                .eq(aimElemIndex).trigger('click.setElemActive');
        })
        .on('click', xpageSaveClass, function(e){
            xconfig.saveScene && xconfig.saveScene(xsceneDesp);
            // $.xmodal({
            //     msg: '场景已保存'
            // });

            // alert(JSON.stringify(xsceneDesp));
        })
        .on('click', xpagesClass, function(e, callback, xpagesCurrRemoved){
            var indexOld = xpagesCurr, // 保存当前页面的索引值
                indexNew = xpagesCurr = $(xpagesClass).index(this), // 当前点击的索引值
                scenes = $(xsceneClass),
                sceneOld = scenes.eq(indexOld),
                sceneNew = scenes.eq(indexNew),
                animateDirection = 1;

            // 点击page item保存当前编辑的页面名称
            $(this).find(xpagesPageInputClass).trigger('blur');

            // 给当前的页面按钮添加激活状态class
            $(xpagesClass).removeClass(xpagesActiveClassName);
            $(this).addClass(xpagesActiveClassName);

            // 给当前的scene添加激活状态的class
            scenes.removeClass(xsceneActiveClassName);
            sceneNew.addClass(xsceneActiveClassName);

            // 如果是当前页不执行任何操作
            if(indexNew === indexOld) return false;

            resetSceneSettingButton();

            animateDirection = indexNew > indexOld ? 1 : -1;
            sceneOld.css({ transition: 'none', transform: 'translateY(0px)' });
            sceneNew.css({ transition: 'none', transform: 'translateY(' + (animateDirection * xsceneViewHeight) + 'px)' });

            // 开始运动
            setTimeout(function(){
                sceneOld.css({ transition: 'all 0.4s ease-out 0s', transform: 'translateY(' + (-animateDirection * xsceneViewHeight) + 'px)' });
                sceneNew.css({ transition: 'all 0.4s ease-out 0s', transform: 'translateY(0px)' });

                setTimeout(function(){
                    callback && callback();
                }, 400);
            }, 0);

            // 播放动画
            playAnimation(sceneNew);
        });

        $(xsceneClass).css({ transform: 'translateY(' + xsceneViewHeight + 'px)' })
        $(xpagesClass).eq(xpagesCurr).trigger('click');

    // 拖拽排序
    xpageList
        .sortable({
            distance: 5,
            activate: function(e, ui){
                xpagesSortStartIndex = $(xpagesClass).index(ui.item);
            },
            stop: function(e, ui){
                xpagesSortStopIndex = $(xpagesClass).index(ui.item);
                var scenes = $(xsceneClass);
                var sceneActiveIndex = $(xpagesActiveClass).index();

                // 调整配置对象里的scene顺序
                xutils.moveElemInArray(xsceneDesp, xpagesSortStartIndex, xpagesSortStopIndex);

                // 调整scene顺序
                if(xpagesSortStopIndex == xpagesSortStartIndex){
                    return false;
                }else if(xpagesSortStopIndex > xpagesSortStartIndex){
                    scenes.eq(xpagesSortStopIndex).after(scenes.eq(xpagesSortStartIndex));
                }else{
                    scenes.eq(xpagesSortStopIndex).before(scenes.eq(xpagesSortStartIndex));
                }

                // 如果当前页改变位置，则更新当前索引
                (sceneActiveIndex != xpagesCurr) && (xpagesCurr = sceneActiveIndex);
            }
        });

/* ============================== 操作页面end ==================================== */



/* ============================== 页面属性操作start ==================================== */

// 公共处理的事情
$(xsceneSettingListClass).on('click', xsceneSettingItemClass, function(e){
    $(xelemActiveClass).removeClass(xelemActiveClassName);
});

// 页面基本设置
$(xsceneSettingListClass).on('click', xsceneSettingBgClass, function(e){
    if($(xsceneClass).length){
        resetSceneSettingButton();
        $(this).addClass('active');

        createPanelWithElement( $(xsceneClass).eq(xpagesCurr) );
    }
});

// 页面模板
$(xsceneSettingListClass).on('click', xsceneSettingTplClass, function(e){
    if($(xsceneClass).length){
        resetSceneSettingButton();
        $(this).addClass('active');

        // 创建面板
        var tabMains = createTabPanel(['封面', '图集', '图文']);

        // tabMains.eq(0).html('<p style="text-align: center; padding: 60px 0px; font-size: 24px;">即将上线，敬请期待！</p>')

        // 展示模板列表
        tabMains.each(function(i){
            var self = $(this),
                list = xsceneTplList[i],
                listWp = '<div class="xpanel-main-wp">{{tplList}}</div>',
                listHtml = '';

            $.each(list, function(j, obj){
                listHtml += xsceneTplHtml.replace('{{tplImg}}', obj.img)
                                         .replace('{{tplName}}', obj.name)
                                         .replace('{{tplType}}', i)
                                         .replace('{{tplOrder}}', j);

            });

            listWp = listWp.replace('{{tplList}}', listHtml);

            self.append(listWp);
            self.find('.xpanel-main-wp').css({height: 480, overflow: 'hidden'}).slimScroll({ height: 480 });
        });

        // 高亮当前页应用的模板
        $('.xpanel-tpl-show', xpanel).each(function(){
            var self = $(this),
                indexType = parseInt( self.attr('data-type') ),
                indexOrder = parseInt( self.attr('data-order') ),
                tplConfig = xsceneTplData[indexType][indexOrder];

            if(xsceneDesp[xpagesCurr].tplid == tplConfig.tplid){
                $('.xpanel-tpl-show').removeClass('active');
                self.addClass('active');

                return false;
            }
        });

        // 显示当前模板分类
        var currTabIndex = 0,
            currTplItem = $('.xpanel-tpl-show.active', xpanel);
        if(currTplItem.length){
            currTabIndex = parseInt(currTplItem.attr('data-type'));
        }
        $(xpanelHeadItemClass, xpanel).eq(currTabIndex).trigger('click');
    }
});

// 模板渲染
xpanel.on('click', '.xpanel-tpl-show', function(){
    var self = $(this);

    $.xmodal({
        msg: '选择页面模板会替换掉原页面的素材，是否继续？',
        btns: ['继续', '取消'],
        fnBtns: [function(){

            var indexType = parseInt( self.attr('data-type') ),
                indexOrder = parseInt( self.attr('data-order') ),
                currScene = $(xsceneClass).eq(xpagesCurr).empty(),
                tplConfig = xsceneTplData[indexType][indexOrder],
                elemsConfig = tplConfig.elems,
                elemsConfigLen = elemsConfig.length;

            // 更新配置对象
            tplConfig.name = xsceneDesp[xpagesCurr].name;
            xsceneDesp[xpagesCurr] = $.extend(true, {}, tplConfig);

            // 在列表模板中高亮选中模板
            $('.xpanel-tpl-show').removeClass('active');
            self.addClass('active');

            // 格式化页面
            formatStyle(currScene, ['elems', 'name', 'tplid'], tplConfig);

            // 将模板中的元素填充到当前页
            for(var j = 0; j < elemsConfigLen; j++){
                var elem = elemsConfig[j],
                    elemType = elem.type,
                    elemPorps = elem.props,
                    elemObj = $('<div class="xcursor-move xscene-elem"><div class="xscene-elem-wrapp"></div><div class="xscene-elem-border"></div><div class="xscene-elem-close xcursor-pointer">×</div></div>').appendTo(currScene).addClass("xscene-" + elemType).attr('data-elemtype', elemType),
                    elemWrappObj = elemObj.find(".xscene-elem-wrapp");
                formatStyle(elemObj, [], elemPorps);
            }

            // 设置拖拽
            currScene.find(xelemClass).each(function(){
                setDraggable($(this), currScene);
            });

            // 播放动画
            playAnimation(currScene);

        }, null]
    });

});

// 二维码
$(xsceneSettingListClass).on('click', xsceneSettingQrcodeClass, function(e){
    resetSceneSettingButton();
    $(this).addClass('active');

    var tabMain = createTabPanel(['二维码预览']).eq(0),
        controlTplLink = '<div class="xclearfix xpanel-control">\
                            <div class="xpanel-control-name">预览地址</div>\
                            <div class="xclearfix xpanel-control-entity">\
                                <div class="xclearfix xpanel-text">\
                                    <input type="text" class=" xradius xpanel-border xpanel-text-input" value="" ></div>\
                            </div>\
                        </div>',
        controlTplQrcode = '<div class="xclearfix xpanel-control">\
                            <div class="xpanel-control-name">二维码</div>\
                            <div class="xclearfix xpanel-control-entity">\
                                <div class="xpanel-imgup"></div>\
                            </div>\
                        </div>',
        controlLink = $(controlTplLink),
        controlQrcode = $(controlTplQrcode),
        previewLink = xconfig.xscenePreviewUrl || 'http://www.winwemedia.com';

    controlLink.find('.xpanel-text-input').val(previewLink);
    controlQrcode.find('.xpanel-imgup').qrcode({
        width: 170,
        height: 170,
        text: previewLink
    });

    tabMain.append(controlLink, controlQrcode)

    $(xpanelHeadItemClass, xpanel).eq(0).trigger('click');
});

function createTabPanel(nameArr){
    // 定义操作tab的相关对象
    var tab = $(xpanelTabTpl).appendTo(xpanel),
        tabHeadList = tab.find(xpanelHeadListClass);

        $.each(nameArr, function(key, value){
            $(xpanelTabHeadTpl).appendTo(tabHeadList).text(value);
            $(xpanelTabMainTpl).appendTo(tab);
        });

        return tab.find(xpanelMainClass);
}

// 播放动画
function playAnimation(currScene){
    currScene.find(xelemClass).each(function(){
        var self = $(this),
            selfAnimationName = self.css('animationName'),
            selfAnimationDelay = parseFloat( self.css('animationDelay') ),
            selfAnimationDuration = parseFloat( self.css('animationDuration') ),
            selfAnimationTotalTime = selfAnimationDelay + selfAnimationDuration,
            noAnimation = self.css('animationName') == 'none';

        if(!noAnimation){
            self.css('opacity', 0).css('animationName', 'none');
            setTimeout(function(){
                self.css('animationName', selfAnimationName);
            }, 0);

            setTimeout(function(){
                self.css('opacity', 1);
            }, selfAnimationTotalTime * 1000)
        }
    });
}


/* ============================== 页面属性操作end ==================================== */








/* ============================== 控制面板切换start ==================================== */
    xpanel.on('click', xpanelHeadItemClass, function(e){
        var index = $(this).index();
        $(xpanelHeadItemClass).removeClass('active').eq(index).addClass('active');
        $(xpanelMainClass).hide().eq(index).show();
    });
/* ============================== 控制面板切换end ==================================== */







/* ============================== 操作元素start ==================================== */

    // 绑定元素的删除功能
    xsceneView
        // 绑定元素的删除功能
        .on('click.deleteElem', xelemDeleteClass, function(e){
            e.stopPropagation();

            var self = $(this).closest(xelemClass),
                index = self.index();

            $.xmodal({
                msg: '确定删当前元素吗？',
                btns: ['确定', '取消'],
                fnBtns: [function(){
                    // 删除dom元素
                    self.remove();

                    // 删除配置对象中的元素对象
                    xsceneDesp[xpagesCurr].elems.splice(index, 1);

                    // 如果页面面板存在，则删除
                    if(!isSettingPanelExist){
                        $(xpanelTabClass).remove();
                        isSettingPanelExist = false;
                    }
                }, null]
            });

        })
        // 绑定元素的激活功能
        .on('click.setElemActive', xelemClass, function(e){
            var self = $(this),
                isCurrElem = self.hasClass(xelemActiveClassName);

            // 激活的元素不用重复激活，如果页面面板存在，即使处于激活状态也需要重新激活以生成控制面板
            if( !isCurrElem || (isCurrElem && isSettingPanelExist===true) ){
                $(xelemClass).removeClass(xelemActiveClassName);
                self.addClass(xelemActiveClassName);
                // 生成元素对应的控制面板
                resetSceneSettingButton();
                createPanelWithElement(self);
            }

        });

    createScene();

    // 拖拽——draggable(widgets)
    xwidgets.draggable({
        // stack: xwidgetsClass,
        appendTo: xwidgetsHelperWrapp,
        revert: 'invalid',
        revertDuration: 400,
        helper: function(){
            return createHelperByDraggable($(this));
        }
    });

    // 初始化已经存在元素的droppable
    $(xsceneClass).each(function(){
        var currScene = $(this);
        setDroppable(currScene);

        $(this).find('.xscene-elem').each(function(){
            var currElem = $(this);
            setDraggable(currElem, currScene);
        });

    });

    // 关闭窗口时提醒用户保存数据
    window.onbeforeunload = function(e){
        var e = e || event;

        e.returnValue = '现在离开您的数据将会丢失，确认离开吗？';
    }

/* ============================== 操作元素end ==================================== */
    // 【注】目前只有部分属性可用于scene（后期需要可以在该函数自行扩展，目前只适用于css, attr, cssBgImage, 其他的属性需要根据具体的对象去扩展，跟control的使用范围对应）
    // withCurrConfig为布尔值，说明元素用当前的配置对象渲染还是模板配置渲染
    function formatElemWith(currElem, excludeArray, withCurrConfig){
        var elemType = currElem.data('elemtype'),
            excludeArray = excludeArray || [],
            mapAction = xsceneDespTpl.mapAction,
            mapUnit = xsceneDespTpl.mapUnit,
            isScene = currElem.hasClass(xsceneClassName),
            props, currElemWrapp;

        if(isScene){  //当前元素是scene
            if(withCurrConfig){
                props = xsceneDesp[currElem.index()];
            }else{
                props = xsceneDespTpl['scene'];
            }
        }else{  //当前元素是elem
            if(withCurrConfig){
                props = xsceneDespTpl[currElem.closest(xsceneClass).index()].elems[currElem.index()];
            }else{
                props = xsceneDespTpl[elemType].props;
            }
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
                }
            }

        });
    }

    // withCurrConfig为布尔值，说明元素用当前的配置对象渲染还是模板配置渲染
    // function formatElemWith(currElem, excludeArray, withCurrConfig)
    function formatStyle(currElem, excludeArray, props){
        var mapAction = xsceneDespTpl.mapAction,
            mapUnit = xsceneDespTpl.mapUnit,
            excludeArray = excludeArray || [],
            isScene = currElem.hasClass('xscene-scene'),
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

    // create scenes
    function createScene(){
        var scenes = xsceneDesp,
            scenesLen = scenes.length,
            i = 0;

        if(scenesLen > 0){
            // create scene
            for(i = 0; i < scenesLen; i++){
                var scene = scenes[i];
                    elems = scene.elems,
                    elemsLen = elems.length,
                    sceneObj = $('<div class="xscene-scene"></div>').appendTo(xsceneView),
                    j = 0,
                    currPageHtml = $(xpagesTpl.replace("{{pagesNumber}}", scene.name)),
                    isTplidInSceneConfig = 'tplid' in scene;

                // 3.0.0版本场景的页面属性中没有tplid字段，做一个兼容处理，如果没有，就添加tplid为none
                if(!isTplidInSceneConfig){
                    scene.tplid = 'none';
                }

                formatStyle(sceneObj, ['elems', 'name', 'tplid'], scene);
                sceneObj.css({ transition: 'none', transform: 'translateY(' + xsceneViewHeight + 'px)' });
                $('.xpage-list').append(currPageHtml);

                // create elements
                for(j = 0; j < elemsLen; j++){
                    var elem = elems[j],
                        elemType = elem.type,
                        elemPorps = elem.props,
                        elemObj = $('<div class="xcursor-move xscene-elem"><div class="xscene-elem-wrapp"></div><div class="xscene-elem-border"></div><div class="xscene-elem-close xcursor-pointer">×</div></div>').appendTo(sceneObj).addClass("xscene-" + elemType).attr('data-elemtype', elemType),
                        elemWrappObj = elemObj.find(".xscene-elem-wrapp");

                    formatStyle(elemObj, [], elemPorps);
                }

            }

            xpagesLen = i;
            $(xpagesClass).eq(i-1).trigger('click');
        }else{
            $(xpageAddClass).trigger('click');
        }


    }

    // 给scene设置droppable
    function setDroppable(currScene){
        currScene.droppable({
            accept: xwidgetsClass,
            tolerance: 'fit',
            activeClass: droppableActiveClassName,
            hoverClass: droppableHoverClassName,
            over: function(e, ui){
                // 将helper变为当前元素的样式
                // changeHelperToElem(ui);
            },
            out: function(e, ui){
                // 将元素变为widget的样式
                // changeElemToHelper(ui);
            },
            drop: function(e, ui){
                // 通过当前draggable生成一个能够在scene范围内拖拽的元素，并自动生成对应的控制面板
                changeHelperToElem(ui);
                createElementByDraggable(ui);
            }
        });
    };

    function setDraggable(currElem, currScene){
        currElem.draggable({
            containment: currScene,
            stop: function(e, ui){
                // 更新配置对象中的对象位置
                var currElemIndex = currElem.index(),
                    props = xsceneDesp[xpagesCurr].elems[currElemIndex].props;

                props.left = ui.position.left;
                props.top = ui.position.top;

                currElem.trigger('click.setElemActive');
            }
        })
    }

    // 合成对应当前draggable元素的子元素和classes
    function generateElemClassesAndChildren(draggableIndex){
        var currElemDefault = xelemDefault[draggableIndex];

        return {
            typeClass: xelemClassesBase.replace('{{elemTypeClass}}', currElemDefault.typeClass),
            elemChildren: xelemChildrenPublic.replace('{{elemChildren}}', currElemDefault.elemChildren),
            elemType: currElemDefault.elemType
        };
    }

    // 把当前拖拽helper变成对应的元素显示
    function changeHelperToElem(ui){
        var draggableIndex = xwidgets.index(ui.draggable),
            elemData = generateElemClassesAndChildren(draggableIndex);

        ui.helper.attr({'class': elemData.typeClass, 'data-elemtype': elemData.elemType}).html(elemData.elemChildren);
        // 格式化元素
        formatElemWith(ui.helper, ['left', 'top'], false);
    }

    // 把拖拽的元素变成控件的样子
    function changeElemToHelper(ui){
        var draggable = ui.draggable,
            helper = ui.helper,
            helperLeft = helper.css('left'),
            helperTop = helper.css('top');

        ui.helper
            .removeAttr('style')
            .css({
                left: helperLeft,
                top: helperTop
            })
            .attr('class', draggable.attr('class'))
            .html(draggable.html());
    }

    // 通过draggable生成helper
    function createHelperByDraggable(draggable){
        var currElem = $("<div></div>");

        return currElem.attr('class', draggable.attr('class')).html(draggable.html());
    }

    // 通过draggable生成element, 添加到scene并绑定拖拽事件，绑定控制面板等操作
    function createElementByDraggable(ui){
        var currScene = $(xsceneClass).eq(xpagesCurr),
            currElem = ui.helper.clone().appendTo(currScene),
            currElemOffset = ui.offset,
            sceneViewOffset = xsceneView.offset(),
            elemType = currElem.data('elemtype'),
            props,
            newCurrElemLeft = currElemOffset.left - sceneViewOffset.left,
            newCurrElemTop = currElemOffset.top - sceneViewOffset.top;

        // 添加对应的元素对象到配置对象中
        xsceneDesp[xpagesCurr].elems.push($.extend(true, {}, xsceneDespTpl[elemType]));  // 注意配置对象的修改时机
        // 获取当前对象的配置对象
        props = xsceneDesp[xpagesCurr].elems[currElem.index()].props;
        // 更新元素的left和top
        currElem.css({ left: newCurrElemLeft, top: newCurrElemTop });
        props.left = newCurrElemLeft;
        props.top = newCurrElemTop;

        // 如果放置在scene里面的elem溢出了scene，则做矫正
        dealWithOverflow(currElem, props);

        // 给新添加的元素添加拖拽行为, 并生成对应的控制面板
        setDraggable(currElem, currScene);
        currElem.trigger('click.setElemActive');

    }

    // 通过元素生成对应的控制面板，并绑定操作以更新元素以及配置对象
    // 会把面板的值更新到元素上，所以每次生成面板都会更新一次元素的属性值和对应的配置对象
    // 【注】这个函数可以将控制面板用于elem和scene，函数会自行判断传进去对象的类别
    // 【注】只有部分control可用于scene（后期需要可以在该函数自行扩展，目前只适用于color, slider, imgup, select这些control, 其他的control需要根据具体的对象赋值）
    function createPanelWithElement(currElem){

        // 定义操作tab的相关对象
        var tab, tabHeadList, tabMain = null;

        var isScene = currElem.hasClass(xsceneClassName), // 判断传进来的对象是否是scene
            currElemIndex, currScene, elemType, currElemWrapp, // 如果元素是elem，需要用到的变量
            props, controlGroup; // 不管元素是scene还是elem都会获取配置对象和控制面板配置

        if(isScene){  //当前元素是scene
            // 获取elem对应的配置对象，以便初始化和设置控件的值
            props = xsceneDesp[xpagesCurr];
            // 获取当前元素对应的控制面板配置
            controlGroup = xpanelsControlsDefined['scene'];
            // 将页面控制面板存在的状态设置为true
            isSettingPanelExist = true;
        }else{  //当前元素是elem
            // 获取elem对应的配置对象，以便初始化和设置控件的值
            currElemIndex = currElem.index();
            currScene = $(xsceneClass).eq(xpagesCurr);
            props = xsceneDesp[xpagesCurr].elems[currElemIndex].props;
            // 获取当前元素对应的控制面板配置
            elemType = currElem.data('elemtype'); // 获取当前元素类型
            controlGroup = xpanelsControlsDefined[elemType]; // 根据当前元素的类型获取对应的控制面板配置对象
            currElemWrapp = $('.xscene-elem-wrapp', currElem);
            // 将页面控制面板存在的状态设置为false
            isSettingPanelExist = false;
        }

        // 干掉当前的control panel
        $(xpanelTabClass).remove();

        // 重新生成一个空的control panel
        tab = $(xpanelTabTpl).appendTo(xpanel);
        tabHeadList = tab.find(xpanelHeadListClass);

        // 用获取的控制面板配置结合配置对象生成控件
        $.each(controlGroup, function(key, controlObj){
            var controlDefaultVal, controlDefaultValBake, // 控件默认值，控件默认值备份
                controlType = controlObj.type, // 控件类型
                hasAttrOrCss = (controlObj.css || controlObj.attr), // 控件对象是否有attr或者css属性
                setAttrOrCss = hasAttrOrCss ? (controlObj.css ? 'css' : 'attr') : 'noAttrOrCss', // 如果有attr或者css则获取对应操作方法（attr/css）
                controlHtml = xpanelsControls[controlType].replace('{{controlName}}', controlObj.name), // 根据控件类型获取对应的控件模板
                control = $(controlHtml); // 实例化模板为jQuery对象

            // 碰到控件分页标识则生成一个tabHead头和tabMain
            if(controlObj.tabDivision >= 0){
                tabHead = $(xpanelTabHeadTpl).appendTo(tabHeadList).text(controlObj.tabName);
                tabMain = $(xpanelTabMainTpl).appendTo(tab);
            }

            // 添加control到当前的tabMain
            tabMain.append(control);

            // 判断不同的控件类型设置默认值
            if(hasAttrOrCss){
                controlDefaultVal = props[ controlObj[setAttrOrCss] ];
            }else{
                if(controlType === 'editor' && controlObj.action === 'setHtml'){
                    controlDefaultVal = props['html'];
                }else if(controlType === 'text' && controlObj.action === 'setText'){
                    controlDefaultVal = props['text'];
                }else if(controlType === 'btns'){
                    controlDefaultVal = props['addClass'];
                }
            }

            //保存一个默认值的备份，后面需要用到判断
            controlDefaultValBake = controlDefaultVal;

            // 给带有controlled属性的currElem添加对应的class,方便select操作对应的控件
            if(controlObj.controlled) control.addClass(controlObj.controlled);
            if(controlObj.control) control.addClass('control');

            // 针对每个control的特性实例化
            if(controlType === 'editor'){
                var editorDespDefault = xsceneDespTpl.txt.props.html;

                // 销毁已经实例化的编辑器
                if(editorLivingGlobal){
                    editorLivingGlobal.destroy();
                    editorLivingGlobal = null;
                }

                // 实例化编辑器
                var editorLiving = editorLivingGlobal = UE.getEditor('xpanel-editor', {
                        toolbars: ue_type.mini.toolbars,
                        initialFrameHeight: 130
                    }),
                    editorSync = function(){  // 同步编辑器内容那个到元素和配置对象
                        if(controlObj.action === 'setHtml'){
                            currElemWrapp.html(editorLiving.getContent()); // 同步内容到元素
                            props.html = editorLiving.getContent(); // 修改配置对象
                        }
                    };

                // 监听ready事件，初始化编辑器内容
                editorLiving.addListener('ready', function(editor) {
                    var text = editorLiving.getContentTxt();
                    if(text == ""){
                        editorLiving.setContent(controlDefaultVal);
                    }
                });
                // 监听focus和blur显示提示文字
                editorLiving.addListener('focus', function(editor){
                    var text = editorLiving.getContentTxt();
                    if(text == editorDespDefault){
                        editorLiving.setContent("");
                        editorSync();
                    }
                });
                editorLiving.addListener('blur', function(editor){
                    var text = editorLiving.getContentTxt();
                    if(text == ""){
                        editorLiving.setContent(editorDespDefault);
                        editorSync();
                    }
                });
                // 实时同步编辑器中的内容
                editorLiving.addListener('contentChange', function(editor){
                    var text = editorLiving.getContentTxt();
                    if(text != editorDespDefault){
                        editorSync();
                    }
                });

                // 给编辑器设置背景颜色
                // editorLivingGlobal.execCommand('background', {
                //     "background-color": 'rgba(0, 0, 0, 0.5)'
                // });

            }
            else if(controlType === 'zindex'){
                control
                    .on('click', '.xpanel-zindex-first', function(e){
                        xutils.moveElemInArray(xsceneDesp[xpagesCurr].elems, currElem.index(), xsceneDesp[xpagesCurr].elems.length-1);
                        currElem.appendTo(currScene);
                    })
                    .on('click', '.xpanel-zindex-last', function(e){
                        xutils.moveElemInArray(xsceneDesp[xpagesCurr].elems, currElem.index(), 0);
                        currElem.prependTo(currScene);
                    })
                    .on('click', '.xpanel-zindex-prev', function(e){
                        // 在配置对象中，把元素在数组中的位置向后挪一位
                        xutils.downElemInArray(xsceneDesp[xpagesCurr].elems, currElem.index());
                        currElem.next().after(currElem);
                    })
                    .on('click', '.xpanel-zindex-next', function(e){
                        // 在配置对象中，把元素在数组中的位置向前挪一位
                        xutils.upElemInArray(xsceneDesp[xpagesCurr].elems, currElem.index());
                        currElem.prev().before(currElem);
                    });
            }
            else if(controlType === 'color'){
                var colorShow = $('.xpanel-color-show', control),
                    colorBtn = $('.xpanel-color-button', control),
                    colorSync = function(rgba){
                        currElem.css(controlObj.css, rgba);
                        props[controlObj.css] = rgba;
                    };

                // 隐藏页面设置中背景色颜色选择器的‘设为透明’按钮
                if(isScene && controlObj.css === 'backgroundColor'){
                    control.addClass('xpanel-color-button-hide');
                }

                // 实例化colorpicker
                colorShow
                    // 设置color-control中颜色选择器设置data-color属性，为下面实例化colorpicker做准备
                    // .attr('data-color', controlDefaultVal)
                    .attr('data-color', 'rgba(255, 0, 0, 1)')
                    // 实例化colorpicker，并设定格式为rgba
                    .colorpicker({
                        format: "rgba"
                    })
                    // 绑定changeColor事件，当colorpicker的颜色变化的时候同步设置元素的颜色值
                    .on("changeColor", function(e) {
                        var self = $(this);
                        var objRGBA = e.color.toRGB();
                        var rgba = xutils.color.colorObjToRGBA(objRGBA);

                        self.css({ "background-color": rgba });

                        colorSync(rgba);
                    })
                    .css({ "background-color": controlDefaultVal });

                // 清除颜色（设置颜色为透明）
                colorBtn.on('click', function(){
                    // 调用colorpicker的setValue方法会触发changeColor
                    colorShow.colorpicker('setValue', 'rgba(255, 255, 255, 0)');
                })

            }
            else if(controlType === 'slider'){
                var sliderSilder = $('.xpanel-slider', control);

                // slider一般操作类型为数值的css属性，所以在这里转换成数字
                controlDefaultVal = parseFloat(controlDefaultVal);

                if(controlObj.css === 'opacity'){ // 透明度需要被转化成百分比，不管是不是初始化新面板都需要转化
                    controlDefaultVal = Math.round(controlDefaultVal * 100);
                }

                sliderSilder.slider({
                    min: controlObj.min,
                    max: controlObj.max,
                    step: controlObj.step,
                    range: 'min',
                    orientation: 'horizonal',
                    value: controlDefaultVal,
                    slide: function(e, ui){
                        setElemBySlider(ui.value, currElem, controlObj, sliderSilder, props, true, isScene);
                    },
                    change: function(e, ui){
                        setElemBySlider(ui.value, currElem, controlObj, sliderSilder, props, true, isScene);
                    }
                });

                // 初始化slider的文字显示
                setElemBySlider(controlDefaultVal, currElem, controlObj, sliderSilder, props, false, isScene);

            }
            else if(controlType === 'imgup'){
                var imgupImg = $('.xpanel-imgup-img', control),
                    imgupInput = $('.xpanel-imgup-input', control),
                    imgupPercent = $('.xpanel-imgup-percent', control),
                    imgupDelete = $('.xpanel-imgup-delete', control),
                    imgupElemImg = $('.xscene-img-img', currElem),
                    imgupSet = controlObj.attr ? 'attr' : 'css',  // 图片上传组件一般用于图片src和背景图片
                    imgupSetValue = controlObj[imgupSet],
                    imgupDefaultSrc = xsceneDespTpl.img.props.src,
                    imgupSync = function(src){
                        var newSrc = src;

                        // 如果是设置背景图片
                        if(imgupSet === 'css' && imgupSetValue === 'backgroundImage'){
                            imgupElemImg = currElem; // 如果是设置背景图片，就在元素自身设置，不找到它下面的img元素进行设置
                            if(src == 'none' || !src){
                                newSrc = 'none'
                            }else{
                                newSrc = 'url(' + src + ')'; // 如果是背景图片就转换成url函数的格式
                            }
                        }
                        imgupElemImg[imgupSet](imgupSetValue, newSrc);
                        props[imgupSetValue] = src;
                        imgupSetDeleteBtn();

                        // 处理上传图片后，图片超出scene的情况
                        if(imgupSet === 'attr' && imgupSetValue === 'src'){
                            var imgupImgObj = new Image();

                            imgupImgObj.src = src;
                            if(imgupImgObj.complete){
                                dealWithOverflow(currElem, props);
                            }else{
                                imgupImgObj.onload = function(){
                                    dealWithOverflow(currElem, props);
                                };
                            }

                        }
                    },
                    imgupSetDeleteBtn = function(){  //当操控的对象是scene时，设置删除按钮
                        // console.log(props[imgupSetValue], imgupDefaultSrc, controlDefaultVal)
                        if(imgupSet === 'css' && imgupSetValue === 'backgroundImage'){
                            if( (props[imgupSetValue] != imgupDefaultSrc) && (props[imgupSetValue] != 'none') ){
                                imgupDelete.show();
                            }else{
                                imgupDelete.hide();
                            }
                        }
                    };

                // 单击图片选择上传
                if(controlDefaultVal === 'none')  controlDefaultVal = imgupDefaultSrc;
                imgupImg
                    .attr('src', controlDefaultVal)
                    .click(function(e){
                        imgupInput.val(''); //避免删除当前图片后，再次上传相同的图片不触发change事件
                        imgupInput.trigger('click');
                    });

                // 如果是背景图就设置删除按钮
                imgupSetDeleteBtn();

                // 绑定删除按钮事件
                imgupDelete.click(function(){
                    imgupImg.attr('src', imgupDefaultSrc);
                    imgupSync('none');
                });

                imgupInput.qiniuUploadImg({
                    multiple: false,
                    token: "iW__QVfOTEwmOLuRSe9FompemjFlg3fBtw3wUxiu:SWR93nV4H3nqWG-hgGQm-e1AiFw=:eyJzY29wZSI6InZjbC1waWN0dXJlcyIsImRlYWRsaW5lIjoxNzM1MDA4NjM3fQ==",
                    bucket: "vcl-pictures",
                    fnUploadInit: function(fileInput, fileCount, index, file){
                        imgupPercent.stop(true, false).fadeIn(400);
                    },
                    fnUploadProgress: function(fileInput, fileCount, index, percent, e){
                        imgupPercent.text(percent + '%');
                    },
                    fnUploadComplete: function(fileInput, fileCount, index, src){
                        imgupPercent.stop(true, false).fadeOut(400);
                        imgupImg.attr('src', src);
                        // 同步更新元素图片和配置对象
                        imgupSync(src);
                    }
                });

            }
            else if(controlType === 'text'){
                var textInput = $('.xpanel-text-input', control),
                    textSet = controlObj.attr ? 'attr' : 'css', //type=text的control会另外判断
                    textSetTextDefault = xsceneDespTpl.btn.props.text,
                    textSync = function(val){
                        if(controlObj.action === 'setText'){ // 除了编辑按钮里面的文本，其他都是设置属性，如果还有其他类型，可以在if语句里面扩展
                            currElemWrapp.text(val);
                            props.text = val;
                        }else{
                            // 设置data-link-(sys/http/tel)
                            currElem[textSet](controlObj[textSet], val);
                            props[controlObj[textSet]] = val;
                            // 设置data-link
                            if(controlObj.action === 'setHttp'){
                                currElem.attr('data-href', val);
                                props['data-href'] = val;
                            }else if(controlObj.action === 'setTel'){
                                currElem.attr('data-href', 'tel://' + val);
                                props['data-href'] = 'tel://' + val;
                            }
                        }
                    };

                // 初始化control的值
                textInput.val(controlDefaultVal);

                textInput.attr('placeholder', controlObj.placeholder).val(controlDefaultVal)

                if(controlObj.action === 'setText'){
                    textInput
                        .on('focus', function(){
                            if($(this).val() === textSetTextDefault)
                               $(this).val('');
                        })
                        .on('blur', function(){
                            if($(this).val() === ''){
                               $(this).val(textSetTextDefault);
                               textSync(textSetTextDefault);
                            }
                        })
                }

                textInput
                    .on('input', function(){
                        var val = $(this).val();
                        textSync(val);
                    });

            }
            else if(controlType === 'btns'){

                var btnsStyleArray = ['xscene-btn1', 'xscene-btn2', 'xscene-btn3', 'xscene-btn4', 'xscene-btn5', 'xscene-btn6', 'xscene-btn7', 'xscene-btn8'];
                var btnsStyleRemove = btnsStyleArray.join(' ');

                $('.xpanel-btn', control)
                    .on('click', function(){
                        currElem.removeClass(btnsStyleRemove).addClass( 'xscene-btn' + ($(this).index() + 1) );
                        props.addClass = 'xscene-btn' + ($(this).index() + 1);
                    });

            }
            else if(controlType === 'select'){

                var selectSelect = $(controlObj.structure),
                    selectType = controlObj.selectType,
                    selectSet = controlObj.attr ? 'attr' : 'css', // select只会设置css或者attr
                    selectSync = function(val){
                        currElem[selectSet](controlObj[selectSet], val);
                        props[controlObj[selectSet]] = val;

                        // 设置data-link
                        if(controlObj.action === 'setSys'){
                            currElem.attr('data-href', val);
                            props['data-href'] = val;
                        }
                    }

                $('.xpanel-select', control).append(selectSelect);

                // 初始化select的值
                selectSelect.find('option').each(function(i){
                    if(controlDefaultVal == $(this).val())
                        $(this).prop('selected', true);
                });

                selectSelect.change(function(e){
                    var self = $(this),
                        val = self.val();

                    if(selectType === 0){
                    }else if(selectType === 1 && controlObj.control){
                        if(val === 'none'){
                            $('.' + controlObj.control).hide();
                        }else{
                            $('.' + controlObj.control).show();
                        }
                    }else if(selectType === 2 && controlObj.control){
                        if(val === 'none'){
                            $('.' + controlObj.control).hide();
                        }else{
                            $('.' + controlObj.control).hide();
                            // 二级选项一般是多个control操作一个attr/css，所以，每次切换到二级选项的时候，要把当前想更新到元素及配置对象上去
                            $('.' + controlObj.control + '-' + val).show().find('input').trigger('input');
                            $('.' + controlObj.control + '-' + val).find('select').trigger('change');
                        }
                    }else if(selectType === 3 && controlObj.control){
                        // 比较复杂的操作需要根据需求单独定义
                    }

                    selectSync(val);
                });

                // 初始化currElem以及配置对象的值
                // 错误，因为在这控制级的select实例化的时候，它后面的control可能还没有实例化，所以这个时候trigger无效，因此要等整个面板生成完，再一次性trigger
                // selectSelect.trigger('change');

            }
            else if(controlType === 'four'){
                var fourInputs = $('.xpanel-four-txt', control),
                    fourMap = ['paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft'],
                    fourSync = function(val, attrName){
                        currElem.css(attrName, val);
                        props[attrName] = val;

                        dealWithOverflow(currElem, props);
                    };

                fourInputs.each(function(i){
                    var self = $(this),
                        keyDownTimer;

                    self.val( props[fourMap[i]] );
                    self.on('input', function(){
                        var val = parseInt( $(this).val() ),
                            val = isNaN(val) ? 0 : val,
                            val = (val < 0) ? 0 : val;

                        self.val(val);
                        fourSync(val, fourMap[i]);
                    }).on('keydown', function(e){
                        var self = $(this),
                            val = parseInt( self.val() ),
                            keycode = e.which;

                        if(keycode == 38 || keycode == 39){
                            val++;
                        }else if(keycode == 37 || keycode == 40){
                            val--;
                        }
                        self.val(val)
                        self.triggerHandler('input');

                    });
                });
            }else if(controlType == 'link'){
                var textInput = $('.xpanel-text-input', control);
                textInput.attr('placeholder', controlObj.placeholder).val(controlDefaultVal)
                textInput
                    .on('input', function(){
                        var val = $(this).val();
                        currElem.attr('data-video', val);
                        props['data-video'] = val;
                    });
            }
        });

        // 更新select控制的其他control的显示
        xpanel.find('.control select').trigger('change');

        // 切换tab到第一个
        $(xpanelHeadItemClass).eq(0).trigger('click');
    }

    function setElemBySlider(value, currElem, controlObj, slider, props, isSyncElem, isScene){
        var cssSetToElem = value;

        // 显示slider的值
        slider.next('.xpanel-slider-val').text(value + controlObj.unit);

        // 如果传参isSyncElem为false，就在这里退出，在初始化面板的时候用到，操作控制面板的组件的时候就需要同步更新元素和配置对象那个了
        if(!isSyncElem) return false;

        // 将slider的value转换成css属性值
        if(controlObj.css === 'opacity'){ // 如果是设置opacity属性，则把数值除以100作为css属性值
            cssSetToElem = cssSetToElem/100;
        }else{ // 如果是其他的css属性，则直接加上对应的单位
            cssSetToElem = cssSetToElem + controlObj.unit;
        }

        // 设置css属性，并修改配置对象
        currElem.css(controlObj.css, cssSetToElem);
        props[controlObj.css] = parseFloat(cssSetToElem);

        // 用来处理当改变元素宽高的时候超出scene边界的情况
        if(!isScene && ( controlObj.css === 'width' || controlObj.css === 'height' ) ){
            dealWithOverflow(currElem, props);
        }

        // 用来处理xscene-elem-border的更新跟不上borde-width变化的问题
        if(!isScene && ( controlObj.css === 'borderWidth' ) ){
            currElem.css({ height: '+=1px' });
            currElem.css({ height: '-=1px' });
            // 超出边界情况
            dealWithOverflow(currElem, props);
        }

    }

    // 用来处理当改变elem宽高的时候超出scene边界的情况
    function dealWithOverflow(currElem, props){
        var overflowX = xsceneViewWidth - (currElem.outerWidth() + props.left),
            overflowY = xsceneViewHeight - (currElem.outerHeight() + props.top);

        if (overflowX < 0){
            currElem.css('left', props.left + overflowX);
            props.left = props.left + overflowX;
        }
        if (overflowY < 0){
            currElem.css('top', props.top + overflowY);
            props.top = props.top + overflowY;
        }
    }

    function resetSceneSettingButton(){
        xsceneSettingItems.removeClass('active');
        $(xpanelTabClass).remove();
    }

});

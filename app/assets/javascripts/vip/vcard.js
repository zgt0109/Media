/**
 * @author frey
 * @date 2015/05/14
 */

$(function(){

    var data = window.vcardData,
        cardListInfo = data.cardList,
        cardLevelStyle = data.cardLevel,
        cardNumberStyle = data.cardNumber,
        cardLogoStyle = data.cardLogo;

    var cardMain = $('.vcard-card-main'),
        cardMainLevel = $('.vcard-level', cardMain),
        cardMainLogo = $('.vcard-logo', cardMain),
        cardMainNumber = $('.vcard-number', cardMain),
        cardList = $('.vcard-list-type'),
        cardListItems = null;

    var cardTplCollection = window.vcardTplCollection,
        cardTplTpl = window.vcardTplHtml,
        cardTplList =  window.vcardTplList;

    

    // 生成card list
    function createListCards(){
        var cardListHtml = '';

        if(cardListInfo.length > 1){
            $.each(cardListInfo, function(cardIndex, cardInfo){
                if(cardIndex > 0){
                    cardListHtml += cardTplList.replace(/{{cardLevel}}/, cardInfo.level);
                }
            });

            cardList.html(cardListHtml);
            cardListItems = $('.vcard-card', cardList);
        }
    }

    // 格式化单个会员卡
    function formatSingleCard(card, cardInfo){
        var cardLevel = $('.vcard-level', card),
            cardLogo = $('.vcard-logo', card),
            cardNumber = $('.vcard-number', card);

        card.css({'backgroundImage': 'url('+ cardInfo.cardBg +')'});
        cardLevel.html(cardInfo.level).css({ 'fontSize': cardLevelStyle.fontSize, 'left': cardLevelStyle.left, 'top': cardLevelStyle.top, 'color': cardInfo.cardLevelColor});
        cardNumber.html(cardInfo.number).css({ 'fontSize': cardNumberStyle.fontSize, 'left': cardNumberStyle.left, 'top': cardNumberStyle.top, 'color': cardInfo.cardNumberColor});
        cardLogo.css({ 'left': cardLogoStyle.left, 'top': cardLogoStyle.top}).find('img').attr('src', cardLogoStyle.src);
    }

    // 修正错乱样式
    function fixCardStyle(card){
        var isFirst = card.closest('.vcard-first').length ? true : false;

        card.find('.vcard-elem').each(function(){
            var cardWidth = 534,
                cardHeight = 318,
                self = $(this),
                elemWidth = self.width(),
                elemHeight = self.height(),
                elemLeft = parseInt(self.css('left')),
                elemTop = parseInt(self.css('top'));

            var operation = 'cardLevel'; // cardLevel/cardNumber/cardLogo
            if(self.hasClass('vcard-logo')){
                operation = 'cardLogo';
            }else if(self.hasClass('vcard-number')){
                operation = 'cardNumber';
            }

            if(elemWidth + elemLeft > cardWidth){
                self.css({'left': cardWidth-elemWidth-10});
                if(isFirst){
                    data[operation].left = cardWidth-elemWidth-10;
                }
            }

            if(elemHeight + elemTop > cardHeight){
                self.css({'top': cardHeight-elemHeight-10});
                if(isFirst){
                    data[operation].top = cardHeight-elemHeight-10;
                }
            }
        });
        
    }

    // 格式化所有会员卡, isSetPublic用来判断是否设置只公共样式，false为设置配置对象上的所有样式，否则只设置配置对象上的部分样式
    function formatCards(){
        $.each(cardListInfo, function(cardIndex, cardInfo){
            var card = (cardIndex === 0) ? cardMain : cardListItems.eq(cardIndex-1);
            formatSingleCard(card, cardInfo);
            fixCardStyle(card);
        });
    }

    // 初始化会员卡名称控件
    function initCardNameController(obj, controller, configObj){
        controller.val(configObj.level);

        controller.on('input', function(){
            var self = $(this),
                val = self.val();

            obj.text(val);
            configObj.level = val;
        });
    }

    function initUploadController(obj, controller, configObj, bgOrLogo){
        var fileInput = controller.next('input[type=file]'),
            fileProgress = $('<div class="vcard-progress">0%</div>').appendTo(obj).hide();

        controller.on('click', function(){
            fileInput.trigger('click');
        });

        fileInput.qiniuUploadImg({
            multiple: false,
            token: window.qiniu_token || "iW__QVfOTEwmOLuRSe9FompemjFlg3fBtw3wUxiu:SWR93nV4H3nqWG-hgGQm-e1AiFw=:eyJzY29wZSI6InZjbC1waWN0dXJlcyIsImRlYWRsaW5lIjoxNzM1MDA4NjM3fQ==",
            bucket: window.qiniu_bucket || "img-asset",
            fnUploadInit: function(fileInput, fileCount, index, file){
                fileProgress.stop(true, false).fadeIn(400);
            },
            fnUploadProgress: function(fileInput, fileCount, index, percent, e){
                fileProgress.text(percent + '%');
            },
            fnUploadComplete: function(fileInput, fileCount, index, src){
                fileProgress.stop(true, false).fadeOut(400);
                if(bgOrLogo === 'bg'){
                    obj.css('backgroundImage', 'url('+ src +')');
                    configObj.cardBg = src;
                }else if(bgOrLogo === 'logo'){
                    obj.find('img').attr('src', src);
                    cardLogoStyle['src'] = src;
                    configObj.src = src;
                    formatCards();
                }
            }
        });
    }

    // 初始化select的显示值
    function initFontSizeControllerVal(controller, configObj){
        var initFontSize = configObj.fontSize;

        controller.find('option').each(function(i){
            var self = $(this),
                val = parseInt(self.val());

            if(val == initFontSize){
                self.prop('selected', true);
            }
        });
    }

    function initFontSizeController(obj, controller, configObj){
        initFontSizeControllerVal(controller, configObj);

        controller.on('change', function(){
            var fontSize = parseInt($(this).val());

            obj.css({ fontSize: fontSize });
            configObj['fontSize'] = fontSize;

            formatCards();
        });
    }

    function initColorpicker(obj, controller, configObj, initColor, levelOrNumber){
        controller
            // 实例化colorpicker，并设定格式为rgba
            .colorpicker({
                format: "rgb"
            })
            // 绑定changeColor事件，当colorpicker的颜色变化的时候同步设置元素的颜色值
            .on("changeColor", function(e){
                var self = $(this);
                var objRGBA = e.color.toRGB();
                var rgba = 'rgba(' + objRGBA.r + ',' + objRGBA.g + ' ,' + objRGBA.b + ', 1)';

                self.css({ "background-color": rgba });
                obj.css('color', rgba);

                if(levelOrNumber == 'level'){
                    configObj.cardLevelColor = rgba;
                }else if(levelOrNumber == 'number'){
                    configObj.cardNumberColor = rgba;
                }
            })
            .css({ "background-color": initColor });
    }

    function setColorpicker(controller, color) {
        controller.colorpicker('setValue', color);
    }

    function initController(){
        var i = 0;
        $.each(cardListInfo, function(cardIndex, cardInfo){
            var isFirst = cardIndex === 0,
                card = isFirst ? cardMain : cardListItems.eq(cardIndex-1),
                cardWp= isFirst ? card.closest('.vcard-first') : card.closest('.vcard-item');

            // 上传背景图
            initUploadController(card, cardWp.find('.vcard-btn-uploadbg'), cardInfo, 'bg');
            // 设置会员名称颜色
            initColorpicker(card.find('.vcard-level'), cardWp.find('.vcard-color-level'), cardInfo, cardInfo.cardLevelColor, 'level');
            // 设置会员号颜色
            initColorpicker(card.find('.vcard-number'), cardWp.find('.vcard-color-number'), cardInfo, cardInfo.cardNumberColor, 'number');

            if(isFirst){
                // 上传logo
                initUploadController(card.find('.vcard-logo'), cardWp.find('.vcard-btn-uploadlogo'), cardLogoStyle, 'logo');
                // 设置会员卡名称
                initCardNameController(card.find('.vcard-level'), cardWp.find('.vcard-setlevel'), cardInfo);
                // 设置会员名字体
                initFontSizeController(card.find('.vcard-level'), cardWp.find('.vcard-select-levelfz'), cardLevelStyle);
                // 设置会员号字体
                initFontSizeController(card.find('.vcard-number'), cardWp.find('.vcard-select-numberfz'), cardNumberStyle);
            }
        });
    }

    function setElemDraggable(){
        var cardMain = $('.vcard-card-main');
        $('.vcard-elem', cardMain).each(function(){
            var self = $(this),
                configObj = null;
            if(self.hasClass('vcard-level')){
                configObj = cardLevelStyle;
            }else if(self.hasClass('vcard-number')){
                configObj = cardNumberStyle;
            }else if(self.hasClass('vcard-logo')){
                configObj = cardLogoStyle;
            }

            $(this).draggable({
                containment: cardMain,
                stop: function(e, ui){
                    configObj.left = ui.position.left;
                    configObj.top = ui.position.top;

                    formatCards();
                }
            })
        });
    }

    // 生成模板列表
    function createTpl(){
        var tplListHtml = '',
            tplListWp = $('.vcard-tpls .vcard-list'),
            tplList = null;

        // 生成列表
        $.each(cardTplCollection, function(tplIndex, tplInfo){
            tplListHtml += vcardTplHtml.replace(/{{cardBg}}/, tplInfo.cardBg).replace(/{{tplName}}/, tplInfo.tplName);
            tplListWp.html(tplListHtml);
            tplList = $('.vcard-card', tplListWp);
        });
        // 格式化样式
        $.each(cardTplCollection, function(tplIndex, tplInfo){
            var tcard = tplList.eq(tplIndex),
                tcardLevel = $('.vcard-level', tcard),
                tcardNumber = $('.vcard-number', tcard),
                tcardLogo = $('.vcard-logo', tcard),
                tpropLevel = tplInfo.cardLevel,
                tpropNumber = tplInfo.cardNumber,
                tpropLogo = tplInfo.cardLogo;

            tcardLevel.css({ 'fontSize': tpropLevel.fontSize, 'left': tpropLevel.left, 'top': tpropLevel.top, 'color': tpropLevel.color});
            tcardNumber.css({ 'fontSize': tpropNumber.fontSize, 'left': tpropNumber.left, 'top': tpropNumber.top, 'color': tpropNumber.color});
            tcardLogo.css({ 'left': tpropLogo.left, 'top': tpropLogo.top}).find('img').attr('src', tpropLogo.src);
        });
    }

    function initTplController(){
        var controller = $('.vcard-btn-selecttpl'),
            modal = $('.vcard-tpls'),
            currCard,
            currCardWp,
            currConfigObjIndex,
            currConfigObj;

        controller.on('click', function(){
            var self = $(this),
                cardListItems = $('.vcard-card', cardList);
                isFirst = self.closest('.vcard-first').length ? true : false;
            
            currCardWp = isFirst ? self.closest('.vcard-first') : self.closest('.vcard-item');
            currCard = currCardWp.find('.vcard-card');
            currConfigObjIndex = isFirst ? 0 : (currCardWp.index() + 1);
            currConfigObj = cardListInfo[currConfigObjIndex];

            modal.fadeIn();
        });

        modal.on('click', '.vcmodal-close', function(){
            modal.fadeOut();
        });

        modal.on('click', '.vcard-item-cardwp', function(){
            var self = $(this),
                item = self.closest('.vcard-item'),
                index = item.index(),
                currTplObj = cardTplCollection[index];

            currConfigObj.tplId = currTplObj.tplId;
            currConfigObj.cardBg = currTplObj.cardBg;
            currConfigObj.cardLevelColor = currTplObj.cardLevel.color;
            currConfigObj.cardNumberColor = currTplObj.cardNumber.color;

            // 如果是第一个会员卡去选择模板则可以从模板中获取更多的默认样式
            if(currConfigObjIndex === 0){
                cardLevelStyle.fontSize = currTplObj.cardLevel.fontSize;
                cardLevelStyle.left = currTplObj.cardLevel.left;
                cardLevelStyle.top = currTplObj.cardLevel.top;

                cardNumberStyle.fontSize = currTplObj.cardNumber.fontSize;
                cardNumberStyle.left = currTplObj.cardNumber.left;
                cardNumberStyle.top = currTplObj.cardNumber.top;

                cardLogoStyle.left = currTplObj.cardLogo.left;
                cardLogoStyle.top = currTplObj.cardLogo.top;

                // 初始化字段大小控件的值
                initFontSizeControllerVal($('.vcard-select-levelfz', currCardWp), cardLevelStyle);
                initFontSizeControllerVal($('.vcard-select-numberfz', currCardWp), cardNumberStyle);
            }

            setColorpicker($('.vcard-color-level', currCardWp), currConfigObj.cardLevelColor)
            setColorpicker($('.vcard-color-number', currCardWp), currConfigObj.cardNumberColor)

            formatCards();
            modal.fadeOut();
        });
    }

    function initEditController(){
        var controller = $('.vcard-btn-carddesp'),
            modal = $('.vcard-edit');

        controller.on('click', function(){
            modal.fadeIn();
        });

        modal.on('click', '.vcmodal-close', function(){
            modal.fadeOut();
        });
    }

    function toggleMutiCards(){
        var checkbox = $('.vcard-muti');

        checkbox.on('click', function(){
           if(checkbox[0].checked){
                cardList.slideDown();
                $('.vcard-setlevel').prop('disabled', true);
            }else{
                cardList.slideUp();
                $('.vcard-setlevel').prop('disabled', false);
            }
        });

        if(checkbox[0].checked){
             cardList.show();
             $('.vcard-setlevel').prop('disabled', true);
         }else{
             cardList.hide();
         }
    }

    createListCards();
    formatCards();
    initController();
    setElemDraggable();
    createTpl();
    initTplController();

    // 展示更多级别会员卡
    toggleMutiCards();

    // 编辑弹窗
    initEditController();
    
    
});
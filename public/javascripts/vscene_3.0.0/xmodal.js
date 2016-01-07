;(function(){
	$.xmodal = function(options){
		var defaults = {
			title: '提示',
			msg: '提示信息',
			btns: ['确定'],
			// btns: ['确定', '取消'],
			fnBtns: [null],
			// fnBtns: [null, null],
			fnModalShow: null,
			fnModalClose: null
		}

		var o = $.extend(true, {}, defaults, options),
			tplBtn = '<div class="xmodal-btn">{{btn}}</div>',
			tplBtns = '<div class="xmodal-btns">{{btns}}</div>',
			tplModal = '<div class="xmodal">\
				        <div class="xmodal-main">\
				            <div class="xmodal-body">\
				                <div class="xmodal-tit">{{title}}</div>\
				                <div class="xmodal-msg">{{msg}}</div>\
				            </div>\
				            <div class="xmodal-close">&#x00D7</div>\
				        </div>\
				    </div>';
		
		var win = $(window),
			btnsHtml = '',
			modalHtml = tplModal.replace('{{title}}', o.title).replace('{{msg}}', o.msg),
			modal = $(modalHtml).appendTo("body").show(), // 这里显示用于获取modalMain的大小
			modalMain = modal.find('.xmodal-main'),
			modalBody = modal.find('.xmodal-body'),
			modalClose = modal.find('.xmodal-close'),
			modalBtns = null,
			modalMainHeight = modalMain.outerHeight();

		// 如果有按钮
		if(o.btns.length > 0){
			$.each(o.btns, function(key, value){
				btnsHtml += tplBtn.replace('{{btn}}', value);
			});

			// 添加按钮到modal
			btnsHtml = tplBtns.replace('{{btns}}', btnsHtml);
			modalBody.append(btnsHtml);

			// 获取按钮对象集
			modalBtns = modal.find('.xmodal-btn');
		}

		// 隐藏modal
		modal.hide();

		// 显示modal
		modalShow();

		// 事件绑定
		modalClose.click(function(){
			modalHide();
		});
		// 如果有按钮
		if(o.btns.length > 0){
			modalBtns.each(function(i){
				$(this).click(function(){
					$.isFunction(o.fnBtns[i]) && o.fnBtns[i]();
					modalHide();
				});
			});
		}

		function modalShow(){
			var modalMainAimMarginTop = - modalMainHeight / 2,
				modalMainInitMarginTop = -(win.height()/2 + modalMainHeight);

			$.isFunction(o.fnModalShow) && o.fnModalShow();
			modal.fadeIn(500);
			modalMain.css('marginTop', modalMainInitMarginTop).animate({'marginTop': modalMainAimMarginTop}, 500);
		}

		function modalHide(){
			var modalMainInitMarginTop = -(win.height()/2 + modalMainHeight);

			modal.fadeOut(500);
			modalMain.animate({'marginTop': modalMainInitMarginTop}, 500, function(){
				$.isFunction(o.fnModalClose) && o.fnModalClose();
			});
		}
		
	};
})();
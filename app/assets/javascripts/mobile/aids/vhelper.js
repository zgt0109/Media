/**
 * @author frey
 * @date 2915/05/06
 */

// tab 切换
$(function(){
    var tab = $('.msg'),
        tabHead = $('.msg-header-item', tab),
        tabMain = $('.msg-list', tab);

    tabHead.each(function(i){
        $(this).click(function(){
            tabHead.removeClass('active').eq(i).addClass('active');
            tabMain.hide().eq(i).show();

            if (tabMain.eq(i).hasClass('msg-friend')) {
              getAidFriends();
            }

            if (tabMain.eq(i).hasClass('msg-rank')) {
              getRankList();
            }

            return false;
        });
    });

    $('.msg-header-item.active').trigger('click');
});

// 表单提交
$(function(){

    // var regName = /^[\u4E00-\u9FA5\uF900-\uFA2D]{2,}$/i;
    var regName = /^\S{2,}$/i,
        regPhone = /^\d{11}$/,
        regCheck = /^\d{6}$/,
        regConvertPass = /^\S{6,}$/;

    var showErrMsg = function(wpError, wpInput, msg){
        wpInput.addClass('input-error');
        wpError.text(msg);
    };

    var hideErrMsg = function(wpError){
        $('.input-error').removeClass('input-error');
        wpError.text('');
    };

    var isTheseInputsChecked = function(wpGroup, collection, regArr, errorTips, wpError){
        var isAllChecked = true;
        collection.each(function(){
            var self = $(this);
            var selfPosition = self.offset();
            var selfIndex = wpGroup.index(this);
            var input = null;

            if(self.hasClass('form-type-text')){
                input = self.find('.dialog-input-txt');
                var val = input.val();

                //if(!regArr[selfIndex].test(val)){
                if(!inputRegMap[mapInputName(self)].test(val)){
                    //showErrMsg(wpError, self, errorTips[selfIndex]);
                    showErrMsg(wpError, self, inputErrorTipMap[mapInputName(self)]);
                    // $('html, body').animate({scrollTop: selfPosition.top - 50})
                    isAllChecked = false;
                    return false;
                }
                else if(input.hasClass('sms-verification')) {
                  smsVerification = localStorage.getItem('sms_code');
                  if (smsVerification != val) {
                    return false;
                  }
                }
            }else if(self.hasClass('form-type-radio')){
                var hasRadioChecked = false;

                self.find('.dialog-input-radio').each(function(){
                    if($(this).prop('checked')){
                        hasRadioChecked = true;
                        return false;
                    }
                });

                if(!hasRadioChecked){
                    //showErrMsg(wpError, self, errorTips[selfIndex]);
                    showErrMsg(wpError, self, inputErrorTipMap[mapInputName(self)]);
                    isAllChecked = false;
                    return false;
                }
            }
        });

        return isAllChecked;
    }

    var mapInputName = function ($input) {
      if ($input.hasClass('dialog-form-name'))
        return 'dialog-form-name';
      else if ($input.hasClass('dialog-form-phone'))
        return 'dialog-form-phone';
      else if ($input.hasClass('dialog-form-check'))
        return 'dialog-form-check';
      else if ($input.hasClass('dialog-form-convertpass'))
        return 'dialog-form-convertpass';
      else if($input.hasClass('dialog-form-store'))
        return 'dialog-form-store'
    }

    var inputRegMap = {
      'dialog-form-name':        regName,
      'dialog-form-phone':       regPhone,
      'dialog-form-check':       regCheck,
      'dialog-form-convertpass': regConvertPass,
      'dialog-form-store':       undefined        
    };

    var inputErrorTipMap = {
      'dialog-form-name':        '姓名为两位以上的字符',
      'dialog-form-phone':       '手机号必须为11位的数字',
      'dialog-form-check':       '请输入6位验证码',
      'dialog-form-convertpass': '请输入6位以上密码',
      'dialog-form-store':       '请选择门店'
    };

    var setForm1 = function(formSectionObj){
        var regArr = [regName, regPhone, regCheck],
            errorTips = [
                '姓名为两位以上的字符',
                '手机号必须为11位的数字',
                '请输入6位验证码'
            ];

        var wpGroup = $('.dialog-form-wp', formSectionObj),
            wpName = $('.dialog-form-name', formSectionObj),
            wpPhone = $('.dialog-form-phone', formSectionObj),
            wpCheck = $('.dialog-form-check', formSectionObj),
            wpError = $('.dialog-form-error', formSectionObj),
            checkBtn = $('.dialog-input-btn', formSectionObj),
            submitBtn = $('.dialog-btn', formSectionObj);

        // 绑定验证码相关事件
        if(checkBtn.length){

            checkBtn.on("click", function(e){
                // 用来表示验证码之前的表单是否都通过验证
                var collection = $(".dialog-form-name, .dialog-form-phone", formSectionObj),
                    isAllChecked = isTheseInputsChecked( wpGroup, collection, regArr, errorTips, wpError ),
                    sendStatu = false, // 记录验证码是否正在发送
                    sendCount = function(startNum){
                        var max = startNum - 1;

                        checkBtnSetVal(max+"s后重新获取");
                        if(max == 0){
                            sendStatu = false;
                            checkBtnEnable();
                            checkBtnSetVal("获取验证码");
                            return false;
                        }
                        setTimeout(function(){
                            sendCount(max)
                        }, 1000);
                    },
                    checkBtnDisable = function(){
                        checkBtn.prop('disabled', true);
                    },
                    checkBtnEnable = function(){
                        checkBtn.prop('disabled', false).val("获取验证码");
                    },
                    checkBtnSetVal = function(msg){
                        checkBtn.val(msg);
                    };

                // 如果前面的验证都通过
                if(isAllChecked){
                    if(!sendStatu){
                        getVerification();
                        sendStatu = true;
                        checkBtnDisable();
                        checkBtnSetVal("验证码已发送！");
                        setTimeout(function(){
                            sendCount(10);
                        }, 1000);
                    }
                }

            });

        }

        
        // 表单提交
        submitBtn.on('click', function(e){
            var collection = $(".dialog-form-name, .dialog-form-phone, .dialog-form-check", formSectionObj),
                isAllChecked = isTheseInputsChecked( wpGroup, collection, regArr, errorTips, wpError );

            isAllChecked = true;
            if(isAllChecked){
                window.form1Submit && window.form1Submit();
            }else{
                e.preventDefault();
            }
        });

        // 表单实时验证
        $('.form-type-text', formSectionObj).on('input', function(){
            var isThisChecked = isTheseInputsChecked(wpGroup, $(this), regArr, errorTips, wpError );

            if(isThisChecked) hideErrMsg(wpError);
        });

    };

    var setForm2 = function(formSectionObj){
        var regArr = [regConvertPass, null],
            errorTips = [
                '请输入6位以上密码',
                '请选择门店'
            ];

        var wpGroup = $('.dialog-form-wp', formSectionObj),
            wpConvertpass = $('.dialog-form-convertpass', formSectionObj),
            wpStore = $('.dialog-form-store', formSectionObj),
            wpError = $('.dialog-form-error', formSectionObj),
            submitBtn = $('.dialog-btn', formSectionObj);


        // 表单提交
        submitBtn.on('click', function(e){
            var collection = $(".dialog-form-convertpass, .dialog-form-store", formSectionObj),
                isAllChecked = isTheseInputsChecked( wpGroup, collection, regArr, errorTips, wpError );

            if(isAllChecked){
                window.form2Submit && window.form2Submit();
            }else{
                e.preventDefault();
            }
        });

        // 表单实时验证
        $('.form-type-text', formSectionObj).on('input', function(){
            var isThisChecked = isTheseInputsChecked(wpGroup, $(this), regArr, errorTips, wpError );

            if(isThisChecked) hideErrMsg(wpError);
        });

    };

    if($('.dialog-form1').length)
        setForm1($('.dialog-form1'));

    if($('.dialog-form2').length)
        setForm2($('.dialog-form2'));

});

// 表单弹窗
$(function(){
    $('.dialog-close').on('click', function(){
        $(this).closest('.dialog').fadeOut(400);
        $('html').removeClass('dialog-forbidden');
    });

    $('.main-btn-getprize').on('click', function(){
        $('.dialog-form1').fadeIn(400);
        $('html').addClass('dialog-forbidden');
        return false;
    });

    $('.main-btn-convertprize').on('click', function(){
        $('.dialog-form2').fadeIn(400);
        $('html').addClass('dialog-forbidden');
        return false;
    });
});

// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require lib/bootstrap.min
//= require lib/bootstrap-colorpicker.min
//= require lib/pnotify.custom.min
//= require lib/scrollUp

//= require fuelux/fuelux.wizard.min

//= require date-time/moment.min
//= require date-time/bootstrap-clockpicker
//= require date-time/bootstrap-datepicker.min
//= require date-time/daterangepicker.min
//= require date-time/bootstrap-datetimepicker
//= require date-time/datepicker.zh

//= require lib/jquery.hotkeys.min
//= require lib/bootstrap-wysiwyg.min

//= require lib/vue.min
//= require nod.min
//= require lib/qrcode.min
//= require lib/highcharts
//= require lib/imgUpload
//= require lib/jquery.validate.min
//= require lib/jquery.validate.messages_zh
//= require lib/iscroll
//= require lib/jquery.slimscroll

//= require map/jquery-jvectormap-1.2.2.min
//= require map/jquery-jvectormap-cn-merc-cn

//= require site_admin
//= require activity
//= require zeroclipboard
//= require lib/rails.validations
//= require client_side_validations.custom
//= require address
//= require weddings
//= require fuelux/fuelux.wizard.min
//= require fight
//= require rails.confirm
//= require jquery-fileupload/basic
//= require qiniu_uploader
//= require select2



function showTip(type, str) {
    PNotify.removeAll();
    type = {
        "success": "",
        "warning": 'error'
    }[type];
    var delay = type == 'error' ? 5000 : 2000;
    new PNotify({
        title: '通知',
        text: str,
        type: type,
        remove: true,
        delay: delay
    });
    return false;
}

Date.prototype.format = function(format) {
    var o = {
        "M+": this.getMonth() + 1, //month
        "d+": this.getDate(), //day
        "h+": this.getHours(), //hour
        "m+": this.getMinutes(), //minute
        "s+": this.getSeconds(), //second
        "q+": Math.floor((this.getMonth() + 3) / 3), //quarter
        "S": this.getMilliseconds() //millisecond
    }

    if (/(y+)/.test(format)) {
        format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    }

    for (var k in o) {
        if (new RegExp("(" + k + ")").test(format)) {
            format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
        }
    }
    return format;
}

function dateDiff(start_d, end_d) {
    var day = 24 * 60 * 60 * 1000;
    try {
        var dateArr = start_d.split(' ')[0].split("-");
        var checkDate = new Date();
        checkDate.setFullYear(dateArr[0], dateArr[1] - 1, dateArr[2]);
        var checkTime = checkDate.getTime();

        var dateArr2 = end_d.split(' ')[0].split("-");
        var checkDate2 = new Date();
        checkDate2.setFullYear(dateArr2[0], dateArr2[1] - 1, dateArr2[2]);
        var checkTime2 = checkDate2.getTime();

        var cha = (checkTime2 - checkTime) / day;
        return cha;
    } catch (e) {
        return 0;
    }
}


$.validator.addMethod("neq0", function(value, element, params) {
    return value != 0;
}, '不能等于0');

jQuery.validator.addClassRules("neq0", {
    neq0: true
});


$.validator.addMethod("gte_now", function(value, element, params) {
    return Date.parse(value) >= new Date().getTime();
}, '必须大于当前时间');

$.validator.addMethod("gte_activity_start_at", function(value, element, params) {
    var start_at = $('#activity_start_at').val();
    if (start_at.length) {
        return true;
    }
    return Date.parse(value) >= Date.parse(start_at);
}, '必须大于开始时间');

jQuery.validator.setDefaults({
    // onfocusout: false,
    // onkeyup: false,
    errorClass: "error-message"
});

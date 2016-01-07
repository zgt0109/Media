/*
 *= require bootstrap.min
 *= require lib/jquery.validate.min
 *= require lib/jquery.validate.messages_zh
 *= require micro_shop/validate
 *= require micro_shop/ace-elements.min
 *= require micro_shop/ace.min
 *= require mobile/lib/jquery-ui-1.10.3.custom.min
 *= require lib/pnotify.custom.min
 *= require micro_shop/jquery.dataTables.min
 *= require micro_shop/jquery.dataTables.bootstrap
 *= require micro_shop/tables
 *= require date-time/moment.min
 *= require date-time/bootstrap-datepicker.min
 *= require date-time/bootstrap-datetimepicker
 *= require date-time/datepicker.zh
 *= require micro_shop/app
 *= require highcharts
 *= require jquery_ujs
 *= require rails.confirm
 *= require lib/jquery.hotkeys.min
 *= require lib/bootstrap-wysiwyg.min
 *= require lib/imgUpload
 *= require_self
 */

function showTip(type, str) {
    PNotify.removeAll();
    type = {
        "success": "",
        "warning": 'error'
    }[type];
    var delay = type == 'error' ? 3000 : 1000;
    new PNotify({
        title: '通知',
        text: str,
        type: type,
        remove: true,
        delay: delay
    });
    return false;
}

function renderModal(options) {
    var id = options.id,
        w = options.w,
        h = options.h,
        title = options.title,
        iframe = options.iframe,
        text = options.text,
        selector = options.selector,
        btns = parseFloat(options.btns),
        action = options.action,
        method = options.method;
    if (method=='get'){
        fmethod = "get"
    }else{
        fmethod = "post"
    }

    if (text) {
        var type = "text";
        var botton='<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>';
    } else {
        var type = "iframe";
        var botton='<button type="button" class="close" onclick="hideModals()">&times;</button>';
    }
    var html = '<div class="modal fade modal-' + type + '" id="' + id + '" data-backdrop="static">' +
        '<div class="modal-dialog" style="width: ' + w + 'px;">' +
        '<div class="modal-content">' +
        '<div class="modal-header">' +botton+
        '<h4 class="modal-title">' + title + '</h4>' +
        '</div><form role="form" action="' + action + '" method="'+ fmethod +'">';
    html += '<input name="_method" type="hidden" value="'+method+'">';
    html += '<input name="authenticity_token" type="hidden"/>'
    if (text && text != "") {
        html += '<div class="modal-body">' +
            '<p class="text-center">' + text + '</p></div>' +
            '<div class="clearfix"></div>';
        if (btns > 0) {
            html += '<div class="modal-footer">';
            if (btns == 1) {
                html += '<button type="button" class="btn btn-sm btn-primary" data-dismiss="modal">确定</button>';
            } else {
                html += '<button type="submit" class="btn btn-sm btn-primary" data-fn="submit">确定</button>' +
                    '<button type="button" class="btn btn-sm btn-default" data-dismiss="modal">取消</button>';
            }
            html += '</div></form>';
        }
        html += '</div>';
    }
    if (iframe && iframe != "") {
        html += '<iframe width="100%" height="' + h + '" src="' + iframe + '"></iframe>';
    }

    html += '</div></div></div>';
    $('#' + id).remove();
    $("body").append(html);
    $('input[name=authenticity_token]').val($("meta[name=csrf-token]").attr("content"));
    $('#' + id).modal('show');
    return false;
}


function hideModals() {
    var dc = $(parent.document),
        $modal = dc.find('.modal'),
        $modalBg = dc.find(".modal-backdrop")
    $modal.attr('aria-hidden', true).removeClass('in');
    $modalBg.remove();
    $(parent.document.body).removeClass('modal-open');
    $modal.find("iframe").remove();
    $modal.remove();
}


function set_wysiwyg_field_value(wysiwyg_instance) {
    var self = $(wysiwyg_instance)
    var content = self.html()

    wysiwyg_value_field = self.next(".wysiwyg-value-field")
    if ( wysiwyg_value_field.is('textarea') ) {
        self.next(".wysiwyg-value-field").text(content)
    };
    if ( wysiwyg_value_field.is('input') ) {
        self.next(".wysiwyg-value-field").val(content)
    };

}

$(function () {
    $(document).on('click', '[data-toggle="modals"]', function () {
        var self = $(this),
            id = self.attr("data-target"),
            action = self.attr("data-url"),
            title = self.attr("data-title") || "系统提示",
            w = self.attr("data-width"), //弹出层的宽度
            h = self.attr("data-height"),//iframe的高度
            text = self.attr("data-text"),//弹出层的文本
            iframe = self.attr("data-iframe"),
            btns = self.attr("data-btns") || 2,//0（无按钮，自动消失）； 1（确认信息，有确认按钮）；2（确认，取消按钮）
            method = self.attr("data-method");
        renderModal({
            id: id,
            w: w,
            h: h,
            title: title,
            iframe: iframe,
            text: text,
            selector: self,
            btns: btns,
            action: action,
            method: method
        });
    });

    $(".cieldon-file").cieldonfileupload({
        token: window.qiniu_token,
        bucket: window.qiniu_bucket
    });

    $("input[type=submit]").click(function () {
        $(".wysiwyg-editor").map(function (i,x){
            set_wysiwyg_field_value(x);
        });
    });

});

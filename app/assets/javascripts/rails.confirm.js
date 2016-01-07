$.rails.allowAction = function(element) {
    var message = element.data('confirm'),
        answer = false,
        callback;
    if (!message) {
        return true;
    }

    if ($.rails.fire(element, 'confirm')) {
        answer = $.rails.confirm(element);
        callback = $.rails.fire(element, 'confirm:complete', [answer]);
    }
    return answer && callback;
}

$.rails.confirm = function(element) {
    var id = 'popup-confirm',
        w = element.data('width'),
        h = element.data('height'),
        title = element.data('title') || '系统提示',
        text = element.data('confirm') || '确定删除？',
        type = text ? 'text' : 'iframe',
        remote = !! element.data('remote');
    var target_str = element.attr('target') ? ' target="'      + element.attr('target') + '"' : '';
    var method_str = element.data('method') ? ' data-method="' + element.data('method') + '"' : '';

    var html = '<div class="modal fade modal-' + type + '" id="' + id + '"  data-backdrop="static">' +
        '<div class="modal-dialog" style="width: ' + w + 'px;">' +
        '<div class="modal-content">' +
        '<div class="modal-header">' +
        '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
        '<h4 class="modal-title">' + title + '</h4>' +
        '</div><form role="form" action="" method="">';

    html += '<div class="modal-body">' +
        '<p class="text-center">' + text + '</p></div>' +
        '<div class="clearfix"></div>';

    html += '<div class="modal-footer">';
    href = remote ? 'javascript:' : element.attr('href');
    html += '<a href="' + href + '"' + target_str + method_str + ' class="btn btn-sm btn-primary" id="pop-confrim-submit">确定</a>';
    html += '<button type="button" class="btn btn-sm btn-default" data-dismiss="modal">取消</button>';
    html += '</div></form>';
    html += '</div>';
    html += '</div></div></div>';

    $('#' + id).remove();
    $("body").append(html);
    $('#' + id).modal('show');
    if (remote) {
        $('#pop-confrim-submit').click(function(event) {
            event.preventDefault();
            $.rails.handleRemote(element);
            $(this).next().click();
            if (element.data('callback')) {
                eval(element.data('callback'));
            }
            return false;
        });
    }
    if (target_str) {
        $('#pop-confrim-submit').click(function(event) {
            $(this).next().click();
        });
    };
    return false;
};

function removePhoto(id) {
    $obj = $('#delete' + id)
    $obj.closest('.photo-li').slideUp(function() {
        $obj.closest('.photo-li').remove();
    });
};
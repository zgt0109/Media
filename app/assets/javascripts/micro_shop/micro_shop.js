/**
 * Created by Administrator on 14-3-20.
 */
var App = function() {

    var base = function() {

        $('[data-rel=tooltip]').tooltip({
            container: 'body'
        });
        $('[data-rel=popover]').popover({
            container: 'body'
        });
    }


    var showQR = function() {
        var $QRCode = $('#QRCode');
        $('.showQRCode').on('mouseover', function() {
            $QRCode.css('display', 'block');

        });
        $('.showQRCode').on('mouseleave', function() {
            $QRCode.css('display', 'none');

        });
    }


    var siteCont = function() {
        function showErrorAlert(reason, detail) {
            var msg = '';
            if (reason === 'unsupported-file-type') {
                msg = "Unsupported format " + detail;
            } else {
                console.log("error uploading file", reason, detail);
            }
            $('<div class="alert"> <button type="button" class="close" data-dismiss="alert">&times;</button>' +
                '<strong>File upload error</strong> ' + msg + ' </div>').prependTo('#alerts');
        }


        $('.wysiwyg-editor').ace_wysiwyg({
            toolbar: [
                'font',
                null,
                'fontSize',
                null, {
                    name: 'bold',
                    className: 'btn-info'
                }, {
                    name: 'italic',
                    className: 'btn-info'
                }, {
                    name: 'strikethrough',
                    className: 'btn-info'
                }, {
                    name: 'underline',
                    className: 'btn-info'
                },
                null, {
                    name: 'insertunorderedlist',
                    className: 'btn-success'
                }, {
                    name: 'insertorderedlist',
                    className: 'btn-success'
                }, {
                    name: 'outdent',
                    className: 'btn-purple'
                }, {
                    name: 'indent',
                    className: 'btn-purple'
                },
                null, {
                    name: 'justifyleft',
                    className: 'btn-primary'
                }, {
                    name: 'justifycenter',
                    className: 'btn-primary'
                }, {
                    name: 'justifyright',
                    className: 'btn-primary'
                }, {
                    name: 'justifyfull',
                    className: 'btn-inverse'
                },
                null, {
                    name: 'createLink',
                    className: 'btn-pink'
                }, {
                    name: 'unlink',
                    className: 'btn-pink'
                },
                null, {
                    name: 'insertImage',
                    className: 'btn-success'
                },
                null,
                'foreColor',
                null, {
                    name: 'undo',
                    className: 'btn-grey'
                }, {
                    name: 'redo',
                    className: 'btn-grey'
                }
            ],
            speech_button: false,
            'wysiwyg': {
                fileUploadError: showErrorAlert
            }
        }).prev().addClass('wysiwyg-style2');
        //$('.wysiwyg-editor').ace_wysiwyg().prev().addClass('wysiwyg-style2');
    }

    var radioTab = function(selector) {


        $('.' + selector + ' input[data-toggle=radioTab]').on('click', function() {
            $('.' + selector + ' .radio-tab-content').children('div').addClass('hide');
            var $self = $(this);
            var target = $self.data('target');
            $('#' + target).removeClass('hide');
        })
    }

    var divShow = function() {
        $('input[data-toggle="showblock"]').on('click', function() {
            var target = $(this).data('target');
            $(target).toggleClass('hide');
        })
    }

    var activeSideBar = function() {
        $('a[href="' + location.pathname + '"]').parents('li').addClass('open active');
    };

    /*modal*/
    var onModalHidden = function() {
        $('.modal').on('hidden.bs.modal', function(e) {
            $(this).find("form")[0].reset();
            $(this).find('#pay_amount').text(0);
            $(this).find('#given_points').text(0);
            $(this).find('.name').html("");
            $(this).find('.usable_amount').html("");
            $(this).find('.usable_points').html("");
            $(this).find('#vip_user_id').val("");
        })
    }

    return {
        init: function() {
            activeSideBar();
            showQR();

            siteCont();
            radioTab('VCFields');
            radioTab('OperaType');
            radioTab('VCCondition');
            radioTab('rightsDateRange');
            radioTab('FestivalType');
            radioTab('GiveType');
            radioTab('ForgetPwd');
            radioTab('voteSetting');
            divShow();
            base();
        },
        modal: function() {
            onModalHidden();

        }
    };
}();
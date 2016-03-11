/**
 * Created by Administrator on 14-3-20.
 */
var App = function () {
    var base = function () {
        Highcharts.setOptions({
            lang: {
                downloadJPEG: '下载 JPEG 格式',
                downloadPDF: '下载 PDF 格式',
                downloadPNG: '下载 PNG 格式',
                downloadSVG: '下载 SVG 格式',
                printChart: '打印图表'
            },
            credits: {
                enabled: false
            } });

        $('[data-rel=tooltip]').tooltip();
        $('[data-toggle="tooltip"]').tooltip();
        $('[data-rel=popover]').popover();
        $('[data-rel=popovers]').popover({
            content: function () {
                return $(this).attr("data-contents");
            },
            trigger: 'hover',
            html: true,
            placement: 'right'
        });
        $(document).on("mouseenter", ".tree-code", function () {
            var self = $(this),
                img = self.attr("data-img");
            self.after('<div class="QRCode"><img src="' + img + '"></div>');
        });
        $(document).on("mouseleave", ".tree-code", function () {
            var self = $(this);
            self.nextUntil(".QRCode").remove();
        });
        var transUrl = function (url) {
            window.location.href = url;
        };
        $(document).on('click', 'th input:checkbox' , function(){
            // console.log("1111");
            var that = this;
            $(this).closest('table').find('tr > td:first-child input:checkbox')
                .each(function(){
                    this.checked = that.checked;
                    $(this).closest('tr').toggleClass('selected');
                });
        });

        $('a[data-toggle="tab"]').click(function (e) {
            e.preventDefault();
            var hash = $(this).attr("href");
            $('.nav a[href="' + hash + '"]').tab('show');
            window.location.hash = "?" + hash;

        });
        var hash = window.location.hash.replace("#?", "");
        $('.nav a[href="' + hash + '"]').tab('show');
        // Validate.init();
        $('.modal').on('shown.bs.modal', function (e) {
            //fileup();
            //Validate.init();
        });

        $(document).on('click', '[data-dismiss="modals"]', function () {
            hideModals();
        });
        $(".form-select-1").change(function () {
            var self = $(this),
                next = $(".form-select-2"),
                $index = self.val(),
                $data = self.attr("data-category").split(",")[$index].split(" "),
                $option = "";
            $.each($data, function (i) {
                $option += '<option value="' + $data[i] + '">' + $data[i] + '</option>';

            });
            next.html($option).removeAttr("disabled");
        });
        $(document).on("click", ".ace-thumbnails li", function () {
            var self = $(this),
                $ul = self.parents("ul");
            $ul.find("li").removeClass("active");
            $ul.find("li").find("input").prop("checked", false)
            self.addClass("active");
            self.find("input").prop("checked", true);
            // console.log(self.find("input").is(":checked"));
        });
        $(".btn-filter-tab").click(function () {
            var $self = $(this);
            $self.siblings().removeClass("active");
            $self.addClass("active");
        });
        $(document).on("click", ".btn-toggle", function () {
            var self = $(this),
                $div = self.attr("data-target");
            self.next().toggle();
        });
        $(document).on('click', '[data-toggle="text"]', function () {
            var self = $(this),
                text = self.attr("data-text");
            if (text && text != "") {
                text = text.split(",");
            }
            self.toggleClass("active");
            if (self.hasClass("active")) {
                self.html(text[1]);
            } else {
                self.html(text[0]);
            }
        });

        $("[data-toggle=div]").on("click", function () {
            var target = $(this).data('target');
            $(target).toggleClass('hide');
        });


        // $(".cieldon-file").parent("div").removeClass().addClass("clearfix");

        $('input[class*="colorpicker"]').colorpicker();
    };
    var showQR = function () {
        var $QRCode = $('.showQRCode');
        $QRCode.on('mouseover', function () {
            $QRCode.find(".QRCode").css('display', 'block');
        });
        $QRCode.on('mouseleave', function () {
            $QRCode.find(".QRCode").css('display', 'none');
        });
    };
    var siteCont = function () {
        function showErrorAlert(reason, detail) {
            var msg = '';
            if (reason === 'unsupported-file-type') {
                msg = "Unsupported format " + detail;
            }
            else {
                // console.log("error uploading file", reason, detail);
            }
            $('<div class="alert"> <button type="button" class="close" data-dismiss="alert">&times;</button>' +
                '<strong>File upload error</strong> ' + msg + ' </div>').prependTo('#alerts');
        }


        ace_wysiwygFn();
    };

    var divToggleByRadio = function(){
        $('input[data-radio-toggle="show"]').on('click', function(){
            var target = $(this).data('target');
            $(target).removeClass('hide');
        });

        $('input[data-radio-toggle="hide"]').on('click', function(){
            var target = $(this).data('target');
            $(target).addClass('hide');
        });

        $('input[data-radio-toggle]:checked').each(function(){
            $(this).triggerHandler('click')
        });
    };

    var divShow = function () {
        $('input[data-toggle="showblock"]').on('click', function () {
            var target = $(this).data('target');
            $(target).toggleClass('hide');
        })
    }
    var handleModal = function (options) {
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
    };
    var dropdownToggle = function () {
        $(".nav-list .dropdown-toggle").click(function () {
            var self = $(this),
                $li = self.parents("li"),
                $submenu = $li.find(".submenu");
            $li.toggleClass("open");
            $li.siblings("li").removeClass("open");
            $li.siblings("li").find(".submenu").slideUp();
            $submenu.slideToggle();
        });
        $("#sidebar-collapse").click(function () {
            $("#sidebar").toggleClass("menu-min");
            $(this).find(".icon-double-angle-left").toggleClass("icon-double-angle-right");

        });
        var url = location.pathname;
        if (url == " ") {
            $("a[href='index']").parents('li').addClass('active');
            return;
        }
        var $a = $(".nav-list a[href='" + url + "']");
        var urls = {"/vbusiness/add_shop": "/vbusiness/shop",
            "/system": "/system/account",
            "/datacube": "/datacube/attention",
            "/api": "/api/doc"
        };
        if (urls[url]) {
            $a = $(".nav-list a[href='" + urls[url] + "']")
        }

        if ($a.parents('ul').hasClass('submenu')) {

            $a.parents('li').addClass('open active');
        } else {

            $a.parents('li').addClass('active');
        }
    };
    var handleTabs = function (options) {
        $(document).on('change', '[data-toggle="tabs"]', function () {
            var self = $(this),
                href = self.attr("data-href"),
                value = self.val(),
                content = $(self.attr("data-target")),
                fn = self.attr("data-fn");
            href += value;
            if (fn && fn != "" && fn != "null") {
                fn += value;
                $fn = options.tabFn[fn];
                if ($fn) {
                    $fn();
                }
            }
            content.find("> .tab-pane.active").removeClass("active");
            $("#" + href).addClass("active");
        });
    };
    var mvcHandler = function () {
        $('[data-mvc=true]').on("click", function () {
            var purpose = $(this).data("purpose");
            var url = $(this).data("url");


            $.get(url, function (data, status) {
                //console.log(data + " " + status);
                var demo = new Vue({
                    el: purpose,
                    data: {
                        list: data
                    }
                });
            });
        });
    };
    var notifyHandler = function () {
        var title, text, type;
        $('[data-toggle=notify]').on('click', function () {
            title = $(this).data('title');
            text = $(this).data('text');
            type = $(this).data('type');
            var test = new PNotify({
                title: title,
                text: text,
                type: type,
                styling: 'fontawesome'
            });
        });
    };
    var handleRender = function () {
        $(document).on('click', '[data-toggle="render"]', function () {
            var self = $(this),
                target = self.attr("data-target"),
                $target = $(target),
                title = self.attr("data-title"),
                iframe = self.attr("data-iframe"),
                h = self.attr("data-height");
            var html = '<div class="widget-box transparent">' +
                '<div class="widget-header widget-header-flat">' +
                '<h4 class="">' + title + '</h4></div>' +
                '<div class="widget-body"><iframe width="100%" height="' + h + '" src="' + iframe + '"></iframe></div></div>';
            $target.html(html);
        });
    };
    var toggleShow = function () {
        $("[data-toggle=toggleShow]").on('click', function () {
            var targets = $(this).data("targets");
            targets = targets.split(',');
            $(targets[0]).addClass('hide');
            $(targets[1]).removeClass('hide');
        });
    };
    var selectTab = function () {
        $("[data-toggle=select]").on('change', function () {
            var $self = $(this);
            var target = $self.find("option:selected").data("target");
            if (target == "#all_option") {
                $(target).find('.form-group').addClass('hide');
            }
            else {
                $(target).removeClass("hide");
                $(target).siblings().addClass("hide");
            }
        });

    };

    var handelMater = function () {
        $(document).on('click', 'a[data-fn="addMater"]', function () {
            var self = $(this),
                div = self.parents(".addvMS"),
                list = div.prevAll(".vMSli"),
                n = list.length;
            if (n >= 8) {
                renderModal({
                    id: "mesModal",
                    text: "最多添加8条！",
                    selector: self
                });
            } else {
                var html = '<div class="vMSli" data-id="' + (n + 1) + '"><span class="pull-left">标题</span><span class="pull-right" id="img-' + (n + 1) + '"></span></div>';
                div.before(html);
            }
        });
        $(document).on('click', '.vMSli .btn-remove', function () {
            var self = $(this),
                div = self.parents(".vMSli"),
                id = self.attr("data-id"),
                action = self.attr("data-action"),
                method = self.attr("data-method");
            /*
             renderModal({
             id: "delModal",
             text: "确定要删除么",
             selector: self,
             action: action,
             method: method
             });
             */

            var $div = $(".vMSli");
            var $form = $(".form-wrap:gt(0)");
            var l = $div.length;

            if (l <= 1) {
                renderModal({
                    id: "mesModal",
                    text: "至少2条多图文！",
                    selector: self
                });
                return false;
            }

            if ($("#form-" + id).length > 0) {
                $("#form-" + id).prev().show();
                $("#form-" + id).remove();
            }

            div.remove();

            $.each($div, function (i) {
                $($div[i]).attr("data-id", i + 1);
            });
            $.each($form, function (i) {
                $($form[i]).attr("id", 'form-' + i);
            });
            if (id >= l && l > 1) {
                id -= 1;
            } else if (l <= 0) {
                id = 0;
            }
            var top = 200 + 90 * (id - 1);
            var mater = $(".form-mater");
            mater.css({"margin-top": top + "px"});
        });
        $(document).on('click', '.warpVMS .btn-edit', function () {
            var self = $(this),
                top = self.attr("data-top"),
                id = self.attr("data-id"),
                body = self.attr("data-body");
            var mater = $(".form-mater");
            mater.css({"margin-top": top + "px"});

            if ($("#form-" + id).length <= 0) {
                $(".form-mater").attr("data-id", id).attr("data-body", body);
                //var form = mater.find(".form-wrap");
                //var html = $(form[0]).html();
                //form.hide();

                var html = $('#material-form-template .form-wrap').html();
                mater.append('<div class="form-wrap" id="form-' + id + '">' + html + '</div>');
                var $form = $("#form-" + id);
                $form.find('select[data-toggle="tab"]').attr("data-href", 'tab_' + id + '_1,tab_' + id + '_2,tab_' + id + '_3').attr("data-content", "#tab" + id);
                $form.find(".tab-content").attr("id", "tab" + id);
                //$form.find("input").val("");
                $form.find("input[type=submit]").val("保存");
                //$form.find("textarea").val("");
                $form.find(".cieldon-file").attr("data-div", "#img-" + (parseInt(id) + 1)).attr("data-height", "70").attr("data-width", "70").html("");
                var pane = $form.find(".tab-pane");
                $.each(pane, function (i) {
                    $(pane[i]).attr("id", "tab_" + id + "_" + (i + 1));
                });
                // fileup();
                fileup_for_material();
            }
            mater.find(".form-wrap").hide();
            $("#form-" + id).show();
        });
        $(document).on('mouseenter', '.material .vMSli', function () {
            var self = $(this),
                id = self.attr("data-id"),
                action = self.attr("data-url"),
                body = self.attr("data-body");
            var top = 260 + 90 * (id - 1);
            var html = '<div class="vMSliTool"><a class="fa fa-pencil btn-edit" data-top="' + top + '" data-id="' + id + '" data-body="' + body + '"></a><a class="fa fa-trash-o btn-remove" data-id="' + id + '" data-body="' + body + '" data-url="' + action + '"></a></div>';
            self.append(html);
        });
        $(document).on('mouseleave', '.material .vMSli', function () {
            var self = $(this);
            self.find(".vMSliTool").remove();
        });
        $(document).on('mouseenter', '.material .vMSHd', function () {
            var top = 0;
            var html = '<div class="vMSliTool" style="height: 200px; line-height: 200px;"><a class="fa fa-pencil btn-edit" data-top="' + top + '" data-id="0"></a></div>';
            $(this).append(html);
        });
        $(document).on('mouseleave', '.material .vMSHd', function () {
            var top = 0;
            var html = '<div class="vMSliTool"><a class="fa fa-pencil btn-edit" data-top="' + top + '"></a></div>';
            $(this).find(".vMSliTool").remove();
        });
    };

    var topNav = function () {
        var path = location.pathname;
        var controller = path.split("/")[1]
        var $li = $('.navbar-header li a[href="/' + controller + '"]').parent();
        $li.siblings().find("a").removeClass("active");
        $li.find("a").addClass("active");
    };

    var dataFilter = function () {
        $(".data-filter").find(".daterange").val(moment().format("YYYY-MM-DD") + " - " + moment().format("YYYY-MM-DD"));

        $(".data-filter a").on("click", function () {
            var $self = $(this);
            var range = $self.data("range");
            switch (range) {
                case "seven":
                    range = moment().subtract("days", 6).format("YYYY-MM-DD");
                    break;
                case "recent_7":
                    range = moment().subtract("days", 7).format("YYYY-MM-DD");
                    break;
                case "month":
                    range = moment().subtract("days", 29).format("YYYY-MM-DD");
                    break;
                case "recent_30":
                    range = moment().subtract("days", 30).format("YYYY-MM-DD");
                    break;
                case "today":
                    range = moment().format("YYYY-MM-DD");
                    break;
                case "yesterday":
                    range = moment().subtract("days", 1).format("YYYY-MM-DD");
                    break;
            }
            if ($self.data("range") == "yesterday") {
                range = range + " - " + moment().subtract("days", 1).format("YYYY-MM-DD");
            } else {
                range = range + " - " + moment().format("YYYY-MM-DD");
            }
            daterange = $self.parents(".data-filter").find(".daterange")
            daterange.val(range);
            daterange.trigger('apply.daterangepicker')

        });
    };

    var step = function () {
        $("[data-toggle=prev]").on("click", function () {
            var $self = $(this);
            var tar = $self.data("target");
            if ($self.text() == "返回") {
                return false;
            }
            $(tar).find(".active:last").removeClass("active");
            if (!$(".step-bar-cont").eq(1).hasClass("active")) {
                $self.addClass("hide").prev().removeClass("hide");
            }
            $(tar).find(".details.show").removeClass("show").prev().addClass("show");
        });

        $("[data-toggle=next]").on("click", function () {
            var $self = $(this);
            var tar = $self.data("target");
            $("[data-toggle=prev]").removeClass("hide").prev().addClass("hide");
            var l = $(tar).find(".step-bar-cont").length;
            if ($(tar).find(".active:last").index() < l - 1) {
                $(tar).find(".active:last").next().addClass("active");
                $(tar).find(".details.show").removeClass("show").next().addClass("show");
            }
            if ($(tar).find(".active:last").index() == l - 1) {
                $("[data-toggle=prev]").remove();
                $("[data-toggle=next]").remove();
            }
        });
    };

    var showAlertByCookie = function () {
        var value = "";
        if (document.cookie.length > 0) {
            var c_start = document.cookie.indexOf('alertBlock' + "=");
            if (c_start != -1) {
                c_start = c_start + 'alertBlock'.length + 1
                var c_end = document.cookie.indexOf(";", c_start);
                if (c_end == -1) c_end = document.cookie.length;
                value = document.cookie.substring(c_start, c_end);
            }
        }

        var alertBlockIndexs = value.split("");
        var $alertBlocks = $('.alert-block i.icon-remove');
        for (var i = 0, l = alertBlockIndexs.length; i < l; i++) {
            $alertBlocks.eq(alertBlockIndexs[i]).parents(".alert-block").hide();
        }

        $('.alert-block i.icon-remove').on('click', function () {
            var index = $('.alert-block i.icon-remove').index(this);
            var Now = new Date();
            var expire = new Date(Now.valueOf() + 60000 * 60 * 24 * 7);
            index = value + index;
            document.cookie = "alertBlock=" + index + ";expires=" + expire.toGMTString() + ";";

        })
    };

    var scrollBar = function () {
        var elem = $('.sly .open.active').get(0);
        var offsetTop = elem ? elem.offsetTop : 0;

        var height = window.screen.availHeight;
        $(".sly").slimscroll({height: height - 230 + 'px', size: '4px', color: '#000', wheelStep: 10, scrollTo: '100px'}).bind('slimscrolling', function (e, pos) {
            // console.log("Reached " + pos)
        }).slimScroll({ scrollBy: offsetTop });
    };
    return {
        init: function (options) {
            showAlertByCookie();
            base();
            showQR();
            divToggleByRadio();
            siteCont();
            handleModal(options);
            dropdownToggle();
            handleTabs(options);
            mvcHandler();
            notifyHandler();
            handleRender();
            toggleShow();
            selectTab();
            // fileup();
            handelMater();
            radioTab();
            topNav();
            dataFilter();
            step();
            scrollBar();
        }
    }
}();
jQuery(function ($) {
    App.init();
    fileup();
});
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
    if (text) {
        var type = "text";
    } else {
        var type = "iframe";
    }
    var html = '<div class="modal fade modal-' + type + '" id="' + id + '" data-backdrop="static">' +
        '<div class="modal-dialog" style="width: ' + w + 'px;">' +
        '<div class="modal-content">' +
        '<div class="modal-header">' +
        '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
        '<h4 class="modal-title">' + title + '</h4>' +
        '</div><form role="form" action="' + action + '" method="' + method + '">';
    if (text && text != "") {
        html += '<div class="modal-body">' +
            '<div class="text-center">' + text + '</div></div>' +
            '<div class="clearfix"></div>';
        if (btns > 0) {
            html += '<div class="modal-footer">';
            if (btns == 1) {
                html += '<button type="button" class="btn btn-sm btn-primary" data-dismiss="modal">确定</button>';
            } else {
                html += '<button type="button" class="btn btn-sm btn-primary" data-fn="submit">确定</button>' +
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
    $('#' + id).modal('show');
    return false;
}
function drawTree() {
    return {
        treeUp: function () {
            $(document).on('click', '[data-toggle="treeUp"]', function () {
                var self = $(this),
                    id = self.parents(".tree-tools").attr("data-id"),
                    li = $(self.parents(".tree-li")[0]),
                    type = self.parents(".tree-li")[0].className.replace(" tree-li", "");
                var html = "";
                $.each(li, function (i) {
                    var r = li[i].outerHTML;
                    if (r) {
                        html += r;
                    }
                });
                var prev = li.prev();
                if (prev.length >= 1) {
                    prev.before(html);
                    li.remove();
                }
            });
        },
        treeDown: function () {
            $(document).on('click', '[data-toggle="treeDown"]', function () {
                var self = $(this),
                    id = self.parents(".tree-tools").attr("data-id"),
                    li = $(self.parents(".tree-li")[0]);
                var html = "";
                $.each(li, function (i) {
                    var r = li[i].outerHTML;
                    if (r) {
                        html += r;
                    }
                });
                var next = li.next();
                if (next.length >= 1) {
                    next.after(html);
                    li.remove();
                }
            });
        },
        treeRemove: function () {
            $(document).on('click', '[data-toggle="treeRemove"]', function () {

            });
        }
    }
}
function getTokenBucket(url) {
    var r = $.ajax({
        type: "Get",
        url: url,
        async: false,
        context: document.body,
        success: function (data) {
        }
    });
//    if(r){
//        r = $.parseJSON(r.responseText);
//        r = [r.data.BUCKET, r.data.token];
//    }
    return r;
}
function fileup() {
   // var tb = getTokenBucket("http://notes18.com/notes/15/entries/443.json?ownership_token=4317af51-dfc6-470f-87b7-56fb38cb2eec"),
   //      token = tb[1],
   //      bucket = tb[0],
    var token = "rnSju14NS7v0hiwky1SMMJhGogoUkOme0lLERyQP:qstfzMgBGV7agkuDEtIonRcb338=:eyJzY29wZSI6ImltZy1hc3NldCIsImRlYWRsaW5lIjoxNDU3Njg4NDM4fQ==",
    bucket = "img-asset"
    $(".cieldon-file").cieldonfileupload({
        token: token,
        bucket: bucket
    });
}
function fileup_for_material() {
    $(".cieldon-file").cieldonfileupload({
        token: $('#file-upload-token').attr('data-token'),
        bucket: $('#file-upload-token').attr('data-bucket')
    });
}
function hideModals() {
    var dc = $(parent.document),
        $modal = dc.find('.modal'),
        $modalBg = dc.find(".modal-backdrop")
    $modal.attr('aria-hidden', true).removeClass('in');
    $modalBg.remove();
    $(parent.document.body).removeClass('modal-open');
    $modal.remove();
}
var dateTimeHandler = function () {
    $('input[class*="daterange"]').attr('readonly', 'readonly').daterangepicker({
        format: 'YYYY-MM-DD'
    });
    $('input[class*="datetimerange"]').attr('readonly', 'readonly').daterangepicker({
        timePicker: true,
        format: 'YYYY-MM-DD HH:mm'
    });
    $('input[class*="date-range-second"]').attr('readonly', 'readonly').daterangepicker({
        timePicker: true,
        format: 'YYYY-MM-DD HH:mm'
    });

    $('input[class*="datepicker"]').attr('readonly', 'readonly').datepicker({
        todayBtn: "linked",
        autoclose: true,

        format: "yyyy-mm-dd"
    });
    $('input[class*="date-time"]').attr('readonly', 'readonly').datetimepicker({
        autoclose: true,
        todayBtn: true,
        language: "zh"
    });

    $('input[class*="date-min-time"]').attr('readonly', 'readonly').daterangepicker({
        timePicker: true,
        singleDatePicker: true,
        format: 'YYYY-MM-DD HH:mm',
        minDate: moment().subtract('days', 1)
    });

    function timepicker(){
        $('input[class*="timepicker"]').attr('readonly', 'readonly').clockpicker({
            autoclose: true
        });

        $('input[class*="timeFrom"]').attr('readonly', 'readonly').change(function(){
            var time=$(this).val();
            $(this).next().next('input').attr('readonly', 'readonly').val(time);
        });
        $('input[class*="timeTo"]').attr('readonly', 'readonly').change(function(){
            var $to=$(this)
            to=$to.val().split(":"),
                $from=$(this).prev().prev('input'),
                from=$from.val().split(":");
            if(parseInt(to[0])<parseInt(from[0])){
                $(this).val($from.val());
            }else if(to[0]==from[0]){
                if(parseInt(to[1])<parseInt(from[1])){
                    $(this).val($from.val());
                }
            }
        });
    }
    timepicker();
    $(".mod-add-cancel").click(function(e){
        var self=$(e.target);
        if(self.hasClass("btn-add")){
            var html='<div class="input-group input-group-text input-group-sm margin-b-10">'+
                     '<input type="text" class="timepicker timeFrom">'+
                     '<span class="input-group-btn">　~　</span>'+
                     '<input type="text" class="timepicker timeTo">'+
                     '<span class="input-group-btn">'+
                     '<button class="btn btn-cancel" type="button">删除</button>'+
                     '</span>'+
                     '</div>';
            self.after(html);
            timepicker();
        }else if(self.hasClass("btn-cancel")){
            self.parents("div.input-group").remove();
        }
    });
};
$(function () {
    dateTimeHandler();
    $(".widget-box").wizard();
    vcScroll();
});
function radioTab() {
    $('input[data-toggle=radioTab]').on('click', function () {
        var target = $(this).data('target');
        var $target = $('#' + target);

        $target.removeClass('hide').siblings().addClass('hide');
    });

}
function vcScroll() {
    $('[data-scroll]').on("click", function () {
        var $this = $(this),
            $id = "#" + $this.attr("data-scroll"),
            $content = $($id),
            $flag = $content.find(".iScrollVerticalScrollbar").length,
            myScroll;
        if (!$flag) {
            setTimeout(load, 500);
        }
        function load() {
            myScroll = new IScroll($id, {
                scrollbars: true,
                mouseWheel: true,
                interactiveScrollbars: true,
                shrinkScrollbars: 'scale',
                fadeScrollbars: true,
                click: true
            });
            document.addEventListener('DOMContentLoaded', function (e) {
                e.preventDefault();
            }, false);
        }
    });
}
function ace_wysiwygFn() {
    $('.wysiwyg-editor').ace_wysiwyg({
        toolbar: [
            'font',
            null,
            'fontSize',
            null,
            {name: 'bold', className: 'btn-info'},
            {name: 'italic', className: 'btn-info'},
            {name: 'strikethrough', className: 'btn-info'},
            {name: 'underline', className: 'btn-info'},
            null,
            {name: 'insertunorderedlist', className: 'btn-success'},
            {name: 'insertorderedlist', className: 'btn-success'},
            {name: 'outdent', className: 'btn-purple'},
            {name: 'indent', className: 'btn-purple'},
            null,
            {name: 'justifyleft', className: 'btn-primary'},
            {name: 'justifycenter', className: 'btn-primary'},
            {name: 'justifyright', className: 'btn-primary'},
            {name: 'justifyfull', className: 'btn-inverse'},
            null,
            {name: 'createLink', className: 'btn-pink'},
            {name: 'unlink', className: 'btn-pink'},
            null,
            {name: 'insertImage', className: 'btn-success'},
            {name: 'insertVideo', className: 'btn-success'},
            {name: 'insertAudio', className: 'btn-success'},
            {name: 'insertTel', className: 'btn-grey'},
            {name: 'insertTable', className: 'btn-grey'},
            null,
            'foreColor',
            null,
            {name: 'undo', className: 'btn-grey'},
            {name: 'redo', className: 'btn-grey'},
            {name: 'viewSource', className: 'btn-grey'}
        ],
        'wysiwyg': {
            //fileUploadError: showErrorAlert
        }
    }).prev().addClass('wysiwyg-style1');
}
function ueadd(){
    UE.registerUI('simpleupload', function(editor, uiName) {
        var toolbars = editor.getOpt("toolbars");
        if(toolbars[0].indexOf("imgupload") >= 0){
            return addUI();
        }
        function addUI(){
            var btn = new UE.ui.Button({
                name: uiName,
                title: '上传图片',
                onclick: function() {
                    var flag = $("#addueinput").length;
                    if(!flag){
                        $('body').append('<input type="file" id="addueinput" style="position:absolute; left:-99999px; top:0;">');
                    }
                    $('#addueinput').click();
                }
            });
            addImg(editor);
            return btn;
        }
    },10);
}
function addImg(ueditor){
    $('body').on('change','#addueinput',function(){
        var $this = $(this),
            len = $this.val().length,
            sta = $(this).val().lastIndexOf(".")+1,
            getname = $(this).val().substr(sta,len);
        if(getname!="jpg" && getname!="png" && getname!="gif" && getname!="JPG"){
            $.alert({"msg":'上传格式文件不正确'});
            return false;
        }
        var Qiniu_UploadUrl = "http://up.qiniu.com";
        var xhr = new XMLHttpRequest();
        xhr.open('POST', Qiniu_UploadUrl, true);
        var formData, startDate;
        var f = $(this).get(0).files[0];
        formData = new FormData();
        formData.append('token', token);
        formData.append('file', f);
        var taking;
        xhr.onreadystatechange = function(response) {
            if (xhr.readyState == 4 && xhr.status == 200 && xhr.responseText != "") {
                var blkRet = JSON.parse(xhr.responseText);
                var imgUrl='http://'+bucket+'.winwemedia.com/'+blkRet.key;
                ueditor.execCommand('insertHtml', '<img src="'+imgUrl+'" />')
            }
        };
        startDate = new Date().getTime();
        xhr.send(formData);
        $this.remove();
    });
}
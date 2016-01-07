/**
 * Created by pan on 14-5-28.
 startDay  开始显示内容日期，整数，0为当前时间，往前为负数，往后为正数
 endDay  结束显示内容日期。0为不限制。
 */

;
(function ($) {
    var Calendar = function (e,options, y, m) {
        var defaults ={
            startDay: 0,
            endDay: 0,
            html: ""
        };
        var opt = $.extend({},defaults,options);
        var optHtml = opt.html;
        var D = new Date();//获取日期
        var Y = y || D.getFullYear();//获取当前年
        var M = m >= 0 ? m : D.getMonth();//获取当前月
        var DaysNum = daysNum(Y, M);//获取当前月天数
        var T = D.getDate();//今天
        var startDay = new Date (new Date().setDate(new Date().getDate() + opt.startDay));
        // var endDay = opt.endDay ? new Date(new Date().setDate(D.getDate() + opt.endDay)) : null;
        var FW = weekdayOffirstday(Y, M);//当月第一天是星期几 0（周日） 到 6（周六）
        var RWD = restWeekDay(FW);// 0（周一） 到 6（周日）
        var totalNum = getTotalNum(DaysNum, RWD);//日历显示总天数
        var $calendar = $(e);
        var YList = "<select data-cal-select='year'>";
        for (var i = 1970; i < 2050+1; i++) {
            if (i == Y) {
                YList += '<option selected value="' + i + '">' + i + '</option>'
            } else {
                YList += '<option value="' + i + '">' + i + '</option>'
            }
        }
        YList += "</select>";
        var MList = "<select data-cal-select='month'>";
        for (var i = 1; i < 13; i++) {
            if (i == M + 1) {
                MList += '<option selected value="' + i + '">' + i + '</option>'
            } else {
                MList += '<option value="' + i + '">' + i + '</option>'
            }
        }
        MList += "</select>";

        var $header = '<div class="cal-select"><i data-toggle="cal-prev" class="fa fa-arrow-left"></i>' +
            '<span>' + YList + '年' + MList + '月' + '</span>' +
            '<i data-toggle="cal-next" class="fa fa-arrow-right"></i></div>';

        $header += '<div class="cal-row-fluid cal-head">' +
            '<div class="cal-cell1">周一</div>' +
            '<div class="cal-cell1">周二</div>' +
            '<div class="cal-cell1">周三</div>' +
            '<div class="cal-cell1">周四</div>' +
            '<div class="cal-cell1">周五</div>' +
            '<div class="cal-cell1">周六</div>' +
            '<div class="cal-cell1">周日</div></div>';

        var cont = "";
        for (var i = 0; i < totalNum; i++) {
            if (i < RWD) {
                cont += Y + "-" + M + "-" + (daysNum(Y, M - 1) - (RWD - 1 - i)).toString() + " ";
            } else {
                var s = i - RWD + 1;
                if (s > DaysNum) {
                    cont += Y + "-" + (M + 2) + "-" + (s - DaysNum).toString() + " ";
                }
                else {
                    cont += Y + "-" + (M + 1) + "-" + s + " ";
                }
            }
        }
        cont = cont.substr(0, cont.length - 1).split(" ");//日期数组

        var $body = '<div class="cal-month-box"><div class="cal-row-fluid">';
        for (var i = 0, l = cont.length; i < l; i++) {
            var date = cont[i];

            var weekend =dayClass = "";
            if(i % 7 >= 5){
                dayClass = "cal-day-weekend";
            }
            if(date.split("-")[1] < M + 1){
                dayClass += " cal-day-oldmonth";
            }else if(date.split("-")[1] > M + 1){
                dayClass += " cal-day-newmonth";
            }
            weekend = '<div class="cal-month-day '+dayClass+'"><span class="pull-right" data-cal-date="' + date + '">' + date.split("-")[2] + '</span></div>';

            $body += '<div class="cal-cell1 cal-cell">' + weekend + '</div>';
            if ((i + 1) % 7 == 0) {
                $body += '</div><div class="cal-row-fluid">'
            }
        }
        $body += '</div></div>';

        $calendar.html($header + $body);
        $calendar.find('i[data-toggle]').click(function () {
            var $this = $(this);
            var dir = $(this).data('toggle');
            M = dir === 'cal-prev' ? M - 1 : M + 1;
            if (M < 0) {
                M = 11;
                Y--;
            }
            if (M > 11) {
                M = 0;
                Y++;
            }
            Calendar(e,options, Y, M)
        });

        $calendar.find('.cal-month-day [data-cal-date]').after(function () {
            var st = $(this).attr("data-cal-date");
            var a = st.split("-");
            var selDate = new Date(a[0],(a[1]-1),a[2]);
            var num =Math.ceil((selDate - startDay) /1000/60/60/24);

            if(opt.endDay){
                if(num>=0&&num<=opt.endDay){
                    return opt.html[parseInt(num)];
                }
            }else{
                return opt.html[parseInt(num)];
            }
        });
        $calendar.find('select[data-cal-select]').change(function () {
            var $self = $(this);
            var type = $(this).data('cal-select');
            var val = parseInt($self.val());
            if (type == 'year') {
                Calendar(e,options,val, M);
            }
            else {
                Calendar(e,options, Y, val - 1);
            }
        });

        renderModal(e);
    };
    var renderModal = function (e) {
        var $calendar = $(e);
        $calendar.find('.cal-info-edit').on('click', function () {
            var $peopleList = $(this).prev();
            var $peoplesType = $peopleList.find('[data-type]');
            // console.log($peoplesType.length);

            var people = '<form class="form clearfix"><div class="trip-price-set">';
            for (var i = 0; i < $peoplesType.length; i++) {
                var $person = $peoplesType.eq(i);

                if(i!=0){
                    people+='</div><div class="trip-price-set">';
                    people += '<span>' + $person.html() + '</span>'+
                        '<div class="form-group"><label>价格</label><div class=""><input type="text" value="'+$person.data('price')+'"></div></div>' +
                        '<div class="form-group"><label>数量</label><div class=""><input type="text" value="'+$person.data('numbers')+'"></div></div>';
                }
                else{
                    people += '<span>' + $person.html() + '</span>'+
                        '<div class="form-group"><label>价格</label><div class=""><input type="text" value="'+$person.data('price')+'"></div></div>' +
                        '<div class="form-group"><label>数量</label><div class=""><input type="text" value="'+$person.data('numbers')+'"></div></div>';
                }
                // console.log($person.data('price'), $person.data('numbers'), $person.html());
            }
            people += '</div></form>';
            var modal = '<div class="modal fade cal-info-details" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">' +
                '<div class="modal-dialog"><div class="modal-content">' +
                '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
                '<h4 class="modal-title" id="myModalLabel">编辑旅游信息</h4></div>' +
                '<div class="modal-body">' + people + '</div>' +
                '<div class="modal-footer">' +
                '<button type="button" class="btn btn-primary btn-sm">确定</button>' +
                '<button type="button" class="btn btn-default btn-sm" data-dismiss="modal">取消</button></div>';
            $('.cal-info-details').remove();
            $('body').append(function () {
                return modal;
            });
            $('.cal-info-details').modal('show');

        });
    };

    var getTotalNum = function (daysNum, rwd) {
        return Math.ceil((daysNum + rwd) / 7) * 7;
    };
    var restWeekDay = function (num) {
        if (num != 0) {
            return num - 1;
        }
        else {
            return 6;
        }
    };
    var daysNum = function (year, month) {
        month = parseInt(month, 10);
        var d = new Date(year, month + 1, 0);
        return d.getDate();
    };
    var weekdayOffirstday = function (year, month) {
        month = parseInt(month, 10);
        var firstDay = new Date(year, month, 1);
        return firstDay.getDay();
    };
    $.fn.calendar = function (options) {
        return new Calendar(this,options);
    };

}(jQuery));
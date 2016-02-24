// 表单错误信息提示
function checkInput(obj, type, msg){
    var tips = '<div class="m-tips {type}">{msg}</div>';
    var typeClass = "m-tips-error";
    switch(type){
        case 1:
            typeClass = "m-tips-success";
            break;
        case 2:
            typeClass = "m-tips-msg";
            break;
    }
    tips = tips.replace(/{msg}/, msg).replace(/{type}/, typeClass);

    obj.find(".m-tips").remove();
    obj.append(tips);
}

function checkInputDel(collection){
    collection.each(function(){
        $(this).find(".m-tips").remove();
    });
}

// select simulation
function selectSimulation(){
    // 生成模拟标签
    var select = $(".m-select");

    var selectSimuDdOriginalWidth = [];
    var selectSimuDdWidth = [];
    var selectSimuDdFontSize = 14 + 2;

    // select联动更新
    var updateSelectSimulation = this.updateSelectSimulation =  function(sindex, setOriginal){
        var defaultFullTxt = "";
        var defaultTxt = "";
        var listTpl = '<div class="m-select-simu-item">{select_item}</div>';
        var listHtml = "";
        var characterLen = 0;

        $(".m-select-real").eq(sindex).find("option").each(function(i){
            var txt = $(this).text();
            var currCharacterLen = txt.length;
            // if(i == 0){
            if(this.selected){
                // 截取适当长度的字符显示在默认项
                defaultFullTxt = txt;
                defaultTxt = txt.substring(0, 6) + '<span class="m-select-simu-trip"></span>';
            }
            listHtml += listTpl.replace(/{select_item}/, txt);

            // 获取这个select列表中字符最大的个数                    
            characterLen = (currCharacterLen > characterLen) ? currCharacterLen : characterLen;
        });

        // 将本select的最大的字符数保存
        selectSimuDdWidth[sindex] = characterLen * selectSimuDdFontSize + 20 * 2;

        // 生成dd内列表内容并更新到文档
        listHtml = '<div class="m-select-simu-scroll">' + listHtml + '</div>';
        $(".m-select-simu").eq(sindex).find(".m-select-simu-dt").html(defaultTxt).attr("data-dt", defaultFullTxt);
        $(".m-select-simu").eq(sindex).find(".m-select-simu-dd").html(listHtml);

        // 设置当前模拟的select列表的宽度
        var currDd = $(".m-select-simu-dd").eq(sindex);
        // 初始化时调用
        if(setOriginal){
            selectSimuDdOriginalWidth[sindex] = currDd.outerWidth(true);
        }

        console.log(selectSimuDdWidth[sindex], characterLen * selectSimuDdFontSize + 20 * 2)
        selectSimuDdWidth[sindex] = (selectSimuDdWidth[sindex] > selectSimuDdOriginalWidth[sindex]) ? selectSimuDdWidth[sindex] : selectSimuDdOriginalWidth[sindex];
        currDd.css({"width": selectSimuDdWidth[sindex]});

        // 生成下拉滚动条
        var currDdScroll = $(".m-select-simu-scroll").eq(sindex);
        if(currDdScroll.find(".m-select-simu-item").length > 4){
            currDdScroll.slimScroll({
                height: 120
            })
        }
    }

    select.each(function(){
        var _select = $(this);

        var selectReal = _select.find("select");
        var selectSimu = null;
        var tpl = '<dl class="m-select-simu m-select-simu-index{m_select_simu_index}">\
                        <dt class="m-select-simu-dt select-focus"><span class="m-select-simu-trip"></span></dt>\
                        <dd class="m-select-simu-dd select-focus"></dd>\
                    </dl>';

        selectReal.each(function(i){
            var self = $(this);
            var selected = self.find(":selected");
            var newTpl = tpl;

            newTpl = newTpl.replace(/{m_select_simu_index}/, i);
            _select.append(newTpl);

            updateSelectSimulation(i, true)

        });

        selectSimu = _select.find(".m-select-simu");

        // 模拟select动作
        _select.on("click", ".m-select-simu", function(e){
            var self = $(this);
            select.find(".m-select-simu-dd").hide();
            self.find(".m-select-simu-dd").show();

            select.find(".m-select-simu-dt").removeClass("focus");
            self.find(".m-select-simu-dt").addClass("focus");

            select.find(".m-select-simu").css({"z-index": "auto"});
            self.css({"z-index": 999999});
            e.stopPropagation();
        }).on("click", ".m-select-simu-item", function(e){
            var self = $(this);
            var dt = $(this).closest(".m-select-simu-dd").hide().prev(".m-select-simu-dt");
            var selectIndex = selectSimu.index(self.closest(".m-select-simu"));
            var optionIndex = $(this).index();
            var txtDt = dt.attr("data-dt");
            var txtThis = $(this).text();
            var txt = txtThis.substring(0, 6) + '<span class="m-select-simu-trip"></span>';

            dt.html(txt);
            dt.attr("data-dt", txtThis);
            selectReal.eq(selectIndex).find("option").eq(optionIndex).prop("selected", true);
            self.closest(".m-select-simu-dd").prev(".m-select-simu-dt").removeClass("focus");

            // 触发原生select的change事件
            if($.trim(txtThis) != txtDt){
                selectReal.eq(selectIndex).trigger("change");
            }

            e.stopPropagation();
        });
        $(document).on("click", function(){
            select.find(".m-select-simu-dt").removeClass("focus");
            select.find(".m-select-simu-dd").hide();
        });
    });

    // 生成下拉滚动条
    $(".m-select-simu-scroll").each(function(i){
        if($(this).find(".m-select-simu-item").length > 4)
            $(this).slimScroll({
                height: 120
            })
    });
}

//select联动
function address_select(selectSimuObj) {
    $('#province').change( function() {
        var province_id = $(this).val();
        var $city_select = $('#city');
        var $district_select = $('#district');
        $city_select.empty();
        $district_select.empty();
        var get_url = "/addresses/cities?province_id=" + province_id;
        $.get(get_url, function(data) {
            for(var i = 0; i < data.citys.length; i++) {
                $city_select.append("<option value='"+data.citys[i][1]+"'>"+data.citys[i][0]+"</option>");
            }
            $city_select.filter('option:eq(0)').selected = true;
            // 更新模拟select UI
            selectSimuObj.updateSelectSimulation($("#city").index(".m-select-real"));
            $("#city").change();
        });
    });

    $('#city').change( function() {
        var city_id = $(this).val();
        var $district_select = $('#district');
        $district_select.empty();
        var get_url = "/addresses/districts?city_id=" + city_id;
        $.get(get_url, function(data) {
            for(var i = 0; i < data.districts.length; i++) {
                $district_select.append("<option value='"+data.districts[i][1]+"'>"+data.districts[i][0]+"</option>");
            }
            if(data.districts.length == 0){
                $district_select.append("<option value='-1'></option>");
            }
            $district_select.filter('option:eq(0)').selected = true;

            // 更新模拟select UI
            selectSimuObj.updateSelectSimulation($("#district").index(".m-select-real"));
        });
    });
}


$(function(){
    var selectSimu = new selectSimulation();
    address_select(selectSimu);
    $("#city").trigger('change');

    // 调整登录注册页底部位置
    (function(){
        if($(".member").length){
            var footer = $(".footer-wrapp");
            var main = $(".m-main");
            var h_top = $(".header-m").outerHeight(true);
            var h_mid = main.outerHeight(true);
            var h_bot = footer.outerHeight(true);
            var h_all = h_top + h_mid + h_bot;
            var m_top = parseInt(main.css("margin-top"));

            $(window).resize(function(){
                var h_win = $(window).height();
                var diff = h_win - h_all;
                if(diff > 0){
                    footer.addClass("footer-fixed");
                    main.css({"margin-top": m_top+diff/2})
                }
                else{
                    footer.removeClass("footer-fixed");
                    main.css({"margin-top": m_top})
                }
            }).trigger("resize");
        }
    })();

});
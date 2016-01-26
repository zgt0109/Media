window.vcardTplCollection = [
    {
        'tplId': 'tpl01',
        'tplName': '模板一',
        'cardBg': 'http://media-asset.winwemedia.com/Flku4iCXcXKeO7GynEga3oXRxS1o',
        'cardLevel': {
            'fontSize': 26,
            'left': 398,
            'top': 132,
            'color': '#eb5c87'
        },
        'cardNumber': {
            'fontSize': 34,
            'left': 224,
            'top': 170,
            'color': '#eb5c87'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/FoVDc2ZFnTvUyHcWGWrPv-7TmYAp',
            'left': 225,
            'top': 113
        }
    },
    {
        'tplId': 'tpl02',
        'tplName': '模板二',
        'cardBg': 'http://media-asset.winwemedia.com/FojmpIvtIiCLmrq6SbhvS_Ppv9LT',
        'cardLevel': {
            'fontSize': 22,
            'left': 244,
            'top': 192,
            'color': '#c6a064'
        },
        'cardNumber': {
            'fontSize': 20,
            'left': 203,
            'top': 225,
            'color': '#c6a064'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/FgmxAVlwK6TjIuesxKk2kQ8rtzwq',
            'left': 199,
            'top': 56
        }
    },
    {
        'tplId': 'tpl02',
        'tplName': '模板三',
        'cardBg': 'http://media-asset.winwemedia.com/FgszfS6KkSNPebOHTgDT3-vejLEQ',
        'cardLevel': {
            'fontSize': 20,
            'left': 255,
            'top': 193,
            'color': '#8d3e7f'
        },
        'cardNumber': {
            'fontSize': 20,
            'left': 210,
            'top': 222,
            'color': '#8d3e7f'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/FgQPfTdI5MLz7bro6XXWqOB0T0XH',
            'left': 203,
            'top': 97
        }
    },
    {
        'tplId': 'tpl02',
        'tplName': '模板四',
        'cardBg': 'http://media-asset.winwemedia.com/Fp3On2CVsdQiNuJON6usT56SeudE',
        'cardLevel': {
            'fontSize': 30,
            'left': 228,
            'top': 224,
            'color': '#e3ca67'
        },
        'cardNumber': {
            'fontSize': 20,
            'left': 194,
            'top': 270,
            'color': '#e3ca67'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/FnnO5xjARHmKIhUtqUr8GluyxKca',
            'left': 196,
            'top': 24
        }
    },
    {
        'tplId': 'tpl02',
        'tplName': '模板五',
        'cardBg': 'http://media-asset.winwemedia.com/FvvOycYhqfJ0GdDeXYW730H2ogYA',
        'cardLevel': {
            'fontSize': 28,
            'left': 23,
            'top': 234,
            'color': '#fff'
        },
        'cardNumber': {
            'fontSize': 24,
            'left': 23,
            'top': 272,
            'color': '#fff'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/Fif2eW4973SRKb_bGPGFY2yvzyUH',
            'left': 9,
            'top': 4
        }
    },
    {
        'tplId': 'tpl02',
        'tplName': '模板六',
        'cardBg': 'http://media-asset.winwemedia.com/FiQemPYveZBw03824hnewDXJfOdj',
        'cardLevel': {
            'fontSize': 12,
            'left': 320,
            'top': 45,
            'color': '#fff'
        },
        'cardNumber': {
            'fontSize': 14,
            'left': 221,
            'top': 243,
            'color': '#fff'
        },
        'cardLogo': {
            'src': 'http://media-asset.winwemedia.com/FhLscZX58OWDhYPJxUQkaO1LpNyR',
            'left': 195,
            'top': 115
        }
    }
];

window.vcardTplHtml = '<div class="vcard-item">\
                            <div class="vcard-item-tit">{{tplName}}</div>\
                            <div class="vcard-item-cardwp">\
                                <div class="vcard-card vcard-item-card" style="background-image: url({{cardBg}});">\
                                    <div class="vcard-elem vcard-level">会员卡</div>\
                                    <div class="vcard-elem vcard-logo"><img src="/assets/vcard/vcard_tpl_logo.png" alt="" /></div>\
                                    <div class="vcard-elem vcard-number">No. 2015236541</div>\
                                </div>\
                            </div>\
                        </div>';

window.vcardTplList = '<div class="vcard-item">\
                            <div class="vcard-item-name">{{cardLevel}}</div>\
                            <div class="clearfix vcard-item-btns">\
                                <input type="button" class="vcard-btn vcard-btn-selecttpl vcard-left" value="选择模版">\
                                <input type="button" class="vcard-btn vcard-btn-uploadbg vcard-right" value="上传背景图">\
                                <input type="file" class="vcard-hidden">\
                            </div>\
                            <div class="vcard-item-cardwp">\
                                <div class="vcard-card vcard-item-card" style="background-image: url({{cardBg}})">\
                                    <div class="vcard-elem vcard-level">{{cardLevel}}</div>\
                                    <div class="vcard-elem vcard-logo"><img src="{{cardLogoSrc}}" alt=""></div>\
                                    <div class="vcard-elem vcard-number">{{cardNumber}}</div>\
                                </div>\
                            </div>\
                            <div class="form-group">\
                                <label for="">会员卡名称颜色</label>\
                                <input class="vcard-btn vcard-color vcard-color-level" type="button" data-color="{{cardLevelColor}}">\
                            </div>\
                            <div class="form-group">\
                                <label for="">会员卡号码颜色</label>\
                                <input class="vcard-btn vcard-color vcard-color-number" type="button" data-color="{{cardNumberColor}}">\
                            </div>\
                        </div>';
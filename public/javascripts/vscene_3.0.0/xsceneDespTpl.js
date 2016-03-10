/*
如下是描述一个微场景的数据结构
[
    tplScene: {
        'bgSrc': null,
        'bgColor': null,
        'elems': [
            tplImg,
            tplTxt,
            tplBtn
        ]
    },
    tplScene: {
        'bgSrc': null,
        'bgColor': null,
        'elems': [
            tplImg,
            tplTxt,
            tplBtn
        ]
    }
]
*/

;(function(obj){

    obj.xsceneDespTpl = {
        scene: {
            'elems': [],
            'name': '新建页面',
            'backgroundImage': 'none',
            'backgroundColor': 'rgba(255, 255, 255, 1)',
            'data-href': '',
            'data-href-sys': '',
            'data-href-http': '',
            'data-href-tel': '',
            'data-href-type': 'none' // http/tel
        },
        img: {
            type: 'img',
            props: {
                'src': 'http://img-asset.winwemedia.com/Ftvknu0qGnfzDRjh4Jn-tYc3nAaV',  //图片路径
                // 'src': '../../assets_vscene_3.0.0/images/vscene_3.0.0/scene_elem_img_default.png',  //图片路径
                'width': 30,    //宽度
                'left': 50,  //横向坐标
                'top': 40,  //纵向坐标
                'animationName': 'none',   // noEffect/fadeIn/top/bottom/left/right/rollover(翻转)
                'animationDelay': 0.5,  // 开始时间(单位/秒)
                'animationDuration': 2,  //链接
                'data-href': '',
                'data-href-sys': '',
                'data-href-http': '',
                'data-href-tel': '',
                'data-href-type': 'none' // http/tel
            }
        },
        txt: {
            type: 'txt',
            props: {
                // 'html': '在此编辑文字',
                'html': '请输入文本内容',
                'width': 60,
                'height': 60,
                'left': 50,  //横向坐标
                'top': 40,  //纵向坐标
                'animationName': 'none',
                'animationDelay': 0.5,
                'animationDuration': 2,
                'data-href': '',
                'data-href-sys': '',
                'data-href-http': '',
                'data-href-tel': '',
                'data-href-type': 'none', // http/tel/sys
                'backgroundColor': 'rgba(255, 255, 255, 0)',
                'verticalAlign': 'top',
                'paddingLeft': '0',
                'paddingRight': '0',
                'paddingTop': '0',
                'paddingBottom': '0',
                'borderStyle': 'none',
                'borderColor': 'rgba(204, 204, 204, 1)',
                'borderWidth': 1
            }
        },
        btn: {
            type: 'btn',
            props: {
                'text': '按钮名称',
                'width': 40,
                'left': 50,  //横向坐标
                'top': 40,  //纵向坐标
                'animationName': 'none',
                'animationDelay': 0.5,
                'animationDuration': 2,
                'data-href': '',
                'data-href-sys': '',
                'data-href-http': '',
                'data-href-tel': '',
                'data-href-type': 'none', // http/tel
                'fontSize': 12,
                'addClass': 'xscene-btn1'
            }
        },
        video: {
            type: 'video',
            props: {
                'src': 'http://img-asset.winwemedia.com/Fu8TQ4BQv3rtoFZ8lOtIGp8s-EyE',
                'width': 30,
                'left': 50,  //横向坐标
                'top': 40,  //纵向坐标
                'data-video': '',
                'animationName': 'none',
                'animationDelay': 0.5,
                'animationDuration': 2,
            }
        },
        mapAction: {  // 一个映射表，属性对应到一个相应的操作
            'html': 'html',
            'text': 'text',
            'addClass': 'addClass',
            'src': 'image',
            'width': 'css',
            'height': 'css',
            'left': 'css',
            'top': 'css',
            'animationName': 'css',
            'animationDelay': 'css',
            'animationDuration': 'css',
            'data-href': 'attr',
            'data-href-sys': 'attr',
            'data-href-http': 'attr',
            'data-href-tel': 'attr',
            'data-href-type': 'attr',
            'data-video': 'attr',
            'backgroundColor': 'css',
            'backgroundImage': 'cssBgImage',
            'verticalAlign': 'css',
            'paddingLeft': 'css',
            'paddingRight': 'css',
            'paddingTop': 'css',
            'paddingBottom': 'css',
            'borderStyle': 'css',
            'borderColor': 'css',
            'borderWidth': 'css',
            'opacity': 'css',
            'fontSize': 'css'
        },
        mapUnit: {  // 一个映射表，属性对应到相应的单位
            'width': '%',
            'height': 'px',
            'left': 'px',
            'top': 'px',
            'animationDelay': 's',
            'animationDuration': 's',
            'paddingLeft': 'px',
            'paddingRight': 'px',
            'paddingTop': 'px',
            'paddingBottom': 'px',
            'borderWidth': 'px',
            'fontSize': 'px'
        }
    }

})( window.xconfig = window.xconfig ? window.xconfig : {} );
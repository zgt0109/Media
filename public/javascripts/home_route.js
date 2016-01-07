// 首页的一些路由
//一个储存我们路径的哈希表   
var routes = {};
//路径注册函数    
function route(path,templateId,controller){
  routes[path] = {templateId: templateId, controller: controller};
}

//初始化路由表
route('','business',function(){
  var data = {
    "title": "社会化媒体时代商业新模式，O2O聚财新体验",
    "picture": "business",
    "icons": {
      "sqdt":"商圈地图",
      "spgl":"商品管理",
      "hyyh":"会员优惠",
      "fldh":"分类导航",
      "dpgl":"店铺管理"
    },
    "erweima": {
      "kjt":"跨境通",
      "zpwd":"周浦万达"
    }
  };
  return data;
});
route('business','business',function(){
  var data = {
    "title": "社会化媒体时代商业新模式，O2O聚财新体验",
    "picture": "business",
    "icons": {
      "sqdt":"商圈地图",
      "spgl":"商品管理",
      "hyyh":"会员优惠",
      "fldh":"分类导航",
      "dpgl":"店铺管理"
    },
    "erweima": {
      "kjt":"跨境通",
      "zpwd":"周浦万达"
    }
  };
  return data;
});
route('food','food',function(){
  var data = {
    "title": "订座、点餐节约时间，有效提高客流量",
    "picture": "food",
    "icons": {
      "cdgl":"菜单管理",
      "czgl":"餐桌管理",
      "dzgl":"订座管理",
      "mdgl":"门店管理",
      "wcy":"微餐饮",
      "yygl":"预约管理"
    },
    "erweima": {
      "bd":"巴顿火锅",
      "dw":"东莞朝天门",
      "jy":"今钰点心",
      "jl":"骏萊海鲜魚港",
      "bc":"泊翠餐饮",
      "uk":"U可时尚餐厅",
      "df":"大蚨老汤火锅面馆"
    }
  };
  return data;
});
route('shop','shop',function(){
  var data = {
    "title": "社会化媒体时代商业新模式，O2O聚财新体验",
    "picture": "shop",
    "icons": {
      "ddgl":"订单管理",
      "plhd":"评论互动",
      "spgl":"商品管理",
      "zfgl":"支付管理"
    },
    "erweima": {   
      "dms":"多美思",
      "gab":"关爱宝",
      "kyl":"康云来服饰",
      "kjt":"跨境通",
      "nn":"牛奶小铺",
      "ky":"卡依之珍稀果汁",
      "sy":"沈阳美的电器团购网",
      "fc":"云南翡翠蓉玺珠宝",
      "hb":"云南花卉门户"
    }
  };
  return data;
});
route('house','house',function(){
  var data = {
    "title": "360°看房、预约看房，品牌楼盘实力俱显",
    "picture": "house",
    "icons": {
      "hxzs":"户型展示",
      "lpjj":"楼盘简介",
      "qjkf":"全景看房",
      "xsgw":"销售顾问",
      "yykf":"预约看房"
    },
    "erweima": {
      "bj":"滨江国际城",
      "km":"昆明安信地产",
      "ss":"上实海上纳缇",
      "sjz":"石家庄买房",
      "sh":"上海境宇建筑设计",
      "sc":"首创国际"
    }
  };
  return data;
});
route('service','service',function(){
  var data = {
    "title": "多品类服务展现，直接预约，及时方便",
    "picture": "service",
    "icons": {
      "ddgl":"订单管理",
      "fwfb":"服务发布",
      "yycx":"预约查询",
      "zfgl":"支付管理"
    },
    "erweima": {
      "bs":"白氏连锁",
      "bm":"博美",
      "mrmj":"美人秘笈",
      "slf":"水立方",
      "mr":"河北美容化妆品",
      "zc":"河北藏茶养生馆",
      "zrm":"自然美spa宜川路店",
      "sjz":"石家庄纤体美容养生"
    }
  };
  return data;
});
route('boss','boss',function(){
  var data = {
    "title": "立足客户个性化需求，为品牌企业占领微信营销高地",
    "picture": "boss",
    "icons": {
      "cpgh":"产品规划",
      "dzyf":"定制研发",
      "gxhxq":"个性化需求",
      "xmpg":"项目评估",
      "xmyshss":"项目实施"
    },
    "erweima": {
      "fd":"复旦",
      "jh":"嘉慧服饰"
    }
  };
  return data;
});
route('wedding','wedding',function(){
  var data = {
    "title": "创意喜帖引爆人气，新婚体验惊喜不断",
    "picture": "wedding",
    "icons": {
      "dhlgl":"多婚礼管理",
      "hlsp":"婚礼视频",
      "hlxt":"婚礼喜帖",
      "zfq":"祝福墙"
    },
    "erweima": {
      "zp":"臻品婚礼顾问",
      "love":"lovemimosa高级婚纱礼服"
    }
  };
  return data;
});
route('edu','edu',function(){
  var data = {
    "title": "课程试听报名，提高学员转化",
    "picture": "edu",
    "icons": {
      "hjjs":"环境介绍",
      "kcgl":"课程管理",
      "msjs":"名师介绍",
      "xygl":"学员管理",
      "zxbm":"在线报名"
    },
    "erweima": {
      "dq":"大庆阳光培训",
      "gtl":"光头罗",
      "kx":"凯信会计",
      "kl":"快乐1+1",
      "xwh":"新文化钢琴",
      "yn":"云南琴行",
      "xgn":"新概念教育集团",
      "bn":"百年众博"
    }
  };
  return data;
});
route('hotel','hotel',function(){
  var data = {
    "title": "看环境、选房间、在线预约，全新体验",
    "picture": "hotel",
    "icons": {
      "ddgl":"订单管理",
      "fxzs":"房型展示",
      "jdjs":"酒店介绍",
      "pllb":"评论列表",
      "qjkf":"全景看房",
      "yydf":"预约订房",
      "zxzf":"在线支付"
    },
    "erweima": {
      "azy":"爱之缘",
      "bg":"北国之春",
      "bj":"滨江国际城",
      "hb":"河北酒店",   
      "sy":"十堰婚博园",
      "x":"辛集酒店餐饮",
      "gz":"赣州汇康大酒店",
      "ys":"河北野生原度假村",
      "xc":"新晨酒店"
    }
  };
  return data;
});
route('trip','trip',function(){
  var data = {
    "title": "图文攻略、线路规划，风景时刻靠近",
    "picture": "trip",
    "icons": {
      "lyfw":"旅游服务",
      "mpgl":"门票管理",
      "pllb":"评论列表",
      "zxzf":"在线支付"
    },
    "erweima": {
      "jh":"河北锦华国旅",
      "gj":"石家庄国际旅行社",
      "sjz":"石家庄旅行社"
    }
  };
  return data;
});
route('car','car',function(){
  var data = {
    "title": "选车、预约驾驶，目标客户锁定营销",
    "picture": "car",
    "icons": {
      "byyy":"保养预约",
      "cxgl":"车系管理",
      "czgh":"车主关怀",
      "sygj":"实用工具",
      "xsdb":"销售代表",
      "yysj":"预约试驾"
    },
    "erweima": {
      "by":"报业名车",
      "df":"东风标致",
      "km":"昆明租车",
      "yy":"英煜隆汽车租赁",
      "sjz":"石家庄汽车租赁",
      "mr":"MrRonnie",
      "jj":"锦江汽车"
    }
  };
  return data;
});
route('dinner','dinner',function(){
  var data = {
    "title": "微信叫外卖、下订单，及时更新菜品服务",
    "picture": "dinner",
    "icons": {
      "cdgl":"菜单管理",
      "dcgl":"订餐管理",
      "ddgl":"订单管理",
      "xsbb":"销售报表"
    },
    "erweima": {     
      "gt":"光头烧烤",
      "sx":"拾香得味",
      "jld":"伽蓝殿花房餐厅",
      "ysf":"玉膳房港粤美食"
    }
  };
  return data;
});
route('life','life',function(){
  var data = {
    "title": "吃喝玩乐购，本地化时尚慢生活信息门户",
    "picture": "life",
    "icons": {
      "bmfw":"便民服务",
      "csxx":"城市信息",
      "chwl":"吃喝玩乐",
      "dpzd":"店铺直达",
      "yhxx":"优惠信息"
    },
    "erweima": {
      "dq":"大庆微生活",    
      "jj":"九江微生活",
      "ks":"昆山微生活",
      "lc":"龙城微生活",
      "nmg":"内蒙古微生活",
      "yc":"盐城微客生活",
      "yq":"阳泉微生活",
      "jl":"吉林江城微生活",
      "yx":"玉溪微客生活",
      "nx":"宁夏-银川"
    }
  };
  return data;
});
route('print','print',function(){
  var data = {
    "title": "颠覆广告传统理念，快速增加微信粉丝",
    "picture": "print",
    "icons": {
      "M-BOX":"M-BOX",
      "V-BOX":"V-BOX"
    }
  };
  return data;
});

route('hospital','hospital',function(){
  var data = {
    "title": "预约挂号服务明细，提升医院形象",
    "picture": "hospital",
    "icons": {
      "ksgl":"科室管理",
      "hyzx":"行业资讯",
      "ysjs":"医生介绍",
      "yygl":"预约管理"
    },
    "erweima": {
      "yc":"岳辰齿科"
    }
  };
  return data;
});


var el = null;
function router(){
  el = el || document.getElementById('view');
  var url = location.hash.slice(1) || '/';
  var route = routes[url];
  if(el && route.controller){ 
    var data = route.controller();
    $(el).html(tmpl("tmpl-right", data));
    $(".subnav a").removeClass("active");
    $("a[href='"+data['picture']+"']").addClass("active");
  }
}

//监听哈希变化   
window.addEventListener('hashchange',router);
//监听页面载入   
window.addEventListener('load',router);
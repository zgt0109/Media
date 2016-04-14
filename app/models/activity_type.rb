class ActivityType < ActiveRecord::Base
  validates :name, presence: true

  ENUM_ID_OPTIONS = [
    ['website',             1,  '微官网'],

    ['vip',                 2,  '微会员卡'],

    ['coupon',              3,  '优惠券'],
    ['gua',                 4,  '刮刮卡'],
    ['wheel',               5,  '大转盘'],
    ['hit_egg',             25, '砸金蛋'],
    ['fight',               8,  '一战到底'],
    ['slot',                28, '老虎机'],
    ['micro_aid',           62, '微助力'],
    ['wave',                64, '摇一摇抽奖'],
    ['wx_red_packet',       40, '微红包' ],
    ['guess',               75, '美图猜猜'],
    ['wx_card',             76, '微信卡券'],
    ['brokerage',           77, '全民经纪人'],
    ['red_packet',          78, '节日礼包'],
    ['fans_game',           67, '吸粉游戏'],
    ['recommend',           70, '推荐有奖'],
    ['unfold',              71, '拆包有奖'],

    ['wx_wall',             38, '微信墙'],
    ['shake',               55, '摇一摇'],

    ['enroll',              10, '微报名'],
    ['vote',                12, '微投票'],
    ['surveys',             15, '微调研'],
    ['message',             24, '微留言'],
    ['album',               19, '微相册'],
    ['greet',               37, '微贺卡'],
    ['reservation',         63, '微预定'],
    ['scene',               73, '微场景'],
    ['panoramagram',        74, '360全景'],
    ['wbbs_community',      49, '微社区'],

    ['share_photo',         33, '晒图'],
    ['exit_share_photo',    34, '退出晒图'],
    ['other_photos',        35, '他人晒图'],
    ['my_photos',           36, '我的晒图'],

    ['groups',              14, '微团购'],
    ['group',               30, '微团购支付版'],
    ['ktv_order',           22, 'KTV预定(不再使用)'],

    ['wx_print',            46, '微信打印'],
    ['exit_wx_print',       47, '退出微信打印'],
    ['hanming_wifi',        48, '汉明wifi'],
    ['wifi',                51, 'wifi'],

    ['micro_store',         11, '微门店'],
    ['book_dinner',         6,  '微订餐'],
    ['book_table',          7,  '微订座'],
    ['take_out',            9,  '微外卖'],

    ['car',                 16, '微汽车'],
    ['weddings',            17, '微婚礼'],
    ['hotel',               18, '微酒店'],
    ['educations',          20, '微教育'],
    ['hospital',            31, '微医疗'],
    ['trip',                32, '微旅游'],

    ['house',               13, '微房产'],
    ['house_bespeak',       26, '预约看房'],
    ['house_seller',        27, '房产销售顾问'],
    ['house_impression',    41, '房友印象'],
    ['house_live_photo',    42, '实景拍摄'],
    ['house_review',        43, '专家点评'],
    ['house_intro',         44, '楼盘简介'],
    ['broche',              65, '微楼书'],

    ['plot_bulletin',       56, '微小区公告'],
    ['plot_repair',         57, '微小区报修管理'],
    ['plot_complain',       58, '微小区投诉建议'],
    ['plot_telephone',      59, '微小区常用电话'],
    ['plot_owner',          60, '微小区业主中心'],
    ['plot_life',           61, '微小区周边生活'],

    ['oa',                  66, '微OA(不再使用)'],

    ['govmail',             68, '微政务信访大厅'],
    ['govchat',             69, '微政务微信互动'],

    ['donation',            53, '微公益'],

    ['booking',             29, '微服务'],

    ['life',                21, '微生活'],
    ['circle',              23, '微商圈'],
    ['business_shop',       39, '微商圈店铺'],

    ['wshop',               45, '微电商'],

    ['wmall',               52, '微客生活圈'],
    ['wmall_shop',          54, '微客生活圈商铺'],
    ['wmall_coupon',        72, '微商圈优惠券'],

    ['new_vote',            79, '投票'],
    ['shequ',               80, '社区通'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS

  ACTIVITY_IDS = [3, 4, 5, 8, 25, 28, 64, 67] + [10, 12, 15]

  #营销互动
  def self.markets
    ids = [3, 4, 5, 8, 25, 28, 62, 64, 67, 70, 71, 75, 76, 77, 78]
    id_options.select{|m| ids.include?(m.last)}#  + [['图片分享', '33, 34, 35, 36']]
  end

  def self.sn_markets
    [
      ["优惠券", 3],
      ["摇一摇抽奖", 64],
      ["刮刮卡", 4],
      ["大转盘", 5],
      ["一战到底", 8],
      ["砸金蛋", 25],
      ["老虎机", 28],
      ["微助力", 62],
      ["推荐有奖", 70],
      ["拆包有奖", 71]
    ]
  end

  #业务管理
  def self.business
    ids = [11, 10, 12, 15, 14, 30, 19, 24, 49, 63, 73, 74, 37]
    id_options.select{|m| ids.include?(m.last)}
  end

  #行业解决方案
  def self.industry
    ids = [9, 16, 18, 32, 45, 17, 20, 31, 21, 52, 53]
    id_options.select{|m| ids.include?(m.last)} + [['微餐饮', '6, 7'], ['微房产', '13, 26, 65, 27, 41, 42, 44'], ['微商圈', '23, 39'], ['微服务', '29, 48'], ['微小区', '56, 57, 58, 59, 60, 61'], ['微政务', '68, 69']]
  end

  #存在活动开始和结束时间的活动
  def self.exist_activity_time
    [3, 4, 5, 8, 14, 25, 28, 64]
  end

  def plot_related?
    plot_bulletin? || plot_repair? || plot_complain? || plot_telephone? || plot_owner? || plot_life?
  end
end

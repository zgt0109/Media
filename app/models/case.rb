class Case < ActiveRecord::Base
  # attr_accessible :category, :description, :main_pic, :minor_pic, :name, :qr_code, :status
  #validates :name, :main_pic, :minor_pic, presence: true
  validates :name, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  #validates :main_alt, :minor_alt, presence: true
  has_many :case_pictures, dependent: :destroy

  accepts_nested_attributes_for :case_pictures, allow_destroy: true, reject_if: proc { |attributes| attributes['pic'].blank? }

  enum_attr :nav_type, :in => [
    ['case', 1, '经典案例'],
    ['nav',  2, '功能导航'],
  ]

  enum_attr :module_type, :in => [
    ['default',  0, '默认'],
    ['industry', 1, '多行业解决方案'],
    ['basic',    2, '基础功能设置'],
    ['market',   3, '营销互动模式'],
  ]

  enum_attr :status, :in => [
    ['show',  1, '显示'],
    ['hide', -1, '隐藏'],
  ]

  enum_attr :category, :in => [
    ['category1', 1, '商业生活'],
    ['category2', 2, '餐饮行业'],
    #['category3', 3, '在线商城'],
    ['category4', 4, '在线商城'],
    ['category5', 5, '房产置业'],
    ['category6', 6, '婚庆影楼'],
    ['category7', 7, '教育培训'],
    ['category8', 8, '酒店宾馆'],
    ['category9', 9, '景区旅游'],
    ['category10', 10, '掌上汽车'],
    ['category11', 11, '订单外卖'],
    ['category12', 12, '医疗保健'],
    ['category13', 13, '家装建材'],

    ['wshop',       16, '微电商'],
    ['wlife',       17, '微生活'],
    ['wmall',       18, '微商圈'],
    ['decoration1', 19, '微装饰'],
    ['edu1',        20, '微教育'],
    ['food1',       21, '微餐饮'],
    ['car1',        22, '微汽车'],
    ['dinner1',     23, '微外卖'],
    ['hotel1',      24, '微酒店'],
    ['house1',      25, '微房产'],
    ['booking',     26, '微服务'],
    ['trip1',       27, '微旅游'],
    ['hospital1',   28, '微医疗'],
    ['wedding1',    29, '微婚礼'],
    ['plots',       30, '微小区'],
    
    ['vip',       31, '微会员'],
    ['website',   32, '微官网'],
    ['group',     33, '微团购'],
    ['pay',       34, '微支付'],
    ['make',      35, '微预约'],
    ['kf',        36, '微客服'],

    ['gua',         37, '刮刮卡'],
    ['wheel',       38, '大转盘'],
    ['hit_egg',     39, '砸金蛋'],
    ['share_photo', 40, '晒图分享'],

  ]

  class << self

    def nav_module_default_categories
      category_options.select{|f| (1..13).to_a.include?(f.last)}
    end

    def nav_module_industry_categories
      category_options.select{|f| (16..30).to_a.include?(f.last)}
    end

    def nav_module_basic_categories
      category_options.select{|f| (31..36).to_a.include?(f.last)}
    end

    def nav_module_market_categories
      category_options.select{|f| (37..40).to_a.include?(f.last)}
    end

  end

  def main_pic_url
    qiniu_image_url(main_pic)
  end

  def minor_pic_url
    qiniu_image_url(minor_pic)
  end
  
  def qr_code_url
    qiniu_image_url(qr_code)
  end

  def icon_url
    qiniu_image_url(icon)
  end
  
end


# <ul class="subnav hover_nav">
#       <li><a href="/solution/life">微客生活圈</a></li>
#       <li><a href="/solution/food">微餐饮</a></li>
#       <li><a href="/shangquan">微商圈</a></li>
#       <li><a href="/solution/shop">微电商</a></li>
#       <li><a href="/solution/house">微房产</a></li>
#       <li><a href="/solution/wedding">微婚礼</a></li>
#       <li><a href="/solution/edu">微教育</a></li>
#       <li><a href="/solution/hotel">微酒店</a></li>
#       <li><a href="/solution/trip">微旅游</a></li>
#       <li><a href="/solution/car">微汽车</a></li>
#       <li><a href="/solution/dinner">微外卖</a></li>
#       <li><a href="/solution/hospital" class="active">微医疗</a></li>
#       <li><a href="/solution/decoration">微装饰</a></li>      
#       <li><a href="/solution/boss">大客户定制</a></li>
#       <!-- <li><a href="/solution/service">服务行业</a></li> -->    
#     </ul>

class WebsiteTemplate < ActiveRecord::Base
  mount_uploader :pic, WebsiteTemplateUploader
  
  # attr_accessible :description, :name, :template_type, :pic, :sort, :status
  
  validates :name, :template_type, presence: true
  
  belongs_to :website_tag
  has_many :websites

  scope :permits, -> { where('website_templates.permit_suppliers is null') }
  scope :supplier_templates, -> (supplier) { where("website_templates.permit_suppliers is null or website_templates.permit_suppliers like '%#{supplier.id}%'") }

  enum_attr :template_type, :in => [
    ['home_template', 1, '首页模板'],
    ['list_template', 2, '列表页模板'],
    ['detail_template', 3, '详情页模板'],
    ['navigation', 4, '导航栏模板'],
    ['menu', 5, '快捷菜单模板'],
  ]
  
  enum_attr :status, :in => [
    ['show', 1, '显示'],
    ['hide', -1, '隐藏'],
  ]

  enum_attr :icon_shape, :in => [
    ['circle', 0, '圆形'],
    ['square', 1, '方形'],
    ['other_icon', -1, '其他'],
  ]

  enum_attr :scroll_way, :in => [
    ['screen', 0, '全屏滑动'],
    ['around', 1, '左右翻动'],
    ['updown', 2, '上下翻动'],
    ['other_scroll', -1, '其他'],
  ]
  
  enum_attr :series, :in => [
      ['websiteV01', 0, '老模版'],
      ['websiteV02', 1, '新模版'],
  ]

  %i(support_bg_image support_slide support_ws_logo support_wm_pic support_bg_music).each do |method_name|
    class_eval(%Q{
      def #{method_name}_name
        #{method_name} ? '支持' : '不支持'
      end

      def #{method_name}_class
        #{method_name} ? 'icon-ok-sign' : 'icon-remove-sign'
      end
    })
  end
  
  # 企业QQ微官网模板套餐
  # 微官网的模板按照数量分为三个套餐
  # 1、4个首页模板+2个列表页模板+2个详情页模板+2个导航栏模板  
  # 2、85个首页模板+15个列表页模板+8个详情页模板+24个导航栏模板 
  # 3、所有首页模板+列表页模板+详情页模板+导航栏模板
  
  BQQ_WEBSITE_PRODUCTS = {
    2101 => {
      1 => (1..4).to_a,
      2 => (1..2).to_a,
      3 => (1..2).to_a,
      4 => (1..2).to_a,
    },
    2102 => {
      1 => (1..85).to_a,
      2 => (1..15).to_a,
      3 => (1..8).to_a,
      4 => (1..24).to_a,
    },
    2103 => {
      1 => (1..WebsiteTemplate.home_template.show.permits.count).to_a,
      2 => (1..WebsiteTemplate.list_template.show.permits.count).to_a,
      3 => (1..WebsiteTemplate.detail_template.show.permits.count).to_a,
      4 => (1..WebsiteTemplate.navigation.show.permits.count).to_a,
    },
  }

  %i(support_bg_image support_slide support_ws_logo support_wm_pic support_bg_music).each do |method_name|
    class_eval(%Q{
      def #{method_name}_name
        #{method_name} ? '支持' : '不支持'
      end

      def #{method_name}_class
        #{method_name} ? 'icon-ok-sign' : 'icon-remove-sign'
      end
    })
  end

  def support_html_li_attrs
    arr, attrs = [], {name: name, website_tag_name: website_tag.try(:name), description: description.to_s}
    %i(support_bg_image support_slide support_ws_logo support_wm_pic support_bg_music icon_shape scroll_way).each do |method_name|
      attrs["#{method_name}_name"] = send("#{method_name}_name")
    end
    attrs.each{|k, v| arr << ["#{k}=#{v}"] if v.present?}
    arr.join(' ').html_safe
  end

  def is_permit_current_supplier(supplier)
    permit_suppliers.blank? || permit_suppliers.split(',').include?(supplier.id.to_s)
  end
  
end

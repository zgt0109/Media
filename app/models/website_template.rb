class WebsiteTemplate < ActiveRecord::Base
  validates :name, :template_type, presence: true

  belongs_to :website_tag
  has_many :websites

  scope :permits, -> { where('website_templates.permit_accounts is null') }
  scope :account_templates, -> (account) { where("website_templates.permit_accounts is null or website_templates.permit_accounts like '%#{account.id}%'") }

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

  def is_permit_current_account(account)
    permit_accounts.blank? || permit_accounts.split(',').include?(account.id.to_s)
  end

  def pic_url
    # qiniu_image_url(pic_key)
    "/uploads/website_template/pic/thumb_#{pic}"
  end

end

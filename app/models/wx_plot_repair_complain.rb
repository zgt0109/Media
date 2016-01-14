class WxPlotRepairComplain < ActiveRecord::Base
  belongs_to :wx_plot
  belongs_to :wx_plot_category

  has_many :messages, class_name: 'WxPlotRepairComplainMessage'
  has_many :statuses, class_name: 'WxPlotRepairComplainStatus'

  scope :show, -> { where(status: [0, 1, 2]) }
  scope :undone, -> { where(status: [0, 1]) }

  accepts_nested_attributes_for :messages

  before_save :create_statuses
  after_create :send_sms, :igetui

  enum_attr :gender, :in => [
    ['sir', 1, '先生'],
    ['madam', 2, '女士']
  ]

  enum_attr :category, :in => [
    ['repair', 1, '报修'],
    ['complain', 2, '投诉'],
    ['advice', 3, '建议']
  ]

  enum_attr :status, :in => [
    ['submit', 0, '已提交'],
    ['accept', 1, '已受理'],
    ['done', 2, '已完成'],
    ['cancel', 3, '已撤消']
  ]

  def allow_change?
    submit? || accept?
  end

  %i(submit accept done cancel).each do |method_name|
    class_eval(%Q{
      def #{method_name}!
        update_attributes!(status: #{method_name.upcase})
      end
    })
  end

  private
    def create_statuses
      self.statuses << self.statuses.new(status: self.status)  if self.new_record? || status_changed?
    end

    def send_sms
      is_open_sms = repair? ? wx_plot.try(:is_open_repair_sms) : wx_plot.try(:is_open_complain_sms)
      return if wx_plot_category.nil? || wx_plot.try(:site).nil? || !is_open_sms
      sms_settings = wx_plot_category.sms_settings.where(['wx_plot_sms_settings.start_at <= ? and wx_plot_sms_settings.end_at >= ?', created_at.strftime('%H:%M'), created_at.strftime('%H:%M')]).all
      wx_plot.site.send_message(sms_settings.collect(&:phone).uniq.join(','), "#{created_at.strftime('%H:%M')}收到#{nickname}用户#{phone}的#{wx_plot_category.name}#{repair? ? '报修申请' : '投诉建议'}", '小区')
    end

    def igetui
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'site', role_id: wx_plot.try(:site_id), token: wx_plot.try(:site).try(:auth_token), messageable_id: self.id, messageable_type: 'WxPlotRepairComplain', source: 'winwemedia_wx_plot', message: '您有一笔新订单，请尽快处理。'})
    rescue => e
      Rails.logger.info "#{e}" 
    end

end

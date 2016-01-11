class ReservationOrder < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :wx_user
  belongs_to :activity
  has_many :custom_values, as: :customized
  scope :today, -> { where(created_at:  Date.today.beginning_of_day..Date.today.end_of_day) }
  enum_attr :status, :in => [
    ['created',  0, '未完成'],
    ['done',   1, '已完成'],
    ['canceled', -1, '已流单'],
    ['abandoned', -2, '已撤销']
  ]

  after_create :igetui

  def intro
    msg = ""
    activity.custom_fields.normal.each do |field|
      value = custom_values.where(custom_field_id: field.id).first.value rescue ''
      msg += "<p>#{field.name}：#{value}</p>"
    end
    msg
  end

  def nickname
    field = activity.custom_fields.where(name: '姓名').first
    value = custom_values.where(custom_field_id: field.id).first.value rescue ''
  end

  def mobile
    field = activity.custom_fields.where(name: '电话').first
    value = custom_values.where(custom_field_id: field.id).first.value rescue ''
  end

  def reservation_date
    field = activity.custom_fields.where(name: '日期时间').first
    value = custom_values.where(custom_field_id: field.id).first.value rescue ''
  end

  private
    def igetui
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'supplier', role_id: supplier_id, token: supplier.try(:auth_token), messageable_id: self.id, messageable_type: 'ReservationOrder', source: 'winwemedia_reservation', message: '您有一笔新的微预定订单，请及时处理。'})
    rescue => e
      Rails.logger.info "#{e}"
    end

end

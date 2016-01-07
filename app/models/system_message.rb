class SystemMessage < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :system_message_module
  belongs_to :system_message_setting

  after_destroy :change_view_remind_message
  after_save :change_view_remind_message

  enum_attr :is_read,  :in => [
      ['unread', false, '未读'],
      ['read', true, '已读'],
  ]

  PARAMS_SETTING = {
      1 => {url: '/wx_plot_repair_complains?type=repair', target: '_self'},
      2 => {url: '/wx_plot_repair_complains?type=complain', target: '_self'}
  }


  def view_url_attrs
    arr = []
    skip_url_attrs.to_h.each{|k, v| arr << ["#{k}=#{v}"] if v.present?}
    arr.join(' ').html_safe
  end

  def skip_url_attrs
    PARAMS_SETTING[system_message_module.module_id.to_i]
  end

  def read!
    update_attributes!(is_read: true) unless is_read
  end

  def change_view_remind_message
    message = {
        channel: "/system_messages/change/#{supplier_id}",
        data: attributes.merge!({operate: (destroyed? || is_read) ? 'delete' : 'add', music: system_message_setting.music}.merge!(skip_url_attrs))
    }
    uri = URI.parse("http://#{FAYE_HOST}/faye")
    Net::HTTP.post_form(uri, message: message.to_json)
  end

end

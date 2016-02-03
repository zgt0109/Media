class Govchat < ActiveRecord::Base
  belongs_to :activity
  enum_attr :status, in: [
    ['normal',  1, '未回复'],
    ['archived', 2, '已归档'],
    ['replied', 3, '已回复'],
    ['deleted', 0, '已删除']
  ]
  enum_attr :chat_type, in: [
    ['report',  1, '举报'],
    ['advise', 2, '咨询'],
    ['complaint', 0, '投诉'],
  ]

  scope :roots, ->{where(parent_id: nil)}
  scope :replies, ->{where("parent_id is not null")}

  # after_create :igetui

  def reply
    Govchat.where(parent_id: id).first
  end

  def has_reply?
    reply.present?
  end

  def site
    govmailbox.try(:activity).try(:site)
  end

  private
    def igetui
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'site', role_id: site.try(:id), token: site.account.try(:token), messageable_id: self.id, messageable_type: 'Govchat', source: 'gov', message: '您有一个新的信箱留言，请及时处理。'})
    rescue => e
      Rails.logger.info "#{e}"
    end

end

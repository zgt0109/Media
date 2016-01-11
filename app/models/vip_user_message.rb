# == Schema Information
#
# Table name: vip_user_messages
#
#  id          :integer          not null, primary key
#  supplier_id :integer          not null
#  vip_user_id :integer          not null
#  is_read     :boolean          default(FALSE), not null
#  msg_type    :integer          default(1), not null
#  send_type   :integer          default(1), not null
#  title       :string(255)      not null
#  content     :text             default(""), not null
#  status      :integer          default(1), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class VipUserMessage < ActiveRecord::Base
  belongs_to :site
  belongs_to :vip_user

  scope :read,   ->( is_read = true ) { where(is_read: is_read) unless is_read.nil?  }
  scope :unread, -> { where(is_read: false) }

  validates :title, :content, :send_type, presence: true
  
  enum_attr :send_type, in: [
    ['send_one', 1, '私信'],
    ['send_all', 2, '群发'],
  ]

  scope :latest, -> { order('is_read, created_at DESC') }

  def self.send_to_all(supplier, options = {})
    supplier.vip_user_ids.each { |vip_user_id|
      supplier.vip_user_messages.create options.merge(vip_user_id: vip_user_id)
    }
  end

  def read?
    is_read?
  end

  def unread?
    !is_read?
  end

  def read_status
    read? ? '已读' : '未读'
  end
end

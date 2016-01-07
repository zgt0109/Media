# == Schema Information
#
# Table name: vip_user_signs
#
#  id          :integer          not null, primary key
#  supplier_id :integer          not null
#  vip_user_id :integer          not null
#  date        :date             not null
#  points      :integer          default(0), not null
#  created_at  :datetime         not null
#

class VipUserSign < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :vip_user

  WDAYS = %W(星期日 星期一 星期二 星期三 星期四 星期五 星期六)

  scope :today, ->  { where(date: Date.today) }
  scope :latest, -> { order('id DESC') }

end

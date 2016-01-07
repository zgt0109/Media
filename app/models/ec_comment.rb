# == Schema Information
#
# Table name: ec_comments
#
#  id         :integer          not null, primary key
#  ec_item_id :integer          not null
#  wx_user_id :integer
#  name       :string(255)      not null
#  content    :string(255)      not null
#  status     :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EcComment < ActiveRecord::Base
  belongs_to :ec_item
  #attr_accessible :content, :name, :status
end

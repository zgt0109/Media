# == Schema Information
#
# Table name: agents
#
#  id                   :integer          not null, primary key
#  agent_no             :string(255)
#  is_vip               :boolean          default(FALSE), not null
#  agent_type           :integer          default(1), not null
#  discount             :decimal(6, 2)    default(0.0), not null
#  nickname             :string(255)
#  name                 :string(255)
#  mobile               :string(255)
#  tel                  :string(255)
#  email                :string(255)
#  contact              :string(255)
#  status               :integer          default(0), not null
#  is_reply             :boolean          default(FALSE), not null
#  admin_user_id        :integer
#  operator_id          :integer
#  balance              :decimal(12, 2)   default(0.0), not null
#  usable_amount        :decimal(12, 2)   default(0.0), not null
#  froze_amount         :decimal(12, 2)   default(0.0), not null
#  supplier_category_id :integer
#  region               :string(255)
#  province_id          :integer          default(9), not null
#  city_id              :integer          default(73), not null
#  district_id          :integer          default(702), not null
#  address              :string(255)
#  sign_in_count        :integer          default(0), not null
#  current_sign_in_at   :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_at      :datetime
#  last_sign_in_ip      :string(255)
#  password_digest      :string(255)
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

 class Agent < ActiveRecord::Base
    has_many :suppliers
    has_many :agent_regions
 end

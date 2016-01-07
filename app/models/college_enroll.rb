# == Schema Information
#
# Table name: college_enrolls
#
#  id               :integer          not null, primary key
#  supplier_id      :integer          not null
#  wx_mp_user_id    :integer          not null
#  college_id       :integer          not null
#  college_major_id :integer          not null
#  wx_user_id       :integer          not null
#  name             :string(255)      not null
#  mobile           :string(255)      not null
#  description      :text             default(""), not null
#  status           :integer          default(1), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CollegeEnroll < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :college
  belongs_to :college_major

  before_create :given_default_attrs
  validates :wx_user_id, presence: true

  private

  def given_default_attrs
    return unless self.college
    self.supplier_id = self.college.supplier_id
    self.wx_mp_user_id = self.college.wx_mp_user_id
  end

end

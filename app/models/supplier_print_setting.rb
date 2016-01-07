class SupplierPrintSetting < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  has_many :activities, as: :activityable
  accepts_nested_attributes_for :activities

  def inlead
    activities.select { |a| [46,47].include? a.activity_type_id }
  end

  def welomo
    activities.select { |a| [79,80].include? a.activity_type_id }
  end
end
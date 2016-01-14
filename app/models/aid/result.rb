class Aid::Result < ActiveRecord::Base
  self.table_name_prefix = 'aid_'

  belongs_to :activity_user
  belongs_to :user

  validates_presence_of :user, :activity_user
  validates_numericality_of :points, greater_than: 0
end

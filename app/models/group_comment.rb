class GroupComment < ActiveRecord::Base
  belongs_to :group_item
  belongs_to :user
  belongs_to :group_order
end
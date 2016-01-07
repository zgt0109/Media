class GroupComment < ActiveRecord::Base
  belongs_to :group_item
  belongs_to :wx_user
  belongs_to :group_order
end
class EcOrderItem < ActiveRecord::Base
  belongs_to :ec_order
  belongs_to :ec_item
end

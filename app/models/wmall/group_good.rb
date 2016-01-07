class Wmall::GroupGood < ActiveRecord::Base
  has_many :pictures, class_name: "Wmall::GroupPicture", foreign_key: "goods_id"
  belongs_to :shop

end
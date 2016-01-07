class Wmall::Coupon < ActiveRecord::Base
  has_many :pictures, class_name: "Wmall::Picture", as: :pictureable
  belongs_to :shop

  def pictures
    Wmall::Picture.where(pictureable_id: id, pictureable_type: "Coupon")
  end
end
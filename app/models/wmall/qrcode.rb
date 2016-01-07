class Wmall::Qrcode < ActiveRecord::Base
  # attr_accessible :title, :body
 
  self.table_name = "wmall_qrcodes"

  validates :scene_id, uniqueness: {scope: :mall_id}

  #enum action_name: [:qr_scene, :qr_limit_scene]

  belongs_to :qrcodeable, :polymorphic => true 

  def update_qrcode_name!
    update_attribute("name","#{self.try(:qrcodeable).try(:name)}二维码推广")
  end 

  def qrcodeable
    class_type = "Wmall::#{qrcodeable_type}"
    Kernel.const_get(class_type).where(id: qrcodeable_id).first
  end
  	

end

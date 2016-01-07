class LeavingMessageTemplate < ActiveRecord::Base

  mount_uploader :pic, PictureUploader


  class << self
    
  end

  def header_bg
    tmp_header_bg = read_attribute(:header_bg)
    if tmp_header_bg.present?
      tmp_header_bg
    elsif self.pic.present?
      self.pic.to_s
    else
      "/assets/leaving_messages/bg-header-#{self.template_id}.jpg"
    end
  end

 
end

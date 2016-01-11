class LeavingMessageTemplate < ActiveRecord::Base

  def header_bg
    tmp_header_bg = read_attribute(:header_bg)
    if tmp_header_bg.present?
      tmp_header_bg
    else
      "/assets/leaving_messages/bg-header-#{self.template_id}.jpg"
    end
  end

end

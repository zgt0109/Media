class ActivityEnroll < ActiveRecord::Base

  belongs_to :activity
  belongs_to :user

  include Spread::Spreads

  def attrs(attr)
    if self.has_attribute?(attr)
      self.send(attr)
    else
      unless self.spreads
        nil
      else
        return self.spreads.send(attr)
      end
    end
  end

  def set_attrs(attr, value)
    value = value.to_s
    if self.has_attribute?(attr)
      self.update_attribute(attr, value)
    else
      self.spreads.send("#{attr}=", value)
    end
    value
  end

  def secure_mobile
    secure = mobile || ''
    if secure.length > 10
      secure[4..7] = '****' rescue ''
    end
    secure
  end

end

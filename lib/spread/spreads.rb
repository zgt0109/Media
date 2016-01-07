# -*- encoding : utf-8 -*-

# 在需要扩展的 Model 插入一句代码即可： include Spread::Spreads

module Spread::Spreads

  def spreads
    Spread::Object.new(self.class.name, self.id)
  end

end

#  include Spread::Spreads
#
#  def attrs(attr)
#    if self.has_attribute?(attr)
#      self.send(attr)
#    else
#      self.spreads.send(attr)
#    end
#  end
#
#  def set_attrs(attr, value)
#    value = value.to_s
#    if self.has_attribute?(attr)
#      self.update_attribute(attr, value)
#    else
#      self.spreads.send("#{attr}=", value)
#    end
#    value
#  end

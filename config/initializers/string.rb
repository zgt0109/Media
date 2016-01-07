class String

  def top(n = 10, options = {})
    options[:points] ||= ""
    new_str = self[0..(n.to_i - 1)]
    new_str += options[:points] if new_str.length < self.length
    new_str
  end

#  def large(width = 720)
#    "#{self}?imageView2/2/w/#{width}"
#  end
#
#  def big
#    "#{self}?imageView2/2/w/640"
#  end
#
#  def thumb
#    "#{self}?imageView2/2/w/200"
#  end
#
#  def custom
#    self.large
#  end
  
end
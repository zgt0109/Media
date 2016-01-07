# -*- encoding : utf-8 -*-
require 'aid/rule'

class Extend

  def initialize(content = nil)
    @content = content.present? && Marshal.load(content) || {} rescue {}
  end

  def serialized_content
    Marshal.dump(@content)
  end

  def method_missing(name,*args)
    @content ||= {}
    method_name = name.to_s.strip
    if method_name.last == "="
      @content[method_name[0..-2]] = args.first
    else
      @content[method_name]
    end
  end

end

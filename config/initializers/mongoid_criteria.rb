# -*- coding: utf-8 -*-
class Mongoid::Criteria

  def r
    if self.try(:length).to_i > 0
      self.all.map{|r| r}
    else
      nil
    end
  end


end
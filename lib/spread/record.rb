# -*- encoding : utf-8 -*-

# Migration of Spread::Record
# db/migrate/20140305091831_create_spread_records.rb

class Spread::Record < ActiveRecord::Base

  Classes = { 0 => nil, 1 => String, 2 => Float, 3 => Fixnum, 4 => Date, 5 => Time }

  self.table_name = "spread_records"

  class << self

    def get_class_id(att_class)
      Classes.keys.each do |key|
        return key if Classes[key] == att_class
      end
      1
    end

  end
  
end

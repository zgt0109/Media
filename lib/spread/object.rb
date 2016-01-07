# -*- encoding : utf-8 -*-
class Spread::Object 

  def initialize(model_name, model_id)
    @spreads = Spread::Record.where(:model_name => model_name, :model_id => model_id)
  end
  
  def method_missing(name,*args)
    method_name = name.to_s.strip
    if method_name.last == "="
      attr_name = method_name[0..-2]
      spread = @spreads.where(:attr_name => attr_name).first_or_create
      if args.first
        spread.attr_class_id = Spread::Record.get_class_id(args.first.class)
        spread.attr_value = args.first.to_s
        spread.save
      end
    else
      attr_name = method_name
      spread = @spreads.where(:attr_name => attr_name).first
      if spread
        attr_class = Spread::Record::Classes[spread.try(:attr_class_id)]
        if [Date, Time].include?(attr_class)
          attr_class.parse(spread.try(:attr_value))
        elsif Fixnum == attr_class
          spread.try(:attr_value).to_i
        elsif Float == attr_class
          spread.try(:attr_value).to_f
        else
          spread.try(:attr_value).to_s
        end
      end
    end
  end

end

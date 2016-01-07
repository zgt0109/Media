class MobileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.to_s =~ /\A[0-9\-]{9,15}\z/i
      record.errors[attribute] << (options[:message] || "格式不正确")
    end
  end
end
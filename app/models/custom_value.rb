class CustomValue < ActiveRecord::Base
  belongs_to :custom_field
  belongs_to :customized, polymorphic: true
  belongs_to :vip_user

  def initialize(attributes=nil, *args)
    super
    if new_record? && custom_field
      self.value ||= custom_field.default_value
    end
  end

  # Returns true if the boolean custom value is true
  def true?
    self.value == '1'
  end

  def editable?
    custom_field.editable?
  end

  def required?
    custom_field.is_required?
  end

  def to_s
    value.to_s
  end
end

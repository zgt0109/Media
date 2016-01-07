# == Schema Information
#
# Table name: activity_forms
#
#  id                     :integer          not null, primary key
#  activity_id            :integer          not null
#  activity_form_field_id :integer          not null
#  field_name             :string(255)
#  field_value            :string(255)
#  sort                   :integer          default(1), not null
#  status                 :integer          default(1), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ActivityForm < ActiveRecord::Base
  #attr_accessible :activity_form_field_id, :activity_id, :field_name, :field_value, :sort, :status
  validates :activity_form_field_id, :activity_id, :sort, presence: true

  belongs_to :activity_form_field
  belongs_to :activity

  before_create :add_default_attrs

  default_scope order('sort asc')

  class << self

    def add_new(form_field_id, activity_id, options)
      options ||= {}
      options[:sort] ||= 1
      options[:required] ||= false
      form_field = ActivityFormField.where(id: form_field_id).first
      if form_field
        self.create(activity_id: activity_id, activity_form_field_id: form_field.id, field_name: form_field.name, field_value: form_field.value, sort: options[:sort], required: options[:required])
      end
    end

  end
  
  def add_default_attrs
    return unless self.activity_form_field

    self.field_name = self.activity_form_field.name
    self.field_value = self.activity_form_field.value
  end

end

# == Schema Information
#
# Table name: activity_form_fields
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  value      :string(255)
#  sort       :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ActivityFormField < ActiveRecord::Base
  #attr_accessible :name, :sort
  validates :name, :sort, presence: true

  Type = { 1 => "文本", 2 => "单选", 3 => "多选", 4 => "日期", 5 => "时间" }
  
  has_many :activity_forms

  def field_type_name
    Type[self.field_type]
  end

  def regular_result(val)
    val = val.to_s.strip
    if self.regular.present?
      # 报名字段服务器端校验
      if Regexp.new(self.regular).match(val).to_s != val
        alert = self.regular_alert.present? && self.regular_alert || "格式不正确"
        return "报名字段：#{self.value} #{alert}！\n当前值是：#{val}"
      end
    end
    nil
  end

end

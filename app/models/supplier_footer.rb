# == Schema Information
#
# Table name: supplier_footers
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  is_default     :boolean          default(FALSE), not null
#  is_show_link   :boolean          default(FALSE), not null
#  footer_content :string(255)      not null
#  footer_link    :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SupplierFooter < ActiveRecord::Base
  belongs_to :supplier
  # attr_accessible :footer_content, :footer_link, :is_default
  
  def self.default_footer
    where(is_default: true).first
  end
end

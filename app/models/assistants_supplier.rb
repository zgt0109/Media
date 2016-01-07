# == Schema Information
#
# Table name: assistants_suppliers
#
#  id           :integer          not null, primary key
#  assistant_id :integer
#  supplier_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AssistantsSupplier < ActiveRecord::Base
  belongs_to :assistant
  belongs_to :supplier
end

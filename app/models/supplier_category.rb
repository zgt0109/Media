# == Schema Information
#
# Table name: supplier_categories
#
#  id         :integer          not null, primary key
#  parent_id  :integer          default(0), not null
#  name       :string(255)      not null
#  sort       :integer          default(0), not null
#  status     :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SupplierCategory < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :parent, class_name: 'SupplierCategory', foreign_key: :parent_id
  has_many :children, class_name: 'SupplierCategory', foreign_key: :parent_id, dependent: :destroy
  has_many :supplier_applies
  has_many :suppliers

  scope :root, -> { where(parent_id: 0) }
  scope :food, -> { where(parent_id: 1) }
  default_scope order("supplier_categories.sort ASC")
end

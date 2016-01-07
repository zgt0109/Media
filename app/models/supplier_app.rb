class SupplierApp < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :supplier_industry

  # attr_accessible :created_at
end

class SupplierAppInfo < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :supplier
end

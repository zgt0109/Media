class ThermalPrinter < ActiveRecord::Base
  # attr_accessible :address, :no
  # has_and_belongs_to_many :shop_branch_print_templates
  belongs_to :shop_branch_print_template
end

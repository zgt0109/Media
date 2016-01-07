# == Schema Information
#
# Table name: house_properties
#
#  id                 :integer          not null, primary key
#  house_id           :integer          not null
#  opening_at         :datetime
#  building_type      :string(255)
#  decorate_condition :string(255)
#  region             :string(255)
#  developer          :string(255)
#  investors          :string(255)
#  sales_address      :string(255)
#  property_type      :string(255)
#  property_right     :integer
#  link_position      :string(255)
#  planning_area      :decimal(12, 2)
#  covered_area       :decimal(12, 2)
#  household_count    :integer
#  parking_count      :integer
#  plot_ratio         :integer
#  greening_rate      :decimal(6, 2)
#  floor_condition    :string(255)
#  progress_rate      :string(255)
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class HouseProperty < ActiveRecord::Base
  #attr_accessible :building_type, :covered_area, :decorate_condition, :description, :developer, :floor_condition, :greening_rate, :house_id, :household_count, :investors, :link_position, :opening_at, :parking_count, :planning_area, :plot_rate, :progress_rate, :property_right, :property_type, :region, :sales_address
	belongs_to :house
end

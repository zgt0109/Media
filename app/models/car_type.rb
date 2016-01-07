# == Schema Information
#
# Table name: car_types
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer          not null
#  wx_mp_user_id      :integer          not null
#  car_shop_id        :integer          not null
#  car_brand_id       :integer          not null
#  car_catena_id      :integer          not null
#  name               :string(255)      not null
#  level              :integer          default(1), not null
#  engine_isplacement :string(255)      not null
#  engine_horsepower  :string(255)      not null
#  gear_box           :string(255)      not null
#  car_model          :string(255)      not null
#  drive              :string(255)      not null
#  price              :decimal(6, 2)    not null
#  status             :integer          default(1), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class CarType < ActiveRecord::Base
	# validates :car_brand_id, :car_catena_id, :level, :name, :engine_isplacement, :engine_horsepower, :gear_box, :car_model, :drive, presence: true

	# validates_numericality_of  :price, greater_than: 0, presence: true

	belongs_to :car_brand
	belongs_to :car_catena
	has_many :car_pictures, dependent: :destroy

  validates :car_catena_id, :car_brand_id, :name, :price, :dealer_price, presence: true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :level, :in => [
  	['mini', 1, '迷你型'],
    ['small', 2, '小型'],
    ['middle', 3, '中型'],
    ['big', 4, '大型'],
    ['large', 5, '超大型'],
  ]

	def delete!
		update_attributes(status: DELETED) if normal?
	end

  def self.get_select_type_html(options,name)
    html = ""
    html << "<select id='car_owner_car_type_id' name='#{name}[car_type_id]' class='input'>" if options
    html << "<option value=''>选择车型</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end

end


class CarType < ActiveRecord::Base
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


class CarActivityNotice < ActiveRecord::Base
	belongs_to :car_shop
  has_one :activity, as: :activityable, order: :activity_type_id, dependent: :destroy

	accepts_nested_attributes_for :activity

  enum_attr :notice_type, :in => [
    ['shop', 1, '微汽车'],
    ['car_type', 2, '车型'],
    ['repair', 3, '保养'],
    ['test_drive', 4, '试驾'],
    ['sales_rep', 5, '销售代表'],
    ['sales_consultant', 6, '销售顾问'],
    ['owner', 7, '车主关怀'],
    ['assistant', 8, '实用工具'],
  ]

end

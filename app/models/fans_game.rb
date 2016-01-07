class FansGame < ActiveRecord::Base
	has_and_belongs_to_many :activities
	
	enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

	scope :show, -> {where(status: NORMAL)}
	scope :latest, -> { order('id DESC') }
end

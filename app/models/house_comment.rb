class HouseComment < ActiveRecord::Base

  validates :reply_content, presence: true, length: { maximum: 200 }, on: :update

  enum_attr :status, :in => [['replying', 0, '未回复'],['replyed', 1, '已回复'],['deleted', -1, '已删除'],]

end

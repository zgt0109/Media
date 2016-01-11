class Activity::Question < ActiveRecord::Base

  validates :title, presence: true, length: { maximum: 60 }
  validates :answer_a, :answer_b, presence: true, length: { maximum: 60 }
  validates :correct_answer, presence: true

  enum_attr :correct_answer, :in => [
    ['A', 'A'],
    ['B', 'B'],
    ['C', 'C'],
    ['D', 'D'],
    ['E', 'E']
  ]

  enum_attr :status, :in => [
    ['used', 1, '使用中'],
    ['deleted', -1, '已删除']
  ]

  def delete!
    update_attributes(status: DELETED)
  end

  def pic_url
    qiniu_image_url(pic_key)
  end
end
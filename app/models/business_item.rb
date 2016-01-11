class BusinessItem < ActiveRecord::Base
  belongs_to :business_shop

  scope :sorted, -> { order('sort ASC') }

  validates :name, :sort, :description, presence: true
  validates :pic, presence: true, on: :create
  validates :price, numericality: { greater_than: 0, allow_blank: true }

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]
end

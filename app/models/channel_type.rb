class ChannelType < ActiveRecord::Base
  belongs_to :site
  has_many :channel_qrcodes

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', 2, '已删除'],
  ]

  validates :name, presence: true, uniqueness: { scope: [:site_id, :status], message: '分类名称不能重复', case_sensitive: false }, if: :normal?

  scope :latest, -> { order('created_at DESC') }
end

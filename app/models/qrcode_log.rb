class QrcodeLog < ActiveRecord::Base
	belongs_to :site
  belongs_to :user
  belongs_to :qrcode
  belongs_to :qrcodeable, polymorphic: true

  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :six_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 5.month), today) }
  scope :twelve_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.year), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :channel_qrcode_normal, ->(ids) { where(qrcodeable_id: ids, qrcodeable_type: "ChannelQrcode") }
  scope :earliest, -> { order('id ASC') }

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', 2, '已删除'],
  ]

  def self.deleted_all!
    update_all(status: DELETED)
  end
end

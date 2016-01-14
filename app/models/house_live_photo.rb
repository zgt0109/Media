class HouseLivePhoto < ActiveRecord::Base
  belongs_to :house
  belongs_to :user

  validates_presence_of :house_id, :wx_media_id

  def status_name
    case status
    when "wx_media"
      "微信原始图片"
    when "qiniu"
      "图片已存储"
    when "approved"
      "已审核"
    else
      ""
    end
  end

end

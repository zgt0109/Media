class House < ActiveRecord::Base

	validates :name, presence: true, length: { maximum: 64 }

  enum_attr :house_type, :in => [['complete_apartment', 0, '现房'],['forward_housing', 1, '期房']]

  belongs_to :site, inverse_of: :house
  belongs_to :province
  belongs_to :district
  belongs_to :city
  has_one :activity, as: :activityable, order: :activity_type_id, dependent: :destroy
  has_one :house_property, dependent: :destroy
  has_one :intro, class_name: 'HouseIntro', dependent: :destroy
	has_many :house_layouts, dependent: :destroy
	has_many :house_pictures, dependent: :destroy
	has_many :house_comments, dependent: :destroy
	has_many :house_experts, dependent: :destroy
	has_many :house_expert_comments, dependent: :destroy
	has_many :bespeaks, class_name: 'HouseBespeak', dependent: :destroy
  has_many :impressions, class_name: 'HouseImpression', dependent: :destroy
  has_many :live_photos, class_name: 'HouseLivePhoto', dependent: :destroy
  has_many :reviews, class_name: 'HouseReview', dependent: :destroy
	has_many :sellers,  class_name: 'HouseSeller', dependent: :destroy

	accepts_nested_attributes_for :activity
	accepts_nested_attributes_for :house_property

  def respond_create_live_photo(wx_user, xml)
    live_photos.create(user_id: wx_user.user_id, pic_url: xml[:PicUrl], wx_media_id: xml[:MediaId])
    Weixin.respond_text(wx_user.openid, site.wx_mp_user.openid, '实景拍摄照片上传成功。')
  end

  def respond_live_photo_location(wx_user, xml)
    live_photo_attrs = {location_x: xml[:Location_X], location_y: xml[:Location_Y]}
    live_photo_attrs.merge!(distance: intro.distance_between(live_photo_attrs)) rescue nil
    live_photos.where(user_id: wx_user.id).order('id DESC').first.update_attributes(live_photo_attrs)
    live_photo_activity = site..activities.house_live_photo.first
    comment = if live_photo_activity && live_photo_activity.extend.force
                "后台开启审核：#{wx_mp_user.nickname}正在审核您的图片，通过后会显示在“实景拍摄”栏目里"
              else
                '后台未开启审核：稍后您就可以在“实景拍摄”栏目中看到您的精彩图片了'
              end
    Weixin.respond_text(wx_user.openid, site.wx_mp_user.openid, comment)
  end

end

class SharePhoto < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :share_photo_setting
  has_many :share_photo_comments, dependent: :destroy
  has_many :share_photo_likes, dependent: :destroy
  acts_as_wx_media :pic_url,{alias_method: :image_url}

  def self.generate_rand_data(num, site_id, user_id)
    share_photo  = where(id: rand(num + 1), site_id: site_id, user_id: user_id).first
    share_photo || generate_rand_data(num, site_id, user_id)
  end

  def show_title
    self.title? ? self.title : '晒图'
  end

  def self.respond_create_share_photo(wx_user, wx_mp_user, pic_url)
    share_photo_setting = wx_mp_user.site.share_photo_setting
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '没有数据') unless share_photo_setting

    share_photo_setting.respond_create_share_photo(wx_user, pic_url)
  end

  def self.respond_share_photo(wx_user, wx_mp_user, keyword)
    share_photo_setting = wx_mp_user.site.share_photo_setting
    share_photo = share_photo_setting.share_photos.where(user_id: user.id).last
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '请先上传照片') unless share_photo

    share_photo.update_attributes(title: keyword)
    wx_user.share_photos!
    url           = mobile_share_photo_url(site_id: wx_mp_user.site_id, openid: wx_user.openid, id: share_photo.id)
    exit_keyword  = share_photo_setting.activities.exit_share_photo.first.try(:keyword).to_s
    other_keyword = share_photo_setting.activities.other_photos.first.try(:keyword).to_s
    my_keyword    = share_photo_setting.activities.my_photos.first.try(:keyword).to_s
    summary       = share_photo_setting.add_tag_description.to_s.gsub!('{exit_keyword}', exit_keyword).to_s.gsub!('{other_keyword}', other_keyword).to_s.gsub!('{my_keyword}', my_keyword)
    SharePhoto.respond_share_photo_news(wx_user.openid, wx_mp_user.openid, summary, share_photo, url)
  end

  def self.respond_other_photo(wx_user, wx_mp_user, activity)
    site = wx_mp_user.site
    share_photo = SharePhoto.where(site_id: activity.site_id).where("user_id != #{wx_user.user_id}").order('RAND()').first
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '还没有人分享图片！') unless share_photo

    url          = mobile_share_photo_url(site_id: wx_mp_user.site_id, openid: wx_user.openid, id: share_photo.id)
    other_photo  = site.activities.other_photos.first
    exit_keyword = site.activities.exit_share_photo.first.try(:keyword).to_s
    my_keyword   = site.activities.my_photos.first.try(:keyword).to_s
    summary      = other_photo.summary.to_s.gsub!('{exit_keyword}', exit_keyword).to_s.gsub!('{other_keyword}', other_photo.try(:keyword).to_s).to_s.gsub!('{my_keyword}', my_keyword)
    SharePhoto.respond_share_photo_news(wx_user.openid, wx_mp_user.openid, summary, share_photo, url)
  end

  def self.respond_my_photo(wx_user, wx_mp_user, activity)
    #查看个人晒图模式
    share_photos = wx_mp_user.site.share_photos.where(user_id: user.id).limit(10).order('id desc')
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '您还未分享图片！') if share_photos.blank?
    
    if share_photos.count == 1
      url = mobile_share_photo_url(site_id: wx_mp_user.site_id, openid: wx_user.openid, id: share_photos.first.id)
      SharePhoto.respond_share_photo_news(wx_user.openid, wx_mp_user.openid, '', share_photos.first, url)
    elsif share_photos.count > 1
      items = share_photos.map do |share_photo|
        url = mobile_share_photo_url(site_id: wx_mp_user.site_id, openid: wx_user.openid, id: share_photo.id)
        {title: share_photo.show_title, pic_url: share_photo.pic_url, url: url}
      end
      Weixin.respond_news(wx_user.openid, wx_mp_user.openid, items)
    end
  end

  def self.respond_share_photo_news(from_user_name, to_user_name, summary, share_photo, url)
    items = [{title: share_photo.show_title, description: summary, pic_url: share_photo.pic_url, url: url}]
    Weixin.respond_news(from_user_name, to_user_name, items)
  end

  def self.mobile_share_photo_url(site_id: nil, openid: nil, id: nil)
    "#{MOBILE_DOMAIN}/#{site_id}/share_photos/#{id}?openid=#{openid}"
  end
end

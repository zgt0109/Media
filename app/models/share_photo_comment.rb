class SharePhotoComment < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :share_photo,:counter_cache => :comments_count
  belongs_to :wx_user
  #attr_accessible :content, :nickname, :status
  
  before_create :add_default_properties!
  
  def add_default_properties!
    self.supplier_id = self.share_photo.supplier_id
    self.wx_mp_user_id = self.share_photo.wx_mp_user_id
  end
end

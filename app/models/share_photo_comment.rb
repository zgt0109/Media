class SharePhotoComment < ActiveRecord::Base
  belongs_to :site
  belongs_to :share_photo,:counter_cache => :comments_count
  belongs_to :user
  
  before_create :add_default_properties!
  
  def add_default_properties!
    self.site_id = self.share_photo.site_id
  end
end

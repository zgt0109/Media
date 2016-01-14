class SharePhotoLike < ActiveRecord::Base
  belongs_to :site
  belongs_to :share_photo, :counter_cache => :likes_count
  belongs_to :user
end

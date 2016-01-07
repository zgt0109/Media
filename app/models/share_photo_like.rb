class SharePhotoLike < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :share_photo,:counter_cache => :likes_count
  belongs_to :wx_user
  #attr_accessible :status
end

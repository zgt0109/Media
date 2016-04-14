# ::Comment = Class.new(ActiveRecord::Base) do
class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :commenter,   polymorphic: true
  has_one :business_shop_impression
  accepts_nested_attributes_for :business_shop_impression

  default_scope -> { order('created_at desc') }
	validates :comment, presence: true, length: { maximum: 200 }

	before_save :save_business_shop_id_to_business_shop_impression

  def self.already_today? user_id, business_shop_id
    where("commenter_id = ? and commentable_type =? and commenter_type = ? and commentable_id = ? and created_at >= ?", user_id, "BusinessShop", "User", business_shop_id, Time.now.midnight).length > 0
  end

  private
    def save_business_shop_id_to_business_shop_impression
    	if commentable_type == "BusinessShop" && business_shop_impression
	    	business_shop_impression.business_shop_id = commentable_id
	    end
    end
end

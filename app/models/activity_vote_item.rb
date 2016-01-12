# == Schema Information
#
# Table name: activity_vote_items
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  activity_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ActivityVoteItem < ActiveRecord::Base

  belongs_to :activity
  has_many :activity_user_vote_items, dependent: :destroy
  #validates :name, uniqueness: { scope: :activity_id }, allow_blank: true
  validates :link, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true

  before_create :generate_item_no

  def self.sorted_by_vote_count(activity)
    total_count = activity.vote_items_count
    # Don't use sort! method here, or activity.activity_vote_items will become an array of array
    vote_items = activity.activity_vote_items#order('sum(activity_user_vote_items_count + adjust_votes) desc')
    vote_items = vote_items.sort { |x, y| y.select_count <=> x.select_count } if activity.activity_setting.try(:sort_desc?)
    vote_items.map { |item| [item, item.per(total_count).round(2)] }
  end

  def per(total_count = nil)
    total_count ||= activity.vote_items_count
    total_count == 0 ? 0 : Float(select_count) / Float(total_count) * 100
  end

  def select_count 
    activity_user_vote_items_count + adjust_votes
  end

  def pic_url
    qiniu_image_url(pic_key)
    # qiniu_image_view_url
  end

  def qiniu_image_view_url
    if activity.text_picture?
      "#{qiniu_image_url(pic_key)}?imageView/2/w/160/h/120"
    elsif activity.picture?
      "#{qiniu_image_url(pic_key)}?imageView/2/w/264/h/198"
    end
  end

  def generate_item_no
    max_item_no = activity.activity_vote_items.maximum(:item_no) || 0
    self.item_no = max_item_no.succ
  end

end

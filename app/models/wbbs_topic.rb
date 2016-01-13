class WbbsTopic < ActiveRecord::Base
  MAX_CONTENT_LENGTH = 140
  belongs_to :site
  belongs_to :wbbs_community
  belongs_to :poster, polymorphic: true
  belongs_to :receiver, polymorphic: true

  has_many :wbbs_replies
  has_many :qiniu_pictures, as: :target
  has_many :wbbs_votables,  as: :votable
  has_many :wbbs_notifications, as: :notifiable

  scope :sticked, -> { order('top DESC') }
  scope :recent, ->( n = nil ) { n ? order('id DESC').limit(n) : order('id DESC') }

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }

  accepts_nested_attributes_for :qiniu_pictures, allow_destroy: true

  enum_attr :status, :in => [
    ['normal',  1, '正常'],
    ['deleted', -1, '已删除'],
    ['messages', 2, '留言'],
    ['privates', 3, '私信']
  ]

  def deleted!
    update_column(:status, -1)
  end

  def normal!
    update_column(:status, 1)
  end

  def poster_name
    poster.try(:nickname) || super || '游客'
  end

  def poster_avatar
    poster.try(:headimgurl) || super || '/assets/wx_wall/user-img.jpg'
  end

  def user
    if poster_type == 'User'
      User.find_by_id(poster_id)
    end
  end

  def create_reply( reply_attributes, wx_user )
    attrs = { wbbs_community_id: wbbs_community_id }
    attrs[:replier_name] = wx_user.try(:nickname).presence
    attrs[:replier_avatar] = wx_user.try(:headimgurl).presence
    wbbs_replies.create( reply_attributes.merge(attrs) )
  end

  def vote_up!( voter )
    wbbs_votables.create( voter: voter, vote_type: WbbsVotable::UP )
    update_column :up_count, up_count + 1
  end

  def report!( voter )
    wbbs_votables.create( voter: voter, vote_type: WbbsVotable::REPORT )
    update_column :reports_count, reports_count + 1
  end

  def voted_up_by?( voter )
    return true unless voter
    wbbs_votables.up.where(voter_type: voter.class.name, voter_id: voter.id).exists?
  end

  def reported_by?( voter )
    return true unless voter
    return true if voter.nil? || voter == poster
    wbbs_votables.report.where(voter_type: voter.class.name, voter_id: voter.id).exists?
  end

  def visible_for?( user )
    return true  if user.nil? || user == poster
    return !poster.wx.user.leave_message_forbidden? if poster.is_a?(User)
  end

  def privates_visible_for?( user )
    return true  if user.nil? || user == poster || user == receiver || messages?
  end
end

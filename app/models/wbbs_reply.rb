class WbbsReply < ActiveRecord::Base
  PAGE_SIZE = 5
  MAX_CONTENT_LENGTH = 140

  belongs_to :wbbs_community
  belongs_to :wbbs_topic, counter_cache: true
  belongs_to :parent, class_name: 'WbbsReply'
  belongs_to :replier, polymorphic: true
  has_many :wbbs_notifications, as: :notifiable

  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }

  after_create :create_notifications

  scope :recent, ->( n = nil ) { n ? order('id DESC').limit(n) : order('id DESC') }

  enum_attr :status, :in => [
    [ 'normal',  1,  '正常'  ],
    [ 'deleted', -1, '已删除' ]
  ]

  def replier_name
    replier.try(:nickname) || super || '游客'
  end

  def replier_avatar
    replier.try(:headimgurl) || super ||  '/assets/wx_wall/user-img.jpg'
  end


  def visible_for?( user )
    return true  if user == replier
    return !replier.user.leave_message_forbidden if replier.is_a?(User)
  end

  private
    def create_notifications
      wbbs_notifications.create(
        notifier: wbbs_topic.poster,
        notifier_name: wbbs_topic.poster_name,
        notifier_avatar: wbbs_topic.poster_avatar,
        notifiable_content: content,
        content: "#{replier_name} 回复了您的帖子，点击<a href=\"http://#{Settings.mhostname}/#{wbbs_topic.site_id}/wbbs_topics/#{wbbs_topic.id}\">查看详情</a>"
      ) if replier != wbbs_topic.poster

      wbbs_notifications.create(
        notice_type: WbbsNotification::REPLY_REPLY,
        notifier: parent.replier,
        notifier_name: parent.replier_name,
        notifier_avatar: parent.replier_avatar,
        notifiable_content: content,
        content: "#{replier_name} 回复了您的评论，点击<a href=\"http://#{Settings.mhostname}/#{wbbs_topic.site_id}/wbbs_topics/#{wbbs_topic.id}\">查看详情</a>"
      ) if parent && parent.replier && parent.replier != replier
    end

end

class WbbsNotification < ActiveRecord::Base
  belongs_to :notifiable, polymorphic: true
  belongs_to :notifier, polymorphic: true

  scope :recent, -> { order('id DESC') }

  enum_attr :notice_type, in: [
    [ 'reply_topic', 1, '回复帖子' ],
    [ 'reply_reply', 2, '回复回复' ]
  ]

  enum_attr :status, :in => [
    [ 'unread',    0, '未读'  ],
    [ 'read',      1, '已读'  ],
    [ 'deleted',  -1, '已删除' ]
  ]

  def notify_topic
    if notifiable.is_a?(WbbsTopic)
      notifiable
    elsif notifiable.is_a?(WbbsReply)
      notifiable.wbbs_topic
    end
  end

  def notifiable_url
    return "http://#{Settings.mhostname}/#{notify_topic.site_id}/wbbs_topics/#{notify_topic.id}" if notify_topic
  end

end

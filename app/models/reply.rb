class Reply < ActiveRecord::Base
  attr_accessor :single_material_id, :multiple_material_id, :activity_id, :audio_id, :video_id, :life_assistant_id, :game_assistant_id

  validates :content, presence: true, if: :text?
  validates :single_material_id, presence: true, if: :single_graphic?
  validates :multiple_material_id, presence: true, if: :multiple_graphic?
  validates :audio_id, presence: true, if: :audio_material?
  validates :game_assistant_id, presence: true, if: :games?
  # validates :life_assistant_id, presence: true, if: :life_assistant?

  belongs_to :site
  # belongs_to :keyword
  belongs_to :replier, polymorphic: true
  belongs_to :replyable, polymorphic: true

  enum_attr :event_type, :in => [
    ['text_event', '文本事件'],
    ['click_event', '点击事件']
  ]

  enum_attr :reply_type, :in => [
    ['text',1,'文本'],
    ['activity',2,'活动'],
    ['single_graphic',3,'单图文素材'],
    ['multiple_graphic',4,'多图文素材'],
    ['audio_material',5,'语音'],
    # ['link',6,'链接'],
    # ['phone', 7, '电话'],
    # ['video_material',8,'视频']
    ['games', 9, '休闲小游戏']
  ]

  before_save :cleanup

  def cleanup
    if text?
      self.replyable_id = nil
      self.replyable_type = nil
    else
      self.content = nil
      if self.activity?
        self.replyable_id = self.activity_id
        self.replyable_type = 'Activity'
      elsif self.games?
        self.replyable_type = 'Assistant'
        self.replyable_id = self.game_assistant_id
      else
        self.replyable_type = 'Material'
        if self.single_graphic?
          self.replyable_id = self.single_material_id
        elsif self.multiple_graphic?
          self.replyable_id = self.multiple_material_id
        elsif self.audio_material?
          self.replyable_id = self.audio_id
        # elsif self.video_material?
        #   self.replyable_id = self.video_id
        end
      end
    end
  end

  def with_face_image_text
    return '' unless text?
    return content unless content.to_s.include?('/')

    text = content
    TQQ_FACES.values.each_with_index do |v, i|
      face = "/#{v}"
      text.gsub!(/#{face}/, "<img src='/assets/faces/#{TQQ_FACES.keys[i]}.gif' alt='#{v}' title='#{v}' />") if text.include?(face)
    end
    text
  end

  def graphic?
    single_graphic? || multiple_graphic?
  end

end

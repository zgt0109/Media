class Material < ActiveRecord::Base
  mount_uploader :audio, AudioUploader

  validates :title, presence: true, length: { maximum: 64 }
  validates :summary, length: { maximum: 120 }, if: :single_graphic?
  validates :source_url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true
  validates :audio, presence: true, if: :audios?
  validates :video, presence: true, if: :videos?

  attr_accessor :activity_id, :menu_type, :original_filename

  enum_attr :material_type, :in => [
    ['single_graphic', 1, '单图文'],
    ['multiple_graphic', 2, '多图文'],
    ['audios', 3, '语音'],
    ['videos', 4, '视频'],
  ]

  enum_attr :reply_type, :in => [
    ['text',1,'文本'],
    ['activity',2,'活动'],
    ['link',3,'链接'],
  ]

  belongs_to :site
  belongs_to :materialable, polymorphic: true
  belongs_to :parent,   class_name: 'Material', foreign_key: :parent_id
  has_many   :children, class_name: 'Material', foreign_key: :parent_id, dependent: :destroy
  has_one    :material_content

  accepts_nested_attributes_for :children, allow_destroy: true
  validates_associated :children

  scope :root, -> { where(parent_id: 0) }
  scope :graphic, -> { where(material_type: [1,2]) }
  scope :graphic_select, -> { select("id, title, created_at, pic_key") }
  scope :audio_select, -> { audios.select("id, audio, fsize, qiniu_audio_url") }

  before_save :cleanup
  after_create :update_audio_file_name

  accepts_nested_attributes_for :material_content
  delegate :content, to: :material_content, allow_nil: true

  def content=(text)
    if new_record?
      build_material_content(content: text)
    else
      material_content ? material_content.content = text : create_material_content(content: text)
    end
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def qiniu_pic_url
    qiniu_image_url(pic_key, bucket: BUCKET_PICTURES)
  end

  def graphic?
    single_graphic? || multiple_graphic?
  end

  def cleanup
    if activity?
      self.content = nil
      self.source_url = nil
      self.materialable_id = self.activity_id
      self.materialable_type = 'Activity'
    elsif link?
      self.content = nil
    else
      self.materialable_id = nil
      self.materialable_type = nil
    end
  end

  def set_success(format, opts)
    self.success = true
  end


  def menuable
    materialable
  end

  def upload_audio_to_qiniu_worker
    #MaterialWorker.new.perform(id) if audios?
    MaterialWorker.perform_async(id) if audios?
  end

  def upload_audio_to_qiniu
    return unless audios?
    put_policy = Qiniu::Auth::PutPolicy.new(BUCKET_MEDIA)
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(put_policy, audio.path)
    if code == 200
      update_column(:qiniu_audio_url, qiniu_image_url(result["key"], bucket: BUCKET_MEDIA))
      audio.remove!
    end
  end

  def audio_absolute_path(host = nil)
    qiniu_audio_url.present? ? qiniu_audio_url : "#{host.to_s}#{audio.to_s}"
  end

  def audio_file_size
    fsize.present? ? fsize : audio.size
  end

  def update_audio_file_name
    return unless audios? && original_filename.present?
    update_column('audio', original_filename)
  end

  def update_audio_file_size
    return unless qiniu_audio_url.present?
    result = Qiniu.stat(BUCKET_MEDIA, qiniu_audio_url.split('/').last)
    update_column(:fsize, result['fsize'])
  end

  def update_audio_qiniu_mime_type(mime_type = 'audio/mp3')
    return unless qiniu_audio_url.present?
    key = qiniu_audio_url.split('/').last
    result = Qiniu.stat(BUCKET_MEDIA, key)
    Qiniu.chgm(BUCKET_MEDIA, key, mime_type) if result['mimeType'].eql?('text/plain')
  end
end

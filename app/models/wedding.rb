# == Schema Information
#
# Table name: weddings
#
#  id            :integer          not null, primary key
#  supplier_id   :integer
#  wx_mp_user_id :integer          not null
#  groom         :string(255)      not null
#  bride         :string(255)      not null
#  wedding_at    :datetime         not null
#  phone         :string(255)      not null
#  address       :string(255)      not null
#  province_id   :integer          default(9), not null
#  city_id       :integer          default(73), not null
#  district_id   :integer
#  music_url     :string(255)
#  video_url     :string(255)
#  story_title   :string(255)      not null
#  story_content :text             default(""), not null
#  seats_status  :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Wedding < ActiveRecord::Base
  WEEK = [[1,"一"],[2,"二"],[3,"三"],[4,"四"],[5,"五"],[6,"六"],[0,"日"]]

  attr_accessor :uploaded_video

  VIDEO_DIR = "#{Rails.root}/public/uploads/videos/wedding/video_url"
  FileUtils.mkdir_p VIDEO_DIR unless File.exists?(VIDEO_DIR)

  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :province
  belongs_to :city
  belongs_to :district

  has_one  :activity, as: :activityable,            dependent: :destroy
  has_many :wishes,   class_name: 'WeddingWish',    dependent: :destroy
  has_many :pictures, class_name: 'WeddingPicture', dependent: :destroy
  has_many :seats,    class_name: 'WeddingSeat',    dependent: :destroy
  has_many :guests,   class_name: 'WeddingGuest',   dependent: :destroy
  has_many :qr_codes, class_name: "WeddingQrCode",  dependent: :destroy

  validates :groom, :bride, :address, :phone, :wedding_at, :province, :city, presence: true
  validates :phone, :numericality => true

  before_create :set_empty_attributes
  before_save :save_video_url_if_uploaded_video

  accepts_nested_attributes_for :activity

  enum_attr :seats_status, :in => [
    ['seats_enabled',  1, '开启'],
    ['seats_disabled', 2, '关闭']
  ]

  enum_attr :template_id, :in => [
    ['template1', 1, '甜心粉'],
    ['template2', 2, '淡雅绿'],
  ]

  def self.get_conditions params
    conn = [[]]
    if params[:name].present?
       conn[0] << "(weddings.groom like ? or weddings.bride like ? )"
       conn << "%#{params[:name].strip}%"
       conn << "%#{params[:name].strip}%"
    end
    if params[:keyword].present?
      conn[0] << "activities.keyword like ?"
      conn << "%#{params[:keyword].strip}%"
    end
    conn[0] = conn[0].join(' and ')
    conn
  end

  def show_week
    WEEK.select{|w| break w[1] if w[0].to_i == self.wedding_at.wday}
  end

  def cover_picture
    pictures.cover.first
  end

  def cover_picture_name
    @cover_picture_name ||= cover_picture.try(:name).to_s
  end

  def set_cover(picture)
    pictures.update_all(is_cover: false)
    pictures.create name: picture, is_cover: true
  end

  def validate_story
    errors.add(:story_title,   "不能为空") if story_title.blank?
    errors.add(:story_content, "不能为空") if story_content.blank?
  end

  def story_valid?
    validate_story
    errors.blank?
  end

  def show_address
    self.try(:province).try(:name) + self.try(:city).try(:name) + self.address
  end

  def need_phone?
    phone_enable.present?
  end  

  private
  def set_empty_attributes
    self.story_title   = '' unless story_title
    self.story_content = '' unless story_content
  end

  def save_video_url_if_uploaded_video
    video_regex = /\.(rm)|(rmvb)|(wmv)|(avi)|(mpg)|(mpeg)|(mp4)$/i
    if uploaded_video.present? && video_regex =~ uploaded_video.original_filename
      file_path = "#{VIDEO_DIR}/#{Time.now.to_i}-#{uploaded_video.original_filename}"
      FileUtils.copy uploaded_video.tempfile, file_path
      FileUtils.chmod(0644, file_path)
      self.video_url = file_path.sub("#{Rails.root}/public", '')
    end
  end

end

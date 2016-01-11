class Album < ActiveRecord::Base
  BROWSING_WAYS = { 1 => '瀑布流', 2 => '单排', 3 => '双排' }

  belongs_to :site
  belongs_to :activity
  has_many   :photos, class_name: 'AlbumPhoto', dependent: :destroy
  validates :name, :site, :activity_id, presence: true
  scope :show, -> { where("albums.id in(select album_id from album_photos)") }
  before_create :add_default_attrs

  enum_attr :visible, in: [
    ['inline', true,  '显示'],
    ['hidden', false, '隐藏']
  ]

  def cover_picture
    photos.where(id: cover_id).first.try(:img_url) || photos.last.try(:img_url)
  end

  def update_visible!
    update_attributes!(visible: !visible)
  end

  def self.top_images
    files = []
    image_path = File.join(Rails.root, 'app', 'assets', 'images', 'wphoto', 'top')
    Dir.entries(image_path).each do |sub|
      next if ['.', '..'].include?(sub)
      next if File.directory?(File.new(File.join(image_path, sub)))
      files << [sub.split('.').first.to_i, File.join('/assets/wphoto/top', sub)]
    end
    files = files.sort{|x, y| x <=> y} if files.present?
    files
  end

  def error_messages
  	errors.map do |field, message|
  		field_name = I18n.t("activerecord.attributes.#{self.class.to_s.underscore}.#{field}")
  		"#{field_name}#{message}"
  	end
  end

  def add_default_attrs
    return unless site
    self.sort = site.albums.order('albums.sort, albums.updated_at DESC').collect(&:sort).min.to_i - 1
  end

end

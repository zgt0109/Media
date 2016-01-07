class WebsiteSetting < ActiveRecord::Base
  mount_uploader :bg_music, AudioUploader
  mount_uploader :bg_pic, WebsiteUploader
  img_is_exist({bg_pic: :bg_pic_key})

  # 无法自定义内容的导航编号数组
  UNABLE_CUSTOM_NAV_TEMPLATE_IDS = [1, 8, 14, 17, 18, 21, 23, 24]

  belongs_to :website
  belongs_to :home_nav_template, class_name: 'WebsiteTemplate', foreign_key: :index_nav_template_id, primary_key: :style_index, conditions: { template_type: WebsiteTemplate::NAVIGATION }
  belongs_to :inside_nav_template, class_name: 'WebsiteTemplate', foreign_key: :nav_template_id, primary_key: :style_index, conditions: { template_type: WebsiteTemplate::NAVIGATION }

  validates :wp_bottom_opacity, :wp_font_opacity, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, presence: true
  
  enum_attr :begin_animation_type, :in => [
    ['begin_animation1', 1, '淡出'],
    ['begin_animation2', 2, '变小淡出'],
    ['begin_animation3', 3, "焦点消失"],
    ['begin_animation4', 4, '往左淡出'],
    ['begin_animation5', 5, "往右淡出"],
    ['begin_animation6', 6, '往上淡出'],
    ['begin_animation7', 7, "往下淡出"],
    ['begin_animation9', 9, "雾面玻璃"],
  ]

  enum_attr :bg_animation_type, :in => [
    ['bg_animation1', 1, '玫瑰花'],
    ['bg_animation2', 2, '雪花'],
    ['bg_animation3', 3, "秋天落叶"],
    ['bg_animation4', 4, '红枫叶'],
    ['bg_animation5', 5, "绿色花朵"],
    ['bg_animation6', 6, '红色花朵'],
    ['bg_animation7', 7, '橙色花朵'],
    ['bg_animation8', 8, "蓝色花朵"],
    ['bg_animation9', 9, '白色霓虹点'],
    ['bg_animation10', 10, "橙色霓虹点"],
    ['bg_animation11', 11, '粉色霓虹点'],
    ['bg_animation12', 12, '黄色霓虹点'],
    ['bg_animation13', 13, "蓝色霓虹点"],
    ['bg_animation14', 14, '紫色霓虹点'],
  ]
  
  before_save :cleanup
  after_commit :upload_bg_music_to_qiniu#, :upload_bg_music_to_qiniu_worker
  after_save :generate_preview_pic

  def home_template
    self.home_template_id.to_i > 0 && WebsiteTemplate.where(:style_index => self.home_template_id).first || nil
  end


  def analytic_script(url = '')
    str = <<START
    <script>
        var pc_style = '';
        var browser = {
          versions: function () {
            var u = navigator.userAgent, app = navigator.appVersion;
            return {
              trident: u.indexOf('Trident') > -1,
              presto: u.indexOf('Presto') > -1,
              webKit: u.indexOf('AppleWebKit') > -1,
              gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1,
              mobile: !!u.match(/AppleWebKit.*Mobile.*/) || !!u.match(/AppleWebKit/) && u.indexOf('QIHU') && u.indexOf('QIHU') > -1 && u.indexOf('Chrome') < 0,
              ios: !!u.match(/\\(i[^;]+;( U;)? CPU.+Mac OS X/),
              android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1,
              iPhone: u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1,
              iPad: u.indexOf('iPad') > -1,
              webApp: u.indexOf('Safari') == -1,
              ua: u
            };
          }(),
          language: (navigator.browserLanguage || navigator.language).toLowerCase()
        }

        if (browser.versions.mobile && !browser.versions.iPad && this.location.href != '#{url}') {
          this.location = '#{url}';
        }
    </script>
START
  end

  def cleanup
    self.remove_bg_pic! if self.bg_pic_template_id.present? && self.bg_pic?
  end

  def bg_image
    @bg_image ||= if self.bg_pic?
      self.bg_pic.large
    else
      template_id = self.bg_pic_template_id.to_i
      if template_id == 0
        "/assets/website/bg/1.jpg"
      else
        "/assets/website/bg/#{template_id}.jpg"
      end
    end
  end

  def self.read_bg_images
    files = []
    image_path = File.join(Rails.root, 'app', 'assets', 'images', 'website', 'bg')
    Dir.entries(image_path).each do |sub|
      next if ['.', '..'].include?(sub)
      next if File.directory?(File.new(File.join(image_path, sub)))
      files << [sub.split('.').first.to_i, File.join('/assets/website/bg', sub)]
    end
    files = files.sort{|x, y| x <=> y} if files.present?
    files
  end

  def set_template(template_id, template_type)
    case template_type.to_i
    when 1
      self.update_attribute(:home_template_id, template_id)
    when 2
      self.update_attribute(:list_template_id, template_id)
    when 3
      self.update_attribute(:detail_template_id, template_id)
    when 4
      self.update_attribute(:nav_template_id, template_id)
    when 5
      self.update_attribute(:menu_template_id, template_id)
    end
  end

  def bg_pic_ul(type = :large)
    qiniu_image_url(bg_pic_key) || bg_pic.try(type)
  end

  def wp_bottom_color
    read_attribute('wp_bottom_color') || '000000'
  end

  def wp_bottom_opacity
    read_attribute('wp_bottom_opacity') || 50
  end

  def wp_font_color
    read_attribute('wp_font_color') || 'FFFFFF'
  end

  def wp_font_opacity
    read_attribute('wp_font_opacity') || 100
  end

  def upload_bg_music_to_qiniu_worker
    #WebsiteSettingWorker.new.perform(id)
    #WebsiteSettingWorker.perform_async(id)
  end

  def upload_bg_music_to_qiniu
    return unless self.bg_music?
    put_policy = Qiniu::Auth::PutPolicy.new(BUCKET_MEDIA)
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(put_policy, self.bg_music.path)
    if code == 200
      update_column(:bg_music_qiniu_url, qiniu_image_url(result["key"], bucket: BUCKET_MEDIA))
      stat_result = Qiniu.stat(BUCKET_MEDIA, result['key'])
      Qiniu.chgm(BUCKET_MEDIA, result['key'], 'audio/mp3') if stat_result['mimeType'].eql?('text/plain')
      self.bg_music.remove!
    end
  end
  
  def bg_music_absolute_path
    bg_music_qiniu_url.present? ? bg_music_qiniu_url : bg_music.to_s
  end

  def generate_preview_pic
    # return unless website.try(:supplier).try(:bqq_account?)
    return unless website.try(:supplier).try(:api_user).try(:bqqv3?)
    
    if !is_change_template? && (home_template_id_changed? or list_template_id_changed?)
      update_attributes(is_change_template: true)

      WebsitePreviewPicWorker.perform_at(5.minutes.from_now, website_id: website_id)
    end
  end

end

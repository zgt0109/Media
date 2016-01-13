class VipCard < ActiveRecord::Base
  LABELED_CUSTOM_FIELD_NAMES = %w[婚姻状况 血型 星座 性别 生肖 学历]
  DATES = { 'one_weeks' => '最近7天', 'one_months' => '最近一月', 'six_months' => '最近半年', 'twelve_months' => '最近一年' }
  TEMPLATE_SETTINGS = {
   'anhei'        => { color_code: 'fff',    bg_image_name: '暗黑',      qiniu_key: 'FoIJL_uBwSNybPOI1K1mNkjJ7sNX'},
   'bodianlan'    => { color_code: '005b71', bg_image_name: '波点蓝',    qiniu_key: 'FsSsbEgO89prbjbSrDmx07DpJJN9'},
   'buwen'        => { color_code: '005b57', bg_image_name: '布纹',      qiniu_key: 'Fuj7Td32cp1YqQlrgokPbAnsje7z'},
   'chunlan'      => { color_code: '005b71', bg_image_name: '纯蓝',      qiniu_key: 'FgQAX14V70LvAVU3zy90w4gOdqMD'},
   'donggan'      => { color_code: 'fff8d5', bg_image_name: '动感',      qiniu_key: 'FudiRXyXaCchVosPYrv22Ws9do1F'},
   'donggan1'     => { color_code: 'FFF',    bg_image_name: '动感-01',   qiniu_key: 'Fl51V5-pG1VNVnmWvR6ypiET8EG-'},
   'donggan2'     => { color_code: 'FFF',    bg_image_name: '动感-02',   qiniu_key: 'Fn77OSKZ2B_ypQfxuN4ELJLbPvje'},
   'fensekafei'   => { color_code: 'feeff5', bg_image_name: '粉色咖啡',  qiniu_key: 'FuMIzzRbEJATsESDkUtS5lGwqv76'},
   'fenxi'        => { color_code: 'fff6d1', bg_image_name: '粉系',      qiniu_key: 'FgQRqP1gQC2Eb_nx0UFPSgL9nv6G'},
   'huidiyinghua' => { color_code: '7d0000', bg_image_name: '灰底印花',   qiniu_key: 'Fg29D4pikc9tLBHknPu48-a9y_WG'},
   'jinse'        => { color_code: '503500', bg_image_name: '金色',      qiniu_key: 'FkmjttOOY-_bDJblLvA5XPwQCDgK'},
   'nenhuang'     => { color_code: '503500', bg_image_name: '嫩黄',      qiniu_key: 'FgK8bBcSq7_ZGdsPJZ3ijWpK7Y2-'},
   'niwu'         => { color_code: 'ffe0c5', bg_image_name: '拟物',      qiniu_key: 'Fgmm2Ld01iFVbSJXzCi9isdEME5T'},
   'shenhong-1'   => { color_code: 'ffdb4c', bg_image_name: '深红-01',   qiniu_key: 'Fsslojg-339tGOZ-pdzC35U_m-m7'},
   'shenhong-2'   => { color_code: 'ffeead', bg_image_name: '深红-02',   qiniu_key: 'FrVAvIhxuPB3yokE_V1G-LPbdohr'},
   'shenhong-3'   => { color_code: 'fff6d1', bg_image_name: '深红-03',   qiniu_key: 'FtnznDELE_5_JQObCCBAfmAifNVE'},
   'shenhui'      => { color_code: 'd7f4ff', bg_image_name: '深灰',      qiniu_key: 'FlKOYvMdm2aEPeRHiDjK_zRAaOdP'},
   'shenlan'      => { color_code: 'd7f4ff', bg_image_name: '深蓝',      qiniu_key: 'FkzLWtUkwbvNPBCTeNmJdt-ltdp3'},
   'tiffany'      => { color_code: '010101', bg_image_name: 'tiffany',  qiniu_key: 'Fpb6MXC7jfmytVLV97lztOC47Ykq'},
   'xiangbing-1'  => { color_code: '512800', bg_image_name: '香槟-01',   qiniu_key: 'FpMMEWfEk9Psw8-rrlm-sJXUVqfH'},
   'xiangbing-2'  => { color_code: '5b4e3e', bg_image_name: '香槟-02',   qiniu_key: 'Fhxma9M5mgP7_EIRBrfPBP8Hu_DD'},
   'xiangbing-3'  => { color_code: '2f2b19', bg_image_name: '香槟-03',   qiniu_key: 'FpPuDGdi4IEY3pr6tkexbA35MxPN'},
   'xiaoqingxin'  => { color_code: '005b71', bg_image_name: '小清新',    qiniu_key: 'FtvuyAiDsM-norU7zPGqzQ0uh6aj'},
   'xuanliang'    => { color_code: '333',    bg_image_name: '炫亮',      qiniu_key: 'Fsk9AsyKEM_GlFJOSWay34trgo8C'},
   'yingse-1'     => { color_code: '333',    bg_image_name: '银色-01',   qiniu_key: 'FvzbJUR3gnlvw7m8IRIywKZ6DaB2'},
   'yingse-2'     => { color_code: '333',    bg_image_name: '银色-02',   qiniu_key: 'FnNBIfj273tdPH7sTvBiJfWfNbLK'},
   'yingse-3'     => { color_code: '333',    bg_image_name: '银色-03',   qiniu_key: 'FrtwvXAMbSU8jIZk-O3UOu0Hxp97'},
   'heisekuxuan'  => { color_code: '333',    bg_image_name: '黑色酷炫',   qiniu_key: 'Foa_ji6C9IG2MySrwjDYgAV25gEJ'}
  }

  MAX_LABELED_CUSTOM_FIELD_COUNT = 2
  store :metadata, accessors: [:show_introduce, :init_grade_name, :sms_check, :vip_importing_enabled, 
    :open_card_sms_notify, :recharge_consume_sms_notify, :labeled_custom_field_ids, :use_vip_avatar,
    :name_font_size, :card_font_size, :settings_json
  ]

  enum_attr :status, :in => [
    ['normal',   1, '正常'],
    ['stopped', -1, '已停用']
  ]

  validates :name, :merchant_name, presence: true, length: { maximum: 20 }, on: :update

  belongs_to :city
  belongs_to :district
  belongs_to :site
  delegate :vip_users, to: :site
  belongs_to :site_category
  belongs_to :activity

  has_many :vip_message_plans, dependent: :destroy
  has_many :custom_fields, as: :customized
  has_many :vip_privileges, dependent: :destroy
  has_many :vip_groups, dependent: :destroy
  has_many :vip_grades, dependent: :destroy
  has_many :vip_cares, dependent: :destroy
  has_many :vip_packages, dependent: :destroy
  has_many :vip_package_items, dependent: :destroy


  has_one :vip_api_setting, dependent: :destroy
  has_many :vip_external_http_apis, dependent: :destroy

  before_save :format_content
  before_create :init_metadata
  after_create :create_default_vip_grade
  after_create :create_default_custom_field

  def init_grade_name
    default_grade.try(:name).presence || metadata[:init_grade_name].presence || '普通会员'
  end

  def start!
    update_attributes(status: NORMAL)
  end

  def template_key
    cover_pic_key || 'FudiRXyXaCchVosPYrv22Ws9do1F'
  end

  def cover_pic_url
    qiniu_image_url(template_key)
  end

  def logo_url
    qiniu_image_url(logo_key)
  end

  def location_address
    address
  end

  def available_conditions
    {
      1 => {'label' => '性别', 'type' => 'string',   'placeholder' => '请输入信息', 'choices' => '男,女'},
      2 => {'label' => '年龄', 'type' => 'integer',  'placeholder' => '请输入信息'},
      3 => {'label' => '生日', 'type' => 'datetime', 'placeholder' => '请输入信息'},
      4 => {'label' => '身高', 'type' => 'integer',  'placeholder' => '请输入信息'},
      5 => {'label' => '体重', 'type' => 'integer',  'placeholder' => '请输入信息'},
      6 => {'label' => '婚姻状况','type' => 'string',   'placeholder' => '请输入信息'},
      7 => {'label' => '血型', 'type' => 'string',   'placeholder' => '请输入信息'},
      8 => {'label' => '生肖', 'type' => 'string',   'placeholder' => '请输入信息'},
      9 => {'label' => '星座', 'type' => 'string',   'placeholder' => '请输入信息'},
      10 => {'label' => '职业', 'type' => 'string',   'placeholder' => '请输入信息'},
      11 => {'label' => '学历', 'type' => 'string',   'placeholder' => '请输入信息'},
      12 => {'label' => '邮编', 'type' => 'string',   'placeholder' => '请输入信息'},
      13 => {'label' => '住址', 'type' => 'string',   'placeholder' => '请输入信息'}
    }
  end

  def self.bg_mini_image_path(pinyin)
    url = qiniu_image_url(template_qiniu_key(pinyin))
    if url.present?
      url += '?imageView2/1/w/100/h/60'
    end
    url
  end

  def self.bg_images
    TEMPLATE_SETTINGS.keys
  end

  def self.template_qiniu_key(pinyin)
    TEMPLATE_SETTINGS[pinyin].to_h[:qiniu_key]
  end

  def labeled_custom_field_ids
    metadata[:labeled_custom_field_ids] || []
  end

  def labeled_custom_fields
    custom_fields.normal.where(id: labeled_custom_field_ids).sorted
  end

  def self.bg_image_name(pinyin)
    TEMPLATE_SETTINGS[pinyin].to_h[:bg_image_name]
  end


  def self.color_code(pinyin)
    TEMPLATE_SETTINGS[pinyin].to_h[:color_code]
  end

  def template_index
    VipCard.template_qiniu_keys.index(template_key)
  end

  def self.template_qiniu_keys
    VipCard::TEMPLATE_SETTINGS.values.map{|x| x.fetch(:qiniu_key)}
  end

  def phone_num
    mobile.present? ? mobile : tel
  end

  def self.export_excel(vip_users)
    xls_report = StringIO.new
    book = VipCard.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['日期', '开卡数', '开卡总数']
    sing_sheet = []
    sing_sheet << export_title

    vip_users.each_with_index do |vip_user,index|
      sing_sheet << [vip_user.created_date,vip_user.count,vip_user[:total_count]].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_excel
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => "会员卡统计"
    return [book,sheet,bold_heading]
  end

  #==start数据魔方部分
  def self.cube_export_excel(vip_users)
    xls_report = StringIO.new
    book = VipCard.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['时间', '会员新增']
    sing_sheet = []
    sing_sheet << export_title

    vip_users.each_with_index do |vip_user,index|
      sing_sheet << [vip_user.created_date,vip_user.count].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end
  #==end数据魔方部分

  def open_card?
    vip_api_setting.try(:enabled?) && vip_external_http_apis.open_card.exists?
  end

  def get_user_info?
    vip_api_setting.try(:enabled?) && vip_external_http_apis.get_user_info.exists?
  end

  def get_transactions?
    vip_api_setting.try(:enabled?) && vip_external_http_apis.get_transactions.exists?
  end

  [:sms_check, :open_card_sms_notify, :use_vip_avatar, :recharge_consume_sms_notify].each do |method_name|
    define_method("#{method_name}?") do
      public_send(method_name) == '1'
    end
  end

  def vip_importing_enabled?
    !!vip_importing_enabled
  end

  def vip_importing_disabled?
    !vip_importing_enabled
  end

  def default_grade
    vip_grades.default.first
  end

  def create_default_vip_grade
    vip_grades.where(status: VipGrade::DEFAULT).first_or_create!(sort: 0, name: '普通会员')
  end

  def checkin_enabled?
    return @checkin_enabled if defined?(@checkin_enabled)
    @checkin_enabled = is_open_points? && site.point_types.normal.checkin.exists?
  end

  private

    def create_default_custom_field
        self.custom_fields.where(field_type: '单行文本', name: '姓名').first_or_create
        self.custom_fields.where(field_type: '单行文本', name: '电话').first_or_create
    end

    def format_content
      self.description = self.description.to_s.gsub(/(?:\n\r?|\r\n?)/, '<br/>')#.gsub(" ","&nbsp;")
      self.points_description = self.points_description.to_s.gsub(/(?:\n\r?|\r\n?)/, '<br/>')#.gsub(" ","&nbsp;")
    end

    def init_metadata
      self.sms_check = '1' if sms_check.nil?
    end
end

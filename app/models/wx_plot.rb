class WxPlot < ActiveRecord::Base

  attr_accessor :is_delete_cover_pic

  belongs_to :site
  has_many :wx_plot_bulletins
  has_many :wx_plot_lives
  has_many :wx_plot_telephones
  has_many :activities, as: :activityable
  has_one :activity_wx_plot_bulletin, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_BULLETIN }
  has_one :activity_wx_plot_repair, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_REPAIR }
  has_one :activity_wx_plot_complain, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_COMPLAIN }
  has_one :activity_wx_plot_owner, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_OWNER }
  has_one :activity_wx_plot_life, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_LIFE }
  has_one :activity_wx_plot_telephone, class_name: 'Activity', as: :activityable, conditions: { activity_type_id: ActivityType::PLOT_TELEPHONE }

  has_many :wx_plot_repair_complains, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :repairs, class_name: 'WxPlotRepairComplain', conditions: { category: WxPlotRepairComplain::REPAIR }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :complains, class_name: 'WxPlotRepairComplain', conditions: { category: WxPlotRepairComplain::COMPLAIN }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :advices, class_name: 'WxPlotRepairComplain', conditions: { category: WxPlotRepairComplain::ADVICE }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :complain_advices, class_name: 'WxPlotRepairComplain', conditions: { category: [WxPlotCategory::COMPLAIN, WxPlotCategory::ADVICE] }, order: 'wx_plot_repair_complains.created_at DESC'

  has_many :wx_plot_categories
  has_many :repair_categories, class_name: 'WxPlotCategory', conditions: { category: WxPlotCategory::REPAIR }
  has_many :complain_categories, class_name: 'WxPlotCategory', conditions: { category: WxPlotCategory::COMPLAIN }
  has_many :advice_categories, class_name: 'WxPlotCategory', conditions: { category: WxPlotCategory::ADVICE }
  has_many :complain_advice_categories, class_name: 'WxPlotCategory', conditions: { category: [WxPlotCategory::COMPLAIN, WxPlotCategory::ADVICE] }
  has_many :telephone_categories, class_name: 'WxPlotCategory', conditions: { category: WxPlotCategory::TELEPHONE }
  has_many :life_categories, class_name: 'WxPlotCategory', conditions: { category: WxPlotCategory::LIFE }

  has_many :sms_settings, class_name: 'WxPlotSmsSetting', dependent: :destroy

  accepts_nested_attributes_for :wx_plot_categories, :sms_settings, :site, :allow_destroy => true
  accepts_nested_attributes_for :activities

  validates :site_id, :name, :bulletin, :repair, :complain, :telephone, :owner, :life, presence: true
  validates :repair_phone, format: { with: /^[0-9_\-]*$/, message: '联系电话格式不正确' }, allow_blank: true
  validates :complain_phone, format: { with: /^[0-9_\-]*$/, message: '联系电话格式不正确' }, allow_blank: true


  def cover_pic
    qiniu_image_url(read_attribute("cover_pic"))
  end
end
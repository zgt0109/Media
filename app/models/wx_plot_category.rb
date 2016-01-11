class WxPlotCategory < ActiveRecord::Base
  belongs_to :wx_plot

  has_many :telephones, class_name: 'WxPlotTelephone', dependent: :destroy
  has_many :lives, class_name: 'WxPlotLife', dependent: :destroy
  has_many :sms_settings, class_name: 'WxPlotSmsSetting', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: {scope: [:wx_plot_id, :category]}

  before_create :add_default_attrs

  enum_attr :category, :in => [
    ['repair', 1, '报修'],
    ['complain', 2, '投诉'],
    ['advice', 3, '建议'],
    ['telephone', 4, '常用电话'],
    ['life', 5, '周边生活']
  ]

  private

    def add_default_attrs
      return unless self.wx_plot
      self.sort = self.wx_plot.wx_plot_categories.where(category: self.category).collect(&:sort).max.to_i + 1
    end
end
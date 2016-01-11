class WxPlotLife < ActiveRecord::Base
  belongs_to :wx_plot
  belongs_to :wx_plot_category

  validates :name, :phone, :address, :content, :wx_plot_category_id, presence: true
  validates :phone, format: { with: /^[0-9_\-]*$/, message: '联系电话格式不正确' }, allow_blank: true

  before_create :add_default_attrs

  private

    def add_default_attrs
      return unless self.wx_plot
      self.sort = self.wx_plot.wx_plot_telephones.collect(&:sort).max.to_i + 1
    end
end
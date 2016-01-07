class WxPlotTelephone < ActiveRecord::Base
  belongs_to :wx_plot
  belongs_to :wx_plot_category

  before_create :add_default_attrs

  private

    def add_default_attrs
      return unless self.wx_plot
      self.sort = self.wx_plot.wx_plot_lives.collect(&:sort).max.to_i + 1
    end

end
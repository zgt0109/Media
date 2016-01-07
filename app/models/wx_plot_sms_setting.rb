class WxPlotSmsSetting < ActiveRecord::Base
  belongs_to :wx_plot
  belongs_to :wx_plot_category
end
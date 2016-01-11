class WxPlotRepairComplainStatus < ActiveRecord::Base
  belongs_to :wx_plot_repair_complain

  enum_attr :status, :in => [
    ['submit', 0, '已提交'],
    ['accept', 1, '已受理'],
    ['done', 2, '已完成'],
    ['cancel', 3, '已撤消']
  ]

end

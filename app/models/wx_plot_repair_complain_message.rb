class WxPlotRepairComplainMessage < ActiveRecord::Base
  belongs_to :messageable, polymorphic: true
end

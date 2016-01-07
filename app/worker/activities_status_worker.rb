class ActivitiesStatusWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'standard', :retry => true, :backtrace => true

  def perform(id, operation_type)
    activity = Activity.where(:id => id).first
    if operation_type.to_s == "close"
      # 关闭活动
      activity.update_column(:status, -1)
    else
      # 开启活动
      activity.update_column(:status, 1)
    end
  end

end
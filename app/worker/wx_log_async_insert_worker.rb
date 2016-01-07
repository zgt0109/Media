class WxLogAsyncInsertWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: true, backtrace: true

  def perform(params)
    WxLog.add_log(params)
  end

end
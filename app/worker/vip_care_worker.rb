class VipCareWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: true, backtrace: true

  def perform(id)
    vip_care = VipCare.where(id: id).first
    vip_care.send_care! if vip_care
  end

end
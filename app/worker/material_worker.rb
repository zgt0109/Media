class MaterialWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'website_setting', :retry => false, :backtrace => true

  def perform(material_id)
    material = Material.where(id: material_id).first
    material.upload_audio_to_qiniu
  end

end

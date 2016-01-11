class MaterialsAudiosController < ApplicationController
  
  before_filter :upload_audio_to_qiniu, only: [:create]

  def index
    @material  = Material.new(material_type: Material::AUDIOS)
    @materials = current_site.materials.audio_select.page(params[:page]).order("id desc")
  end

  def create
    @material = current_site.materials.build(params[:material])
    if @material.save(validate: false)
      redirect_to materials_audios_path, notice: '语音素材上传成功'
    else
      redirect_to materials_audios_path, alert: '语音素材上传失败'
    end
  rescue => error
    redirect_to materials_audios_path, alert: '语音素材上传失败'
  end

  def destroy
    @material = current_site.materials.where(id: params[:id]).first
    if @material.try(:destroy)
      redirect_to materials_audios_path, notice: '语音素材删除成功'
    else
      redirect_to materials_audios_path, alert: '语音素材删除失败'
    end
  end
  
  private 
  
  def upload_audio_to_qiniu
    upload_file = params[:material][:audio]
    tempfile = upload_file.tempfile
    put_policy = Qiniu::Auth::PutPolicy.new(BUCKET_MEDIA)
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(put_policy, tempfile.path)
    if code == 200
      params[:material].merge!(fsize: tempfile.count, qiniu_audio_url: qiniu_image_url(result["key"], bucket: BUCKET_MEDIA), original_filename: upload_file.original_filename, audio: nil) 
      stat_result = Qiniu.stat(BUCKET_MEDIA, result['key'])
      Qiniu.chgm(BUCKET_MEDIA, result['key'], upload_file.content_type) if stat_result['mimeType'].eql?('text/plain')
    end
  end

end

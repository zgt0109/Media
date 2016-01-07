class Pro::WeddingQrCodesController < Pro::WeddingsBaseController

  def index
    @qr_codes = @wedding.qr_codes.order("created_at desc")
  end

  def new
    render layout: 'application_pop'
  end

  def create
    # params[:qrcode][:content] = "http://m.winwemedia.com/#{@supplier.id}/weddings?wid=#{@wedding.id}?title=" + params[:qrcode][:content]
    @wedding.qr_codes.create params[:qrcode]
    render json: {msg: 'success', code: 0}
    # render inline: "<script>parent.location.reload();</script>"
  end

  def destroy
    @wedding.qr_codes.find(params[:id]).destroy
    redirect_to wedding_qr_codes_path(@wedding), notice: '删除分享设置成功'
  end
  
end

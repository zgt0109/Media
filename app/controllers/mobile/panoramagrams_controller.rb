class Mobile::PanoramagramsController < Mobile::BaseController
  skip_before_filter :auth, :authorize
  before_filter :block_non_wx_browser
  before_filter :get_share_image, only: [:index]
  
  layout 'mobile/panoramagrams'

  def index
    @panoramagrams = @site.panoramagrams.normal.order(:sort).page(params[:page])
  end

  def panorama
    @panoramagram = @site.panoramagrams.where(id: params[:id]).first
    @items = @panoramagram.items.order(:sort)

    respond_to do |format|
      format.html {render layout: false} 
      format.xml {render formats: :xml}
    end
  end

  def load_more_items
    @items = @site.panoramagrams.normal.order(:sort).page(params[:page]).collect do |i| 
      { link_to: panorama_mobile_panoramagram_path(i, site_id: i.site_id), img_url: i.pic_url, txt: i.name }
    end
    render json: {items: @items}
  end

  private
    def get_share_image
      @activity = Activity.find(params[:aid])
      @share_image = @activity.qiniu_pic_url.present? ? @activity.qiniu_pic_url :  @activity.default_pic_url
    rescue => e
      @share_image = qiniu_image_url(Concerns::ActivityQiniuPicKeys::KEY_MAPS[74], bucket: BUCKET_PICTURES)
    end

end
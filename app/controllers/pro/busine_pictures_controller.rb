class Pro::BusinePicturesController < WebsiteShared::WebsitePicturesController

  before_filter :require_business_website
  before_filter :find_picture, only: [:edit, :update, :destroy]

  def index
    @pictures = @website.website_pictures.sorted
  end

  def new
    @picture = @website.website_pictures.new
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def create
    @picture = @website.website_pictures.new(params[:website_picture])
    if @picture.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    end
  end

  def update
    if @picture.update_attributes(params[:website_picture])
      flash[:notice] = "更新成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    end
  end

  private
    def find_picture
      require_business_website
      @picture = @website.website_pictures.find params[:id]
    end
end

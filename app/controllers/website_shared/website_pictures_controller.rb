class WebsiteShared::WebsitePicturesController < WebsiteShared::WebsiteBaseController

  before_filter :set_life_website
  before_filter :find_picture, only: [:edit, :show, :update, :destroy]

  def index
    @pictures = @website.website_pictures.page(params[:page]).per(8)
    render 'pro/website_pictures/index'
  end

  def new
    @picture = @website.website_pictures.build(can_validate: true)
    render 'pro/website_pictures/new', layout: 'application_pop'
  end
  
  def create
    @picture = @website.website_pictures.new(params[:website_picture])
    if @picture.save
      render "pro/website_pictures/create", layout: false
    else
      render_with_alert('pro/website_pictures/new', '添加失败', layout: 'application_pop')
    end
  end

  def edit
    render 'pro/website_pictures/new', layout: 'application_pop'
  end

  def update
    @picture = @website.website_pictures.find(params[:id])
    if @picture.update_attributes(params[:website_picture])
      render "pro/website_pictures/update", layout: false
    else
      render_with_alert('pro/website_pictures/new', '更新失败', layout: 'application_pop')
    end
  end

  def destroy
    @picture.destroy
    render js: "$('#photo_#{@picture.id}').remove(); showTip('success', '删除成功');"
  end

end

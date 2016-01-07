class Pro::WeddingPicturesController < Pro::WeddingsBaseController
  def index
    @picture  = WeddingPicture.new
    #@pictures = @wedding.pictures.order('is_cover DESC, id DESC').page(params[:page]).per(9)
    @pictures = @wedding.pictures
    # render layout: 'application_pop'
  end
  def index_old
    @picture  = WeddingPicture.new
    @pictures = @wedding.pictures.order('is_cover DESC, id DESC').page(params[:page]).per(9)
    render layout: 'application_pop'
  end

  def create
    pic = @wedding.pictures.create pic_key: params[:pic_key]
    # redirect_to wedding_pictures_path(@wedding), notice: '添加照片成功'
    render json: {message: "ok",id: pic.id}
  end

  def update
    pic = @wedding.pictures.find params[:id]
    is_cover = !pic.is_cover
    @wedding.pictures.where(is_cover: true).update_all(is_cover: false) if is_cover
    pic.update_attributes(is_cover: is_cover)
    if is_cover
      render js: "
        $('.pic-setting-link').text('设为封面');
        var doc  = $('#pic-setting-link-#{pic.id}').text('取消封面');
        var html = $('#wedding-pic-li-#{pic.id}')[0].outerHTML;
        $('#wedding-pic-li-#{pic.id}').remove();
        $('#pics-ul').prepend(html);
      "
    else
      render js: "$('#pic-setting-link-#{pic.id}').text('设为封面')"
    end
  end

  def destroy
    pic = @wedding.pictures.find(params[:id])
    pic.destroy
    # render js: "$('#photo_#{pic.id}').remove()"
    render json: {message: "ok",id: pic.id}
  end
  
end

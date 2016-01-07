class Mobile::BrochePhotosController <  Mobile::BaseController
  layout 'mobile/broche'

  def index
    @broche = @supplier.broche
    @broche_photos = @broche.broche_photos.order('sort asc')
  end
end

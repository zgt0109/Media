class Mobile::Wmall::ProductsController < Mobile::Wmall::BaseController
  def index
    @current_wmall_titles << "淘精品"
  end

  def show
    @current_wmall_titles << "商品详情"
  end
end

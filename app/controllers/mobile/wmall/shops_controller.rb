class Mobile::Wmall::ShopsController < Mobile::Wmall::BaseController
  def index
    @current_wmall_titles << "逛品牌"
  end

  def category
  end

  def products
  end

  def add_comment
    @comment = ::Wmall::Comment.new
  end

  def comments
  end

  def show
    @current_wmall_titles << @shop.try(:name)
  end

  def show_env
    @current_wmall_titles << "店内环境"
  end

  def slides
    @current_wmall_titles << "图片展示"

    render :layout => false
  end
end

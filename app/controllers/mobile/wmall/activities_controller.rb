class Mobile::Wmall::ActivitiesController < Mobile::Wmall::BaseController
  def index
    @current_wmall_titles << "热门活动"
  end
end

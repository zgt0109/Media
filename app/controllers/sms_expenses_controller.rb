class SmsExpensesController < ApplicationController
  before_filter do
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def index
    @search = current_user.sms_expenses.succeed.search(params[:search])
    
    if params[:search] && @search.date_gte && @search.date_lte && @search.date_gte > @search.date_lte
      return redirect_to :back, alert: '开始时间不能大于结束时间'
    end
    
    @dates = @search.select("date").group("date").order("date desc").page(params[:page])
  end

end

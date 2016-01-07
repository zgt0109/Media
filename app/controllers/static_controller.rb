# coding: utf-8
class StaticController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  layout false

  def zhidahao
    render 'home/zhidahao', layout: "home"
  end

  def app
    render layout: 'home'  
  end

  def mobile
    user_agent = request.user_agent.to_s.downcase
    if user_agent =~ /android/
      return redirect_to "http://www.winwemedia.com/uploads/WKLOrder.apk"
    elsif user_agent =~ /iphone/ || user_agent =~ /ipad/
      return redirect_to "https://itunes.apple.com/cn/app/wei-ke-lai-guan-jia/id931502732?l=en&mt=8"
    else
      return render text: "请使用手机访问此链接"
    end
  end

  def enroll
    @supplier_apply = SupplierApply.new(params[:supplier_apply])
    
    respond_to do |format|
      if @supplier_apply.save(validate: false)
        format.json { render :json => { message: "提交成功!"}, :callback => 'parseForm' }
      else
        format.json { render :json => { message: @supplier_apply.errors.full_messages.join('; ') }, :callback => 'parseForm' }
      end
    end
  end

end

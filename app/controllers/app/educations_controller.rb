module App
  class EducationsController < BaseController
    layout "app/educations"
    before_filter :find_college

    def index
    end

    def address
      @branches = @college.branches
    end

    def flash_photo
      render(layout: false)
    end

    def environment
      @photos = @college.photos.page(params[:page]).per(4).order("created_at desc")
      respond_to do |format|
        format.html
        format.js
      end
    end

    def map
      @branch = CollegeBranch.find_by_id(params[:id])
      unless @branch.present?
        redirect_to address_app_educations_path, notice: "数据不存在"
        return
      end
      begin
        params = { address: @branch.address, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
        result = RestClient.get("http://api.map.baidu.com/geocoder/v2/", params: params)
        data = JSON(result)
        @location = data['result']['location']
      rescue
        @location = {}
        redirect_to address_app_educations_path, notice: "获取数据出错，请检查地址是否填写正确，或尝试刷新"
        return
      end
      render(layout: false)
    end

    def create_enroll
      @college_enroll = @college.enrolls.build(params[:college_enroll])
      if @college_enroll.save
        render text: ''
      else
        render text: @college_enroll.errors.full_messages.join('，')
      end
    end

    private

    def find_college
      session[:cid] = params[:cid] if params[:cid].present?

      @college  = College.includes(:majors).find(params[:cid] || session[:cid])
      @college_enroll ||= @college.enrolls.new(wx_user_id: session[:wx_user_id])
    rescue
      return render text: '请求参数不正确'
    end

  end
end

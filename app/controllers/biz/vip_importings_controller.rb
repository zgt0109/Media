class Biz::VipImportingsController < ApplicationController
  before_filter :set_vip_card, only: :index
  before_filter :find_vip_importing, only: [:edit, :update]

  def index
    @search = current_site.vip_importings.search(params[:search])
    @vip_importings = @search.page(params[:page])
  end

  def create
    uploaded_file = params[:file]
    return redirect_to :back, alert: "请导入格式为.CSV的文件。" if uploaded_file.blank?

    tempfile = uploaded_file.tempfile
    return redirect_to :back, alert: "请导入格式为.CSV的文件。" if uploaded_file.original_filename !~ /\.csv\z/i
    return redirect_to :back, alert: "上传文件不能大于2M，请重新上传。" if tempfile.count > 1024 ** 2

    file_name = copy_tempfile(tempfile)
    result = VipImporting.validate_and_import(current_site, file_name, sync: params[:sync].present?)

    respond_to do |format|
      if result.is_a?(Hash) # 会员导入失败，数据格式不正确
        format.json { render json: result }
        format.html { redirect_to :back, alert: result[:message] }
      else
        format.json { flash.notice = "文件上传成功，请于30分钟后查看数据导入情况"; render json: {} }
        format.html { redirect_to :back, notice: "文件上传成功，请于30分钟后查看数据导入情况"  }
      end
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @vip_importing.update_attributes(params[:vip_importing])
      flash[:notice] = '保存成功'
      render inline: '<script>parent.location.reload();</script>'
    else
      render_with_alert :edit, "保存失败，#{@vip_importing.errors.full_messages.join('，')}", layout: 'application_pop'
    end
  end

  def destroy
    current_site.vip_importings.where(id: params[:ids]).delete_all
    redirect_to :back, notice: "操作成功"
  end

  private
    def set_vip_card
      @vip_card = current_site.vip_card
    end

    def copy_tempfile(tempfile)
      dir = "#{Settings.uploads_dir}/tmp/vip_importings/#{current_site.id}"
      file_name = "#{dir}/#{Time.now.to_s(:number)}.csv"
      FileUtils.mkdir_p dir
      FileUtils.copy tempfile.path, file_name
      file_name
    end

    def find_vip_importing
      @vip_importing = current_site.vip_importings.find_by_id(params[:id])
      return redirect_to vip_importings_path, alert: '会员导入记录不存在' unless @vip_importing
    end
end
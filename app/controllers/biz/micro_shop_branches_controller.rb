# -*- coding: utf-8 -*-
class Biz::MicroShopBranchesController < ApplicationController
  before_filter :find_shop, except: :login
  before_filter :find_shop_branch, only: [ :edit, :update, :destroy, :highchart, :pictures, :create_pic, :toggle_sub_account ]
  skip_before_filter *ADMIN_FILTERS, :find_shop, :find_shop_branch, only: :location_img

  def index
    return redirect_to micro_shops_url, alert: '请先添加门店' unless @shop
    @search        = @shop.shop_branches.includes(:city, :district).used.search(params[:search])
    @shop_branches = @search.page(params[:page])
  end

  def new
    @shop_branch = ShopBranch.new
    @url = micro_shop_branches_path
    render :form, layout: 'application_pop'
  end

  def edit
    @url = micro_shop_branch_path
    render :form, layout: 'application_pop'
  end

  def create
    @shop_branch = @shop.shop_branches.new(params[:shop_branch])
    if @shop_branch.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('addGate').style.display='none';window.parent.location.reload();</script>"
    else
      redirect_to :back, alert: "添加失败，#{@shop_branch.errors.full_messages.join('\n')}"
    end
  end

  def update
    if @shop_branch.update_attributes(params[:shop_branch])
      flash[:notice] = "更新成功"
      return redirect_to micro_shop_branches_path if params[:pic]
      render inline: "<script>window.parent.document.getElementById('addGate').style.display='none';window.parent.location.reload();</script>"
    else
      redirect_to :back, alert: "更新失败，#{@shop_branch.errors.full_messages.join('\n')}"
    end
  end

  def destroy
    @shop_branch.delete!
    redirect_to :back, notice: '删除成功'
  end

  def highchart
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    @today_transactions = @shop_branch.vip_user_transactions.where("date(created_at) = ?",@today)
    @yesterday_transactions = @shop_branch.vip_user_transactions.where("date(created_at) = ?",@today-1.day)
    @total_transactions = @shop_branch.vip_user_transactions
  end

  def pictures
    @pictures = @shop_branch.qiniu_pictures
  end

  def create_pic
    return render text: nil if @shop_branch.qiniu_pictures.count >= 10
    @picture = @shop_branch.qiniu_pictures.create(sn: params[:qiniu_pic_key])
    render :partial => "biz/micro_shop_branches/picture", :locals => {picture: @picture}
  end

  def del_picture
    picture = QiniuPicture.where(id: params[:id]).first
    picture.destroy
    render js: <<-eos
      $('#delete'+#{picture.id}).closest('.photo-li').slideUp( function() {
        $(this).remove();
      });
    eos
  end

  def location_img
    wx_user = WxUser.find(params[:id])
    url = "http://st.map.qq.com/api?size=360*200&center=#{wx_user.location_y},#{wx_user.location_x}&zoom=16&format=png&markers=#{wx_user.location_y},#{wx_user.location_x},1"
    data = HTTParty.get(url).to_s
    send_data data, type: 'image/png', disposition: 'inline'
  end

  def permissions
    @search       = current_user.shop_branch_sub_accounts.set.search(params[:search])
    @sub_accounts = @search.page(params[:page])
  end

  def new_permission
    @account_names = [['请选择分店', '']]
    @account_names << ['全部分店（一次创建所有分店权限）', '0'] if current_user.shop_branch_sub_accounts.unset.exists?
    @account_names += current_user.shop_branch_sub_accounts.unset.pluck(:username, :id)
    render :permission
  end

  def permission
    sub_account_id = params[:sub_account_id]
    if request.get?
      @sub_account = current_user.shop_branch_sub_accounts.find(sub_account_id)
      return @account_names = [[@sub_account.username, @sub_account.id]]
    end

    sub_account_id = current_user.shop_branch_sub_accounts.unset.pluck(:id) if sub_account_id == '0'
    SubAccount.where(id: sub_account_id).update_all(permissions: params[:permissions].to_a.to_json, updated_at: Time.now)
    redirect_to permissions_micro_shop_branches_path, notice: '保存成功'
  end

  def toggle_sub_account
    @sub_account = @shop_branch.sub_account
    message = @sub_account.status_toggle_text + '成功'
    @sub_account.toggle_status!
    render js: "$('#toggle-sub_account-#{@sub_account.id}').text('#{@sub_account.status_toggle_text}'); showTip('success', '#{message}');"
  end

  private
    def find_shop
      @shop = current_user.shop
      redirect_to micro_shops_path, alert: "请先填写门店基础设置" unless @shop
    end

    def find_shop_branch
      @shop_branch = @shop.shop_branches.find(params[:id])
    end
end

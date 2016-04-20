module Kefu
  class StaffsController < ApplicationController
    before_filter :load_staffs, only: [:index, :edit, :update, :destroy]

    def index
      # @staffs = current_site.staffs
    end

    def new
      @staff = Kf::Staff.new
    end

    def create
      @staff = Kf::Staff.new(params[:kf_staff].merge({
        site_id: current_site.id,
        wx_mp_user_id: current_site.wx_mp_user.id,
        account_id: current_site.wx_mp_user.try(:kf_account).try(:id)
      }))

      if @staff.save
        flash[:notice] = "成功创建客服"
        redirect_to staffs_path
      else
        render :new
      end
    end

    def edit
      @staff = @staffs.find(params[:id])
      @staff.staff_no = @staff.staff_no.split('@')[0]
    end

    def update
      @staff = @staffs.find(params[:id])
      if @staff.update_attributes(params[:kf_staff])
        redirect_to staffs_path
      else
        render :edit
      end
    end

    def destroy
      staff = @staffs.find(params[:id])
      staff.destroy
      redirect_to :back
    end

    def validate_staff_no
      if params[:staff_id] == '0'
        staff = Kf::Staff.new(site_id: current_site.id, staff_no: params[:staff_no])
      else
        staff = Kf::Staff.find(params[:staff_id])
        staff.staff_no = params[:staff_no]
      end
      render :json => { valid: staff.is_staff_no_valid? } and return
    end

    def validate_staff_role
      if params[:staff_id] == '0'
        staff = Kf::Staff.new(site_id: current_site.id, role: params[:role])
      else
        staff = Kf::Staff.find(params[:staff_id])
        staff.role = params[:role]
      end
      render :json => { valid: staff.is_role_valid? } and return
    end

    private

    def load_staffs
      @staffs = current_site.wx_mp_user.kf_account.try(:staffs) || []
    end

  end
end

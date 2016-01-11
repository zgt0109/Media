class Huodong::Brokerage::SettingsController < ApplicationController

    def index
        @brokerage = current_site.brokerage_setting
        @brokerage ||= ::Brokerage::Setting.new(activity: Activity.new(activity_type_id: 77))
    end

    def create
      @brokerage = ::Brokerage::Setting.new(params[:brokerage_setting])
      if @brokerage.save
        redirect_to brokerage_settings_path, notice: "保存成功"
      else
          render_with_alert :index, "保存失败，#{@brokerage.errors.full_messages.first}"
      end
    end

    def update
        @brokerage = current_site.brokerage_setting
        if @brokerage.update_attributes(params[:brokerage_setting])
            redirect_to brokerage_settings_path, notice: "保存成功"
        else
            render_with_alert :index, "保存失败，#{@brokerage.errors.full_messages.first}"
        end
    end

end
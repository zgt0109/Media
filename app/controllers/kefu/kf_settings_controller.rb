module Kefu
  class KfSettingsController < ApplicationController

    def update
      flash[:notice] = "保存成功"
      wx_mp_user = current_site.wx_mp_user
      if wx_mp_user
        wx_mp_user.kefu_enter = params[:kefu_enter]
        wx_mp_user.kefu_quit = params[:kefu_quit]
        wx_mp_user.save
      end
      redirect_to kf_settings_path
    end

    def reset
      wx_mp_user = current_site.wx_mp_user
      if wx_mp_user
        wx_mp_user.kefu_enter = nil
        wx_mp_user.kefu_quit = nil
        wx_mp_user.save
      end
      flash[:notice] = "重置成功"
      redirect_to kf_settings_path
    end
    
  end
end

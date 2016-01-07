class WifiClientsController < ApplicationController

  def index
    @wifi_client = current_user.wifi_clients.first || current_user.wifi_clients.new
    # binding.pry
    if @wifi_client.new_record? || @wifi_client.activities.count == 0
      @wifi_client.activities.new(:name => "wifi",:wx_mp_user_id => current_user.wx_mp_user.id, :activity_type_id => 51)
    end
  end

  def create
    @wifi_client = WifiClient.new(params[:wifi_client])
    # binding.pry
    @wifi_client.save!
    redirect_to :back, notice: '创建成功!'
  end

  def update
    @wifi_client = current_user.wifi_clients.find(params[:id])
    @wifi_client.update_attributes(params[:wifi_client])
    redirect_to :back, notice: '更新成功!'
  end

  def mobile
    @wifi_client = current_user.wifi_clients.first
    if @wifi_client
      render layout: 'application_pop'
    else
      respond_to do |format|
        format.js
      end 
    end
  end

  def bind

  end

  def modify_bind

  end

end

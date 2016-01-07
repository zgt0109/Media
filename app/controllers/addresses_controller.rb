#class AddressesController < ApplicationController
class AddressesController < ActionController::Base

  def cities
    render json: { citys: City.where(province_id: params[:province_id]).order(:sort).pluck(:name, :id) }
  end

  def districts
    render json: { districts: District.where(city_id: params[:city_id]).order(:sort).pluck(:name, :id) }
  end

end

# -*- coding: utf-8 -*-
class Site::PagesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  layout 'home'

  def micro_channel
    @html_class = 'platform'
    @navigations = YAML.load_file("#{Rails.root}/config/navigations.yml")
  end

  def agents_inquiry
    @agents = Agent.where("name = ?", params[:name])
    respond_to do |format|
      format.html {}
      format.js do
        return render json: {code: 1, name: params[:name]}  if @agents.count.to_i > 0
        return render json: {code: 0}  if @agents.blank?
      end
    end
  end

end

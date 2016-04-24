class Pro::WshopsController < ApplicationController
  def index
    current_site.update_attributes(token: SecureRandom.urlsafe_base64(60)) unless current_site.token.present?

    if Rails.env == 'production'
      render text: "ec.winwemedia.com/admin/products?auth_token=#{current_site.token}"
    else
      render text: "ec.testing.winwemedia.com/admin/products?auth_token=#{current_site.token}"
    end
  end
end

class Pro::WshopsController < ApplicationController
  def index
    current_user.update_attributes(token: SecureRandom.urlsafe_base64(60)) unless current_user.token.present?

    if Rails.env == 'production'
      render text: "ec.winwemedia.com/admin/products?auth_token=#{current_user.token}"
    else
      render text: "ec.testing.winwemedia.com/admin/products?auth_token=#{current_user.token}"
    end
  end
end

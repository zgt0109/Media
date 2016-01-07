class Pro::WshopsController < Pro::EcBaseController
  def index
    current_user.update_attributes(auth_token: SecureRandom.urlsafe_base64(60)) unless current_user.auth_token.present?


    if Rails.env == 'production'
      render text: "ec.winwemedia.com/admin/products?auth_token=#{current_user.auth_token}"
    else
      render text: "ec.testing.winwemedia.com/admin/products?auth_token=#{current_user.auth_token}"
    end
  end
end

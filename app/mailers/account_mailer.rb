class AccountMailer < ActionMailer::Base
  default from: "forget_password@winwemedia.com"

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "微枚迪密码找回"
  end
end

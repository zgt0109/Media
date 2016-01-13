class VipUserMailer < ActionMailer::Base

  default :from => "forget_password@winwemedia.com"

  def transaction_email(account_password)
    @notice = "你的密码是：#{account_password.password_digest}，为保证账户安全请尽快修改密码！"
    mail(:to => account_password.email, :subject => "交易密码找回")
  end

  # 自动绑定失败通知
  def binds_failure_notification(body, subject = "#{Rails.env}: 公众账号自动绑定失败通知 #{Time.now}")
    if Rails.env.production?
      to = ["liang.wk@winwemedia.com, guorongxu@weiligongshe.com"]
    else
      to = ["liang.wk@winwemedia.com"]
    end
    mail(:to => to, :subject => subject, :body => body)
  end

  def find_password_email(vip_user)
    @notice = "您在公众账号：#{vip_user.supplier.nickname}中的会员卡余额支付密码已重置，新密码为：#{vip_user.password}，为确保支付安全请尽快修改此密码！"
    mail(:to => vip_user.password_email, :subject => "会员卡余额支付密码找回")
  end

end

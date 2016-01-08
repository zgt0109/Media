VipUserChecker = Struct.new(:vip_user, :openid, :trade_token) do
  def valid?
    vip_user && vip_user.normal? && valid_openid?
  end

  def error?
    !valid?
  end

  def error_message(prefix = nil)
    case
    when vip_user.blank?      then "#{prefix}找不到会员"
    when openid_invalid?      then "#{prefix}找不到会员"
    when trade_token_invalid? then "#{prefix}找不到会员"
    when vip_user.deleted?    then "#{prefix}找不到会员"
    when vip_user.freeze?     then "#{prefix}会员卡已被冻结"
    when vip_user.pending?    then "#{prefix}会员卡正在审核中"
    when vip_user.rejected?   then "#{prefix}会员卡申请已被拒绝"
    end
  end

  private
    def valid_openid?
      openid.blank? || vip_user.wx_user.openid == openid
    end

    def valid_trade_token?
      trade_token.blank? || vip_user.trade_token == trade_token
    end

    def openid_invalid?
      !valid_openid?
    end

    def trade_token_invalid?
      !valid_trade_token?
    end
end

class SnCode < ActiveRecord::Base

  enum_attr :status, :in => [
      ['unused', 1, '未使用'],
      ['using', 2, '使用中'],
      ['used', 3, '已使用'],
  ]

  def self.use_code!(mp_user, wx_user)
    got_sn_code = SnCodeScanLog.where(site_id: mp_user.site_id, user_id: wx_user.user_id).exists?
    return "您已经获取过了，sn码为:#{sn_code_scan_log.code}" if got_sn_code

    sn_code = SnCode.unused.first
    return '随机码已经被抢光了' if sn_code.nil?
    SnCodeScanLog.create(site_id: mp_user.site_id, user_id: wx_user.user_id, code: sn_code.code)
    sn_code.using!
    sn_code.code
  end

end

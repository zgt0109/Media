class SnCode < ActiveRecord::Base
  # attr_accessible :title, :body
  #validates :code, uniqueness: true

  enum_attr :status, :in => [
      ['unused', 1, '未使用'],
      ['using', 2, '使用中'],
      ['used', 3, '已使用'],
  ]


  def self.use_code!(mp_user, wx_user)
    got_sn_code = SnCodeScanLog.where(supplier_id: mp_user.supplier_id, wx_user_id: wx_user.id).exists?
    return "您已经获取过了，sn码为:#{sn_code_scan_log.code}" if got_sn_code

    sn_code = SnCode.unused.first
    return '随机码已经被抢光了' if sn_code.nil?
    SnCodeScanLog.create(supplier_id: mp_user.supplier_id, wx_mp_user_id: mp_user.id, wx_user_id: wx_user.id, code: sn_code.code)
    sn_code.using!
    sn_code.code
  end

end

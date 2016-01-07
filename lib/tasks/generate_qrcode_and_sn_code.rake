namespace :generate_qrcode_and_sn_code do
  require 'uuidtools'
  require 'uri'

  #desc 'main batch'
  #task hongxing_data: [
  #  :get_qrcode,
  #  :generate_sn_code
  #]

  desc 'generate sn_code'
  task :generate_sn_code => :environment do
    supplier_id = 10010
    wx_mp_user = WxMpUser.find_by_supplier_id(supplier_id)
    time = Time.now
    inserts = []
    sum = 1
    count = 10000
    return puts "-------------mp_user Invalid ----------------" unless wx_mp_user
    puts "--------------start generate sn code -------------------------------"
    while sum <= count
      inserts << "(#{supplier_id},#{wx_mp_user.id},'#{rand_uuid}','#{time}','#{time}')"
      sum += 1
    end
    inserts.in_groups_of(100,false).each_with_index do |insert_sqls, index|
      sql = "INSERT INTO sn_codes (supplier_id,wx_mp_user_id,code,created_at, updated_at) VALUES #{insert_sqls.join(', ')}"
      ActiveRecord::Base.connection.execute(sql)
      sleep(2)
      puts "-------------------finish #{100 * (index + 1)}/#{count}--------------------------"
    end
    puts '--------------Done!-------------------------------'
  end

  desc 'initialize qrcode'
  task :get_qrcode => :environment do
    supplier_id = 10115
    scene_id = 1
    wx_mp_user = WxMpUser.find_by_supplier_id(supplier_id)
    ticket = get_ticket wx_mp_user,scene_id
    if ticket.present?
      select_attrs = {supplier_id:wx_mp_user.supplier_id, wx_mp_user_id: wx_mp_user.id, action_name: Qrcode::QR_LIMIT_SCENE, scene_id: scene_id}
      qrcode = Qrcode.where(select_attrs).first || Qrcode.new()
      attrs = {supplier_id:wx_mp_user.supplier_id, wx_mp_user_id: wx_mp_user.id, name: "锦江二维码推广", action_name: Qrcode::QR_LIMIT_SCENE, scene_id: scene_id,ticket: ticket, description: "锦江二维码推广"}
      qrcode.attributes = attrs
      if qrcode.save
        puts '--------------Done!-------------------------------'
      else
        puts '--------------faild -> save faild-------------------'
      end
    else
      puts '--------------faid -> no ticket-------------------------------'
    end
  end


  def rand_uuid
    UUIDTools::UUID.random_create.to_s[0,6]
  end


  def get_ticket wx_mp_user,scene_id
    #return '' unless wx_mp_user.service?
    appid = wx_mp_user.app_id#'wxda25202e2d4a4726'#
    secret = wx_mp_user.app_secret #'03d706fe96a4f286dc06e066631aba7a'#
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}"
    url = URI::encode(url)
    result = RestClient.get(url)
    info = JSON(result)
    access_token = info['access_token']
    return '' unless access_token.present?
    attrs = "{\"action_name\": \"QR_LIMIT_SCENE\", \"action_info\": {\"scene\": {\"scene_id\": #{scene_id}}}}"
    result = RestClient.post("https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}", attrs)
    info = JSON result
    info['ticket']
  end
end
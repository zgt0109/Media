class VipApiSetting < ActiveRecord::Base
  belongs_to :site
  belongs_to :vip_card

  acts_as_enum :auth_type, in: [
    [ 'basic_auth',  'HTTP基本认证' ],
    [ 'digest_auth', 'HTTP摘要认证' ]
  ]

  acts_as_enum :status, in: [
    [ 'disabled', 0, '停用' ],
    [ 'enabled',  1, '启用' ]
  ]

  store :metadata, accessors: [ :args_submit_type, :headers ]

  acts_as_enum :args_submit_type, in: [
    [ 'form_args', '0', 'Form' ],
    [ 'raw_args',  '1', 'Raw' ]
  ]

  def open_card( vip_user )
    api = VipExternalHttpApi.where(vip_card_id: vip_card_id).open_card.first
    return unless api
    query = vip_user.custom_field_with_value_names.merge!( name: vip_user.name, mobile: vip_user.mobile, uid: vip_user.wx_user.openid )

    http_method, url, options = httparty_args( api, query )
    logger.info "*************************************************#{__method__} options=#{options}"
    json = JSON( HTTParty.__send__(http_method, url, options).body )
    logger.info "*************************************************#{__method__} repsonse: #{json}"
    attrs = {is_sync: true}.merge!(json.slice('card_no', 'usable_points', 'usable_amount'))
    attrs['user_no'] = attrs.delete('card_no')
    attrs.delete('usable_points') if attrs['usable_points'].to_i <= 0
    attrs.delete('usable_amount') if attrs['usable_amount'].to_i <= 0
    vip_user.update_attributes(attrs) if attrs['user_no'].present?
  end


  def get_user_info( mobile )
    api = VipExternalHttpApi.where(vip_card_id: vip_card_id).get_user_info.first
    return unless api
    http_method, url, options = httparty_args( api, { mobile: mobile } )
    logger.info "*************************************************#{__method__} options=#{options}"
    JSON( HTTParty.__send__(http_method, url, options).body )
  end

  def get_transactions( query = {} )
    api = VipExternalHttpApi.where(vip_card_id: vip_card_id).get_transactions.first
    return unless api
    http_method, url, options = httparty_args( api, query )
    logger.info "*************************************************#{__method__} options=#{options}"
    JSON( HTTParty.__send__(http_method, url, options).body )
  end

  def url_for( api )
    full_path = "#{callback_domain.to_s.sub(/\/$/, '')}/#{api.path.to_s.sub(/^\//, '')}"
    "http://#{full_path.sub(/^http:\/\//, '')}"
  end

  def json_headers
    { 'Content-Type' => 'application/json' }
  end

  def add_auth( options )
    if auth_type.present?
      options[auth_type.to_sym] = { username: auth_username, password: auth_password }
    end
  end

  def httparty_args( api, query )
    url = url_for(api)
    options = { headers: json_headers }
    if raw_args?
      options[:body] = query.to_json
    else
      options[:query] = query
    end
    add_auth( options )
    [ api.http_method, url, options ]
  end

end

class BqqController < ApplicationController
  skip_before_filter *ADMIN_FILTERS

  include MobileHelper

  def auth
    WinwemediaLog::BqqApi.add("auth request params: #{params}")

    xml = params[:xml]
    if xml.blank?
      render json: { errcode: 40001, errmsg: 'invalid xml data' }
    elsif check_signatrue?(params)
      if xml[:uin].blank? or xml[:name].blank?
        return render json: { errcode: 40002, errmsg: 'invalid uin or name' }
      end

      name, uin = xml[:name], xml[:uin]
      supplier_nickname = [ name, uin ].join('$')
      wx_mp_user_name = xml[:wxName].present? ? xml[:wxName] : name

      api_user = ApiUser.bqq.where(uid: uin).first

      auth_attrs = { nickname: name, name: name, description: params.to_s }
      supplier_attrs = { nickname: supplier_nickname, company_name: name, qq: uin, privileges: xml[:privilege] }
      wx_mp_user_attrs = { name: wx_mp_user_name, uid: xml[:wxID], app_id: xml[:appID] }

      if api_user
        supplier = api_user.supplier
        supplier.update_attributes(supplier_attrs)
        api_user.update_attributes(auth_attrs)
      else
        Supplier.transaction do
          password = SecureRandom.hex(5)
          supplier = Supplier.create!(supplier_attrs.merge(account_type: 4, password: password, password_confirmation: password))
          api_user = ApiUser.where(provider: 'bqq', supplier_id: supplier.id, uid: uin).first_or_create!(auth_attrs)
        end
      end

      api_user.refresh_token

      if supplier.wx_mp_user
        supplier.wx_mp_user.update_attributes(wx_mp_user_attrs)
      else
        WxMpUser.where(supplier_id: supplier.id).first_or_create(wx_mp_user_attrs)
      end

      render json: { uin: uin, access_token: api_user.token, url: bqq_login_url }
    else
      render json: { errcode: 40003, errmsg: 'access denied' }
    end
  rescue => error
    render json: { errcode: -1, errmsg: "system error: #{error}" }
  end

  def login
    WinwemediaLog::BqqApi.add("login request params: #{params}")

    session[:pc_supplier_id] = nil

    if params[:access_token].blank?
      return render json: { errcode: 40004, errmsg: "invalid access_token" }
    end

    api_user = ApiUser.where(token: params[:access_token]).first

    if api_user && api_user.uid == params[:uin]
      session[:pc_supplier_id] = api_user.supplier_id
      redirect_to websites_url
    else
      WinwemediaLog::BqqApi.add("login invalid request params: #{params}")
      render json: { errcode: 40004, errmsg: "invalid access_token" }
    end
  end

  def website_menus
    begin
      WinwemediaLog::BqqApi.add("website_menus request params: #{params}")

      api_user = ApiUser.where(uid: params[:uin]).first
      website = Website.micro_site.where(supplier_id: api_user.try(:supplier_id)).first
      if website
        @website_menus = WebsiteMenu.root.where(website_id: website.id)
        sub_menus = get_website_menus(@website_menus)
        menus = [ id: website.id, name: website.name, url: mobile_root_url(supplier_id: website.supplier_id), sub_menus: sub_menus ]
      else
        @website_menus = []
        menus = []
      end
    rescue => error
      WinwemediaLog::BqqApi.add("website_menus error: #{error.message} > #{error.backtrace}")
      menus = []
    end

    json_data = menus.to_json

    if params[:cb].present?
      render text: "#{params[:cb]}&#{params[:cb]}(#{json_data})"
    else
      render json: json_data
    end
  end

  def autoreply
    @activity = Activity.find(params[:activity_id].to_i)
    result = @activity.send_reply_to_bqq

    render json: result
  rescue => error
    render json: { errcode: 4001, errmsg: "record not exist: #{error}" }
  end

  def check_signatrue?(options)
    app = ApiApp.bqq
    if app && options[:signature] == Digest::SHA1.hexdigest([options[:uin], options[:nonce], options[:timestamp], app.token].sort.join)
      return true
    else
      return false
    end
  end

end

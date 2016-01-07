class Api::V1::WbbsController < Api::BaseController
  before_filter :cors_set_access_control_headers

  def find
    keyword, supplier_id, auth_token= params.values_at(:keyword, :supplier_id, :auth_token)

    return render json: { errcode: 1, errmsg: "Missing auth_token" } unless auth_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "Missing keyword" } unless keyword.present?
    return render json: { errcode: 1, errmsg: "Missing supplier_id" } unless supplier_id.present?

    wbbs = Activity.get_activity_by_keyword(keyword, supplier_id)
    if wbbs.present?
     return render json: { errcode: 0, supplier_id: supplier_id, aid: wbbs.id }
   else
    return render json: { errcode: 1, errmsg: "request wbbs not exists." }
   end
  rescue => e
    render json: { errcode: 1, errmsg: "request failed." }
  end

  def create_wbbs

    name, keyword, supplier_id, summary, auth_token, qiniu_logo_key, qiniu_pic_key = params.values_at(:name, :keyword, :supplier_id, :summary, :auth_token, :qiniu_logo_key, :qiniu_pic_key)

    return render json: { errcode: 1, errmsg: "Missing auth_token" } unless auth_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "Missing name" } unless name.present?
    return render json: { errcode: 1, errmsg: "Missing supplier_id" } unless supplier_id.present?
    return render json: { errcode: 1, errmsg: "Missing keyword" } unless keyword.present?
    return render json: { errcode: 1, errmsg: "duplicate keword" } if Activity.valid.where(supplier_id: supplier_id, keyword: keyword).exists?

    supplier = Supplier.find_by_id(supplier_id)
    return render json: { errcode: 1, errmsg: "supplier not found" } unless supplier.present?

    wx_mp_user_id = supplier.wx_mp_user.id rescue nil

    return render json: { errcode: 1, errmsg: "wx_mp_user not found" } unless wx_mp_user_id.present?

    activity = Activity.create(status: 1, name: name, keyword: keyword, ready_at:  Time.now, start_at:  Time.now, end_at: Time.now + 100.years,
                        supplier_id: supplier_id, wx_mp_user_id: wx_mp_user_id, activity_type_id: 49, qiniu_pic_key: qiniu_pic_key, summary: summary)
    wbbs = supplier.wbbs_communities.create(name: name, supplier_id: supplier_id, wx_mp_user_id: wx_mp_user_id, logo: qiniu_logo_key)
    wbbs.activity = activity
    if activity && wbbs
      render json: { errcode: 0, supplier_id: supplier_id, aid: activity.id }
    else
      render json: { errcode: 1, errmsg: "request failed." }
    end
  end

  private
    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

end

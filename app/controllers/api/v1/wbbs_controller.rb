class Api::V1::WbbsController < Api::BaseController
  before_filter :cors_set_access_control_headers

  def find
    keyword, site_id, auth_token= params.values_at(:keyword, :site_id, :auth_token)

    return render json: { errcode: 1, errmsg: "Missing auth_token" } unless auth_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "Missing keyword" } unless keyword.present?
    return render json: { errcode: 1, errmsg: "Missing site_id" } unless site_id.present?

    wbbs = Activity.get_activity_by_keyword(keyword, site_id)
    if wbbs.present?
     return render json: { errcode: 0, site_id: site_id, aid: wbbs.id }
   else
    return render json: { errcode: 1, errmsg: "request wbbs not exists." }
   end
  rescue => e
    render json: { errcode: 1, errmsg: "request failed." }
  end

  def create_wbbs
    name, keyword, site_id, summary, auth_token, logo_key, pic_key = params.values_at(:name, :keyword, :site_id, :summary, :auth_token, :logo_key, :pic_key)

    return render json: { errcode: 1, errmsg: "Missing auth_token" } unless auth_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "Missing name" } unless name.present?
    return render json: { errcode: 1, errmsg: "Missing site_id" } unless site_id.present?
    return render json: { errcode: 1, errmsg: "Missing keyword" } unless keyword.present?
    return render json: { errcode: 1, errmsg: "duplicate keword" } if Activity.valid.where(site_id: site_id, keyword: keyword).exists?

    site = Site.find_by_id(site_id)
    return render json: { errcode: 1, errmsg: "site not found" } unless site.present?

    activity = Activity.create(status: 1, name: name, keyword: keyword, ready_at:  Time.now, start_at:  Time.now, end_at: Time.now + 100.years,
                        site_id: site_id, activity_type_id: 49, pic_key: pic_key, summary: summary)
    wbbs = site.wbbs_communities.create(name: name, site_id: site_id, logo: logo_key)
    wbbs.activity = activity
    if activity && wbbs
      render json: { errcode: 0, site_id: site_id, aid: activity.id }
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

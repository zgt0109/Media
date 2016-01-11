class Biz::VipCardsController < Biz::VipController
  before_filter :fetch_activity_and_vip_card
  skip_before_filter :require_vip_card, only: [:settings, :index]

  def index
    @activity_notice = @activity.active_activity_notice || @activity.activity_notices.create({description: "会员卡", activity_status: 1}.merge({title: "尊敬的会员{name}", summary: "尊敬的会员{name},您的会员卡号为{card_id},快来点击查看优惠信息吧!!"}))
    @activity.ready_activity_notice || @activity.activity_notices.create({title: "申请微信会员卡", summary: "您尚未申请会员特权,快来点击申领吧!!", description: "申请微信会员卡", activity_status: 0})
  end

  def settings
  end

  def marketing

  end

  def help
  end

  def update
    @vip_card.attributes = params[:vip_card]
    @vip_card.save(validate: false)
    redirect_to :back, notice: '保存成功'
  end

  def conditions
    @custom_fields = @vip_card.custom_fields.normal.order(:position).page(params[:page]).per(20)
  end

  def set_is_open_points
    @vip_card.toggle! :is_open_points
    render js: "showTip('success', '操作成功');"
  end

  def toggle_use_vip_avatar
    use_vip_avatar = @vip_card.use_vip_avatar? ? '0' : '1'
    @vip_card.update_attributes(use_vip_avatar: use_vip_avatar)
    render js: "showTip('success', '操作成功');"
  end

  def stop
    @vip_card.stopped!
    redirect_to :back, notice: '操作成功'
  end

  def start
    @vip_card.start!
    redirect_to :back, notice: '操作成功'
  end

  def remove_logo
    @vip_card.update_column(:logo, nil)
    @vip_card.update_column(:logo_key, nil)

    # remove logo url from settings_json
    settings_logo = JSON.parse @vip_card.settings_json
    settings_logo['cardLogo'] = {'src' => nil, 'left' => 10, 'top' => 10} # default settings for logo
    @vip_card.settings_json = settings_logo.to_json
    @vip_card.save

    redirect_to :back, notice: '操作成功'
  end

  def end_introduce
    @vip_card.show_introduce = 'end'
    @vip_card.save
    render nothing: true
  end

  def template
    if request.post?
      @vip_card.update_column :template_id, params[:template_id]
      render json: { message: '设置成功' }
    end
  end

  def toggle_vip_importing
    @vip_card.update_attributes(vip_importing_enabled: !@vip_card.vip_importing_enabled?)
    render json: { message: '设置成功', vip_importing_enabled: @vip_card.vip_importing_enabled? }
  end

  def toggle_label_custom_field
    custom_field_id = params[:custom_field_id].to_i
    if @vip_card.labeled_custom_field_ids.include?(custom_field_id)
      @vip_card.labeled_custom_field_ids.delete(custom_field_id)
    else
      @vip_card.labeled_custom_field_ids += [custom_field_id]
    end
    @vip_card.labeled_custom_field_ids = @vip_card.labeled_custom_fields.pluck(:id)
    @vip_card.save if @vip_card.labeled_custom_field_ids.length <= 2
    render nothing: true
  end
end

# -*- encoding : utf-8 -*-
class Biz::ActivityFormsController < ActivitiesController
  before_filter :restrict_trial_supplier, except: :index

  def index
    @activity_type_id = 10
    #@search = current_user.activities.show.where(:activity_type_id => @activity_type_id).order('created_at desc').search(params[:search])
    #@activities = @search.page(params[:page])
    @activity_id = params[:search][:id_eq] if params[:search].present?

    @total_activities = current_user.activities.show.where("activities.activity_type_id = 10").order('activities.id DESC')
    case params[:status]
      when '-1'
        @activities = @total_activities.where("((activities.status = 0 or activities.status = 1) and activities.end_at is not null and activities.end_at < '#{Time.now}') or activities.status = -1")
      when '0'
	@activities = @total_activities.where("((activities.status = 0 and activities.start_at is null and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) or ((activities.status = 0 or activities.status = 1) and activities.start_at is not null and activities.start_at > '#{Time.now}'))")
      when '1'
        @activities = @total_activities.where("(( (activities.status = 0 or activities.status = 1) and (activities.start_at is not null and activities.start_at < '#{Time.now}') and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) or (activities.status = 1 and activities.start_at is null and (activities.end_at is null or (activities.end_at is not null and activities.end_at > '#{Time.now}'))) )")
      else
        @activities = @total_activities
    end
    @search     = @activities.search(params[:search])
    @activities = @search.page(params[:page])
  end

  def new
    @activity = current_user.activities.new(activity_type_id: 10, wx_mp_user_id: current_user.wx_mp_user.try(:id))
    render "show"
  end

  def show
    @activity = current_user.activities.find(params[:id])
  end

  def create
    @activity = current_user.activities.new(params[:activity])
    self.extend_format
    @activity.name ||= @activity.activity_notices.first.try :title
    if activity_time_invalid?
      return render_with_alert "show", TIME_ERROR_MESSAGE
    end
    if  @activity.save
      return redirect_to edit_fields_activity_forms_path(id: @activity.id, redirect_to_on_pop_close: "/activity_forms")
    else
      render_with_alert "show", "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
  end

  def extend_format
    return unless @activity
    extent_attrs = params[:activity][:extend].to_h
    %w(template_color font_color closing_note allow_repeat_apply show_enroll_list).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", extent_attrs[method_name])
    end
    %i(enrolled_tip unenrolled_tip cannot_enroll_tip template_qiniu_key template_id related_link_type related_album_id related_website_id related_scene_id).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", params[method_name])
    end
  end

  def update
    @activity = current_user.activities.find(params[:id])
    self.extend_format
    #@activity.extend.closing_note = params[:extend_closing_note] if params[:extend_closing_note]
    #@activity.extend.allow_repeat_apply = params[:allow_repeat_apply].to_i
    @activity.name ||= @activity.activity_notices.first.try :title
    if activity_time_invalid?
      return render_with_alert "show", TIME_ERROR_MESSAGE
    end
    if @activity.update_attributes(params[:activity])
      redirect_to "/activity_forms", notice: '保存成功'
    else
      render_with_alert "show", "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
  end

  def edit_audited
    @activity = current_user.activities.find(params[:id])
    @activity.update_attributes!({audited: @activity.audited? ? false : true})
    render js: "showTip('success', '操作成功');"
  end

  def delete
    if @activity.deleted!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def edit_fields
    if flash[:errors].is_a?(Array)
      if flash[:errors].length > 0
        @notice = flash[:errors].first
      else
        @notice = "报名字段保存成功！"
      end
    end
    @activity = Activity.where(id: params[:id]).first
    @supplier_id = current_user.id
    @fields = ActivityFormField.where(supplier_id: [0, @supplier_id])
    @checked_fields = ActivityForm.where(activity_id: @activity.id)
    # 如果没有选择过字段，自动加入姓名字段
    @checked_fields = [ActivityForm.add_new(1, @activity.id, sort: 1, required: true), ActivityForm.add_new(2, @activity.id, sort: 2, required: true)] if @checked_fields.blank?
    @required_field_names = @checked_fields.map{|af| af.required && af.field_name || nil}.compact
    @checked_fields_names = @checked_fields.map{|cf| cf.field_name}
    # render layout: 'application_pop'
  end

  def checked_field
    form_field = params[:form_field_id].to_i > 0 && ActivityFormField.where(id: params[:form_field_id]).first
    if form_field
      sort_id =  params[:sort_id]
      activity_form = ActivityForm.new(field_name: form_field.name, field_value: form_field.value, sort: sort_id)
      render :partial => "checked_field", :locals => {f: activity_form, required: false}
    else
      render :text => "查询不到任何记录： ActivityFormField.where(id: #{params[:form_field_id]}).first"
    end
  end

  def edit_fields_save
    @errors = []
    @activity_id, @new_field = params[:id].to_i, params[:new_field].to_s.strip
    @supplier_id = current_user.id
    @errors << "无法获取当前用户 id" unless @supplier_id > 0
    @errors << "无法获取活动 id" unless @activity_id > 0
    @errors << "字段名称不能为空！" if @new_field.empty?
    if @errors.blank?
      max_id = ActivityFormField.select("max(id) as max_id").first.try(:max_id)
      same_name_field = ActivityFormField.where(value: @new_field, supplier_id: [0, @supplier_id]).first
      if same_name_field
        @errors << "名称为【#{@new_field}】的字段已经存在，不能重复添加！"
      else
        create_field = ActivityFormField.create(value: @new_field, supplier_id: @supplier_id, name: "f_#{max_id + 1}")
        if create_field.persisted?
          @new_li = "<label> <input class=\"ace\" form_field_id=\"#{create_field.id}\" id=\"#{create_field.name}\" name=\"#{create_field.name}\" type=\"checkbox\" value=\"#{create_field.value}\"> <span class=\"lbl\">#{create_field.value}</span></label>"
        else
          @errors << create_field.errors.first.join(" ")
        end
      end
    end
    render :json => {errors: @errors, new_li: @new_li.to_s}
  end

  def checked_fields_save
    @errors = []
    @activity_id = params[:id].to_i
    @supplier_id = current_user.id
    @errors << "无法获取当前用户 id" unless @supplier_id > 0
    @errors << "无法获取活动 id" unless @activity_id > 0
    @add_count = @update_count = @del_count = 0
    if @errors.blank?
      @fields = params[:fields]
      @field_names = @fields.keys
      @required_field_names = params[:requires].try(:keys) || []

      @old_fields = ActivityForm.where(activity_id: @activity_id)
      @old_fields.each do |old|
        if @field_names.delete(old.field_name)
          # 如果旧字段在新字段集里存在，只修改旧字段的排序值
          old.sort = @fields[old.field_name]
          if @required_field_names.include?(old.field_name)
            old.required = true
          else
            old.required = false
          end
          old.save
          @update_count += 1
        else
          # 如果旧字段在新字段集里不存在，则删除这个旧字段
          old.delete
          @del_count += 1
        end
      end
      @field_names.each do |field_name|
        aff = ActivityFormField.where(name: field_name, supplier_id: [0, @supplier_id]).first
        if aff
          # 增加字段
          if @required_field_names.include?(field_name)
            required = true
          else
            required = false
          end
          ActivityForm.add_new(aff.id, @activity_id, sort: @fields[field_name], required: required)
          @add_count += 1
        end
      end
    end
    # render :text => {errors: @errors, add_count: @add_count, update_count: @update_count, del_count: @del_count}.inspect
    flash[:errors] = @errors
    redirect_to "/activity_forms"
  end

end

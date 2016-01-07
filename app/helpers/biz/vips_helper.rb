module Biz::VipsHelper

  def vip_user_search_path(action_name)
    case action_name
      when 'pending'  then pending_vip_users_path
      when 'rejected' then rejected_vip_users_path
      when 'freezed'  then freezed_vip_users_path
    end
  end

  def given_group_name(giver)
    case giver.given_group_id
    when -1 then '全部用户'
    when -2 then '未分组'
    else
      giver.given_group.try(:name)
    end
  end

  def vip_user_count_by_group(group)
    vip_users = current_user.vip_users.visible
    case group
    when -1 then vip_users.count
    when -2 then vip_users.where(vip_group_id: nil).count
    else
      group.vip_users_count
    end
  end

  def vip_user_count_by_birthday_month(month)
    @birthday_field ||= @vip_card.custom_fields.normal.where(name: '生日').first
    if @birthday_field
      @birthday_values ||= @birthday_field.custom_values.to_a
      @birthday_values.count { |v| Date.parse(v.value).month == month if v.value.present? } rescue 0
    else
      0
    end
  end

  def vip_grades_time(value)
    nums = { 6 => '半', 12 => '一', 24 => '两', 36 => '三', 48 => '四', 60 => '五' }
    "自领卡之日起满#{nums[value]}年用户"
  end

  def has_privilege_for?( privilege_code )
    return false unless current_user
    return true  unless current_user.bqq_account?
    current_user.has_privilege_for?( privilege_code )
  end

  def vip_admin_path?
    return true if controller_name == 'vip_users' && action_name =~ /index|show|pending|rejected|deleted|freezed/
    return true if controller_name =~ /vip_importings|vip_statistics/
  end

  def vip_report_path?
    controller_name == 'vip_records'
  end

  def vip_base_path?
    controller_name == 'vip_cards' && action_name =~ /index|conditions|template|settings/
  end

  def vip_marketing_path?
    controller_name =~ /vip_grades|vip_privileges|vip_groups|vip_packages|vip_package_items|point_types|point_gifts|vip_cares|vip_message_plans|vip_transactions/ || request.path == marketing_vip_cards_path
  end

  def link_to_li( text, path, options = {} )
    options[:class] = 'active' if options[:class].blank? && request.path == path
    content_tag :li, options do
      link_to text, path
    end
  end

  def item_consume_class_name( item_consume )
    if item_consume.can_use?
      'normal'
    elsif item_consume.used?
      'used'
    else
      'exceed'
    end
  end

  def point_gift_sku_to_human( sku )
    return '不限' if sku == -1
    return '兑换完毕' if sku <= 0
    sku
  end

  def vip_labeled_values(vip_card, vip_user)
    @labeled_custom_fields ||= vip_card.labeled_custom_fields
    @labeled_custom_fields.map do |custom_field|
      vip_user.custom_values.find{ |v| v.custom_field_id == custom_field.id }.try(:value) || '无'
    end.join('&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;')
  end

  def all_vip_users_count
    @all_vip_users_count ||= current_user.vip_users.visible.count
  end

  def no_group_vip_users_count
    @no_group_vip_users_count ||= current_user.vip_users.visible.where(vip_group_id: nil).count
  end

  def vip_card_settings_data(vip_card, vip_user = nil)
    data = if vip_card.try(:settings_json).present?
      raw vip_card.try(:settings_json)
    else
      JSON.generate({
        cardLevel: {
            fontSize: vip_card.try(:card_font_size).presence || "16px",
            left: 520,
            top: 10,
        },
        cardNumber: {
            fontSize: vip_card.try(:name_font_size).presence || "14px",
            left: 520,
            top: 310,
        },
        cardLogo: {
            src: vip_card.try(:logo_url),
            left: 10,
            top: 10
        },
        cardList: [
          {
            level: '{{会员等级}}',
            number: '{{会员卡号}}',
            tplId: 'tpl01',
            cardLevelColor: vip_card.try(:card_bg_color),
            cardNumberColor: vip_card.try(:name_bg_color),
            cardBg: vip_card.try(:cover_pic_url)
          }
        ]
      })
    end

    if vip_user
      data.sub!('{{会员等级}}', vip_user.vip_grade_name)
      data.sub!('{{会员卡号}}', vip_user.user_number)
    end
    raw(data)
  end

end

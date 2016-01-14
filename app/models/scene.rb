class Scene < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.mhostname

  enum_attr :scene_type, :in => [
    ['no_redirect', 0, '无跳转'],
    ['bg_redirect', 1, '背景图跳转'],
    ['btn_redirect', 2, '按钮跳转'],
  ]

  enum_attr :button_position, :in => [
    ['bottom', 0, '下'],
    ['middle', 1, '中'],
    ['vbot', 2, '偏下'],
  ]

  enum_attr :menuable_type, :in => [
    ['text', 1, '文本'],
    ["link", 6, '链接'],
    ['tel', 2, '电话'],
    ['vote', 3, '微投票'],
    ['enroll', 4, '微报名'],
    ['surveys', 5, '微调研'],
    ['reservation', 7, '微预定'],
  ]

  belongs_to :activity

  def button_class
    if bottom?
      'bottom'
    elsif middle?
      'middle'
    else
      'vbot'
    end
  end

  def menuable_type_option
    case menuable_type
    when 6 then 'link'
    when 2 then 'tel'
    when 3 then 'vote'
    when 4 then 'enroll'
    when 5 then 'surveys'
    when 6 then 'reservation'
    end
  end

  def pic_url
    qiniu_image_url(pic_key).try(:+, '?imageView/2/w/860/1280')
  end

  def related_link(openid)
    related_link = '#'
    if vote?
      activity =  Activity.vote.find_by_id(menuable_id)
      return related_link unless activity
      related_link = mobile_vote_login_url(site_id: activity.site_id, vote_id: activity.id, openid: openid)
    elsif link?
      related_link = url
    elsif enroll?
      activity = Activity.enroll.find_by_id(menuable_id)
      return related_link unless activity
      related_link = new_app_activity_enroll_url(site_id: activity.site_id, aid: activity.id, openid: openid)
    elsif reservation?
      activity = Activity.reservation.find_by_id(menuable_id)
      return related_link unless activity
      related_link = mobile_reservations_url(site_id: activity.site_id, aid: activity.id, openid: openid)
    elsif surveys?
      activity = Activity.surveys.find_by_id(menuable_id)
      return related_link unless activity
      related_link =  mobile_survey_url(site_id: activity.site_id, id: activity.id, openid: openid)
    end
    related_link
  end

  def button_pic_url
    qiniu_image_url(button_pic_key)
  end

end

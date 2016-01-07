module InteractionsHelper
  def enrolls_path?
    controller_name =~ /activity_forms|activity_enrolls/
  end

  def votes_path?
    return true if controller_name == 'activities' && action_name =~ /vote|user_data/
    return true if @activity.try(:vote?)
  end

  def surveys_path?
    return true if controller_name == 'activity_survey_questions'
    return true if controller_name == 'activities' && action_name =~ /survey/
    return true if @activity.try(:surveys?)
  end

  def albums_path?
    controller_name == 'albums'
  end

  def leaving_messages_path?
    controller_name == 'leaving_messages'
  end

  def greet_cards_path?
    controller_name =~ /greets|greet_cards/
  end

  def wbbs_path?
    controller_name =~ /wbbs_topics|wbbs_communities/
  end

  def wx_walls_path?
    controller_name =~ /wx_walls|wx_wall_messages|wx_wall_user_prizes|wx_wall_datas/
  end

  def reservations_path?
    controller_name =~ /reservations/
  end

  def scenes_path?
    controller_name =~ /scene/
  end

  def govs_path?
    govmails_path? || govchats_path?
  end

  def govmails_path?
    govmailboxes_path? || controller_name =~ /govmails/
  end

  def govmailboxes_path?
    controller_name =~ /govmailboxes/
  end

  def govchats_path?
    controller_name =~ /govchats/
  end

  def panoramagrams_path?
    controller_name =~ /panoramagrams/
  end

  def interactions_path?
    reservations_path? || enrolls_path? || votes_path? || surveys_path? || albums_path? || leaving_messages_path? || greet_cards_path? || wbbs_path? || scenes_path? || panoramagrams_path?
  end
end

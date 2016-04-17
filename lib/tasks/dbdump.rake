desc 'winwemedia mysqldump'
task :dbdump => :environment do
  puts "*************** start mysqldump"

  site_id = 79750
  wx_mp_user_id = 47445
  
  activity_ids = Activity.where(site_id: 79750).pluck(:id).join(',')
  fight_paper_ids = FightPaper.where(site_id: 79750).pluck(:id).join(',')

  dump = "mysqldump -P1025 -h10.66.46.29 -uroot -p'winwemedia%^&2253' winwemedia_production"
  db = 'keting_db.sql'
  sql_site = "\'site_id = 79750\'"
  sql_activity = "\'activity_id in (#{activity_ids})\'"
  sql_fight = "\'fight_paper_id in (#{fight_paper_ids})\'"
  sql_wx_mp_user = "\'wx_mp_user_id = 47445\'"
  sql_agent = "\'id = 10001\'"

  system "#{dump} activities --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} activity_consumes --where=#{sql_site} --no-create-info >> #{db}"


  enroll_activity_ids = "\'activity_id in (2343498, 2454336, 2454336)\'"
  activity_enroll_ids = ActivityEnroll.where(activity_id: [2343498, 2454336, 2454336]).pluck(:id).join(',')
  system "#{dump} activity_enrolls --where=#{enroll_activity_ids} --no-create-info >> #{db}"

  system "#{dump} activity_feedbacks --where=#{sql_activity} --no-create-info >> #{db}"

  system "#{dump} form_fields --where='site_id = 0' --no-create-info >> #{db}"
  system "#{dump} form_fields --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} activity_forms --where=#{sql_activity} --no-create-info >> #{db}"

  system "#{dump} activity_groups --where=#{sql_activity} --no-create-info >> #{db}"

  system "#{dump} activity_hits --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} activity_notices --where=#{sql_wx_mp_user} --no-create-info >> #{db}"

  system "#{dump} activity_prizes --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} activity_properties --where=#{sql_activity} --no-create-info >> #{db}"

  system "#{dump} activity_questions --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} activity_settings --where=#{sql_activity} --no-create-info >> #{db}"

  survey_activity_ids = "\'activity_id in (2270712, 2294986)\'"
  survey_question_ids = SurveyQuestion.where(activity_id: [2270712, 2294986]).pluck(:id).join(',')
  # system "#{dump} survey_questions --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} survey_questions --where=#{survey_activity_ids} --no-create-info >> #{db}"
  system "#{dump} survey_answers --where=#{sql_activity} --no-create-info >> #{db}"

  system "#{dump} activity_types --no-create-info >> #{db}"

  system "#{dump} activity_user_vote_items --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} activity_vote_items --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} activity_users --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} agents --where=#{sql_agent} --no-create-info >> #{db}"

  system "#{dump} assistants --no-create-info >> #{db}"
  system "#{dump} assistants_sites --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} cities --no-create-info >> #{db}"


  sql_custom_field1 = "customized_type='VipCard' and customized_id in (26056)"
  sql_custom_field2 = "customized_type='Activity' and customized_id in (#{activity_ids})"
  custom_field_ids1 = CustomField.where(sql_custom_field1).pluck(:id).join(',')
  custom_field_ids2 = CustomField.where(sql_custom_field2).pluck(:id).join(',')

  system "#{dump} custom_fields --where=\"#{sql_custom_field1}\" --no-create-info >> #{db}"
  system "#{dump} custom_fields --where=\"#{sql_custom_field2}\" --no-create-info >> #{db}"

  system "#{dump} custom_values --where=\'custom_field_id in (#{custom_field_ids1})\' --no-create-info >> #{db}" if custom_field_ids1.present?
  system "#{dump} custom_values --where=\'custom_field_id in (#{custom_field_ids2})\' --no-create-info >> #{db}" if custom_field_ids2.present?


  system "#{dump} districts --no-create-info >> #{db}"
  system "#{dump} fans_games --no-create-info >> #{db}"

  system "#{dump} fight_answers --where=#{sql_wx_mp_user} --no-create-info >> #{db}"
  system "#{dump} fight_paper_questions --where=#{sql_fight} --no-create-info >> #{db}"
  system "#{dump} fight_papers --where=#{sql_wx_mp_user} --no-create-info >> #{db}"
  system "#{dump} fight_report_cards --where=#{sql_wx_mp_user} --no-create-info >> #{db}"

  # system "#{dump} greet_cards --where='greet_id=3367' --no-create-info >> #{db}"
  # system "#{dump} greets --where=#{sql_wx_mp_user} --no-create-info >> #{db}"
  system "#{dump} groups --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} help_menus --no-create-info >> #{db}"
  system "#{dump} help_posts --no-create-info >> #{db}"


  material_ids = Material.where(site_id: 79750).pluck(:id).join(',')
  sql_material = "\'material_id in (#{material_ids})\'"
  system "#{dump} material_contents --where=#{sql_material} --no-create-info >> #{db}"
  system "#{dump} materials --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} message_hits --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} payment_settings --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} payment_types --no-create-info >> #{db}"
  system "#{dump} payments --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} piwik_sites --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} point_gifts --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} point_transactions --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} point_types --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} provinces --no-create-info >> #{db}"

  system "#{dump} scene_htmls --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} scenes --where=#{sql_activity} --no-create-info >> #{db}"

  sql_spread_record = "\"model_name='ActivityEnroll' and model_id in (#{activity_enroll_ids})\""
  system "#{dump} spread_records --where=#{sql_spread_record} --no-create-info >> #{db}"

  system "#{dump} site_copyrights --where='id in (1, 8182)' --no-create-info >> #{db}"
  system "#{dump} sites --where='id in (79750)' --no-create-info >> #{db}"

  sql_survey = "\'survey_question_id in (#{survey_question_ids})\'"
  system "#{dump} survey_question_choices --where=#{sql_survey} --no-create-info >> #{db}"

  # system "#{dump} greet_card_items --where='greet_card_id in (1202)' --no-create-info >> #{db}"
  
  sql_vip_card = '\'vip_card_id = 26056\''
  sql_vip_privilege = '\'vip_privilege_id = 4705\''
  system "#{dump} vip_cards --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} vip_grades --where=#{sql_vip_card} --no-create-info >> #{db}"
  system "#{dump} vip_grades_vip_privileges --where=#{sql_vip_privilege} --no-create-info >> #{db}"
  system "#{dump} vip_recharge_orders --where=#{sql_wx_mp_user} --no-create-info >> #{db}"
  system "#{dump} vip_user_payments --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} vip_user_signs --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} vip_user_transactions --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} vip_users --where=#{sql_site} --no-create-info >> #{db}"


  wbbs_topic_ids = WbbsTopic.where(site_id: 79750).pluck(:id).join(', ')
  sql_wbbs_vote = "\"votable_type='WbbsTopic' and votable_id in (#{wbbs_topic_ids})\""

  system "#{dump} wbbs_communities --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} wbbs_replies --where='wbbs_community_id = 4665' --no-create-info >> #{db}"
  system "#{dump} wbbs_topics --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} wbbs_votables --where=#{sql_wbbs_vote} --no-create-info >> #{db}"


  sql_website = '\'website_id = 35921\''
  website_menu_ids = WebsiteMenu.where(website_id: 35921).pluck(:id).join(', ')
  sql_website_menu_content = "\'website_menu_id in (#{website_menu_ids})\'"

  system "#{dump} websites --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} website_settings --where=#{sql_website} --no-create-info >> #{db}"
  system "#{dump} website_popup_menus --where=#{sql_website} --no-create-info >> #{db}"
  system "#{dump} website_pictures --where=#{sql_website} --no-create-info >> #{db}"
  system "#{dump} website_menus --where=#{sql_website} --no-create-info >> #{db}"
  system "#{dump} website_menu_contents --where=#{sql_website_menu_content} --no-create-info >> #{db}"
  system "#{dump} website_tags --no-create-info >> #{db}"
  system "#{dump} website_templates --no-create-info >> #{db}"


  system "#{dump} wx_menus --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} wx_mp_users --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} wx_participates --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} wx_prizes --where=#{sql_activity} --no-create-info >> #{db}"
  system "#{dump} replies --where=#{sql_wx_mp_user} --no-create-info >> #{db}"
  system "#{dump} wx_requests --where=#{sql_site} --no-create-info >> #{db}"

  system "#{dump} shake_prizes --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} shake_rounds --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} shake_users --where=#{sql_site} --no-create-info >> #{db}"
  system "#{dump} shakes --where=#{sql_site} --no-create-info >> #{db}"

  # wx_user_addresses
  system "#{dump} wx_users --where=#{sql_site} --no-create-info >> #{db}"

  puts "*************** done mysqldump"
end

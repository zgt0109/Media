# encoding: UTF-8

class InitDb < ActiveRecord::Migration

  create_table "accounts", options: 'AUTO_INCREMENT = 10001' do |t|
    t.integer  "account_type",                 :default => 0,   :null => false
    t.integer  "account_category_id"
    t.string   "nickname"
    t.string   "company_name"
    t.string   "contact"
    t.string   "mobile"
    t.string   "tel"
    t.string   "email"
    t.string   "qq"
    t.integer  "status",                 :default => 0,   :null => false
    t.string   "token"
    t.datetime "start_at"
    t.datetime "expired_at"
    t.boolean  "is_open_sms",            :default => false, :null => false
    t.integer  "pay_sms_count",          :default => 0,   :null => false
    t.integer  "free_sms_count",         :default => 0,   :null => false
    t.integer  "province_id",            :default => 9,   :null => false
    t.integer  "city_id",                :default => 73,  :null => false
    t.integer  "district_id",            :default => 702, :null => false
    t.string   "address"
    t.integer  "sign_in_count",          :default => 0,   :null => false
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip"
    t.string   "password_digest"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.text     "metadata"
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "accounts", ["nickname"], :name => "index_accounts_on_nickname", :unique => true

  def change
    create_table "account_categories" do |t|
      t.integer  "parent_id",               :default => 0, :null => false
      t.string   "name",                                   :null => false
      t.integer  "sort",                    :default => 0, :null => false
      t.integer  "status",     :limit => 1, :default => 1, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  create_table "account_passwords" do |t|
    t.integer  "account_id",                                         :null => false
    t.string   "email"
    t.integer  "password_type",                     :default => 1,   :null => false
    t.string   "password_digest",                   :default => "1", :null => false
    t.integer  "password_question_id",              :default => 1,   :null => false
    t.string   "password_answer"
    t.integer  "err_num",              :limit => 1, :default => 0
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "account_passwords", ["account_id"], :name => "index_account_passwords_on_account_id"
  add_index "account_passwords", ["email"], :name => "index_account_passwords_on_email"
  add_index "account_passwords", ["password_question_id"], :name => "index_account_passwords_on_password_question_id"

  create_table "account_footers" do |t|
    t.integer  "account_id", default: 0,            :null => false
    t.boolean  "is_default",     :default => false, :null => false
    t.boolean  "is_show_link",   :default => false, :null => false
    t.string   "footer_content",                    :null => false
    t.string   "footer_link"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "account_logs" do |t|
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "ip"
    t.string   "referer"
    t.string   "user_agent"
    t.datetime "created_at"
  end

  add_index "account_logs", ["user_id", "user_type"], :name => "index_account_logs_on_user_id_and_user_type"

  create_table "sites", options: 'AUTO_INCREMENT = 10001' do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "token"
    t.integer  "status",                           :default => 1, :null => false
    t.text     "privileges"
    t.integer  "piwik_site_id"
    t.integer  "piwik_domain_status", :limit => 1, :default => 0, :null => false
    t.text     "metadata"
    t.text     "description"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  create_table "activities", options: 'AUTO_INCREMENT = 10001' do |t|
    t.integer  "site_id",                                              :null => false
    t.integer  "activity_type_id",                                     :null => false
    t.string   "page_title"
    t.string   "name",                                                 :null => false
    t.string   "summary"
    t.string   "keyword",                                              :null => false
    t.datetime "ready_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "activityable_id"
    t.string   "activityable_type"
    t.string   "extend",            :limit => 1024
    t.string   "pic_key"
    t.string   "bg_pic_key"
    t.string   "logo_key"
    t.integer  "status",            :limit => 1,    :default => 0,     :null => false
    t.integer  "pv_count",            :limit => 1,    :default => 0,     :null => false
    t.boolean  "require_wx_user",                   :default => false
    t.boolean  "audited",                           :default => false, :null => false
    t.boolean  "show_contact",                      :default => false
    t.integer  "vote_item_type",                    :default => 1,     :null => false
    t.integer  "deal_status",                       :default => 0,     :null => false
    t.text     "description"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "activities", ["activity_type_id"], :name => "index_activities_on_activity_type_id"
  add_index "activities", ["activityable_id", "activityable_type"], :name => "index_activities_on_activityable_id_and_activityable_type"
  add_index "activities", ["keyword"], :name => "index_activities_on_keyword"
  add_index "activities", ["site_id"], :name => "index_activities_on_site_id"

  create_table "activities_business_shops", :id => false do |t|
    t.integer  "activity_id"
    t.integer  "business_shop_id"
    t.datetime "created_at",       :null => false
  end

  add_index "activities_business_shops", ["activity_id"], :name => "index_activities_business_shops_on_activity_id"
  add_index "activities_business_shops", ["business_shop_id"], :name => "index_activities_business_shops_on_business_shop_id"

  create_table "activities_fans_games" do |t|
    t.integer  "activity_id",                 :null => false
    t.integer  "fans_game_id",                :null => false
    t.integer  "game_status",  :default => 1, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "activities_fans_games", ["activity_id"], :name => "index_activities_fans_games_on_activity_id"
  add_index "activities_fans_games", ["fans_game_id"], :name => "index_activities_fans_games_on_fans_game_id"

  create_table "activity_consumes" do |t|
    t.integer  "site_id",                          :null => false
    t.integer  "activity_id",                      :null => false
    t.integer  "user_id",                          :null => false
    t.integer  "vip_privilege_id"
    t.integer  "activity_prize_id"
    t.integer  "shop_branch_id"
    t.integer  "applicable_id"
    t.string   "applicable_type"
    t.integer  "activity_group_id"
    t.string   "code",                             :null => false
    t.string   "name"
    t.string   "mobile"
    t.integer  "status",            :default => 1, :null => false
    t.datetime "use_at"
    t.datetime "expire_at"
    t.text     "description"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "activity_consumes", ["activity_group_id"], :name => "index_activity_consumes_on_activity_group_id"
  add_index "activity_consumes", ["activity_id"], :name => "index_activity_consumes_on_activity_id"
  add_index "activity_consumes", ["activity_prize_id"], :name => "index_activity_consumes_on_activity_prize_id"
  add_index "activity_consumes", ["applicable_id"], :name => "index_activity_consumes_on_applicable_id"
  add_index "activity_consumes", ["shop_branch_id"], :name => "index_activity_consumes_on_shop_branch_id"
  add_index "activity_consumes", ["site_id"], :name => "index_activity_consumes_on_site_id"
  add_index "activity_consumes", ["status"], :name => "index_activity_consumes_on_status"
  add_index "activity_consumes", ["user_id"], :name => "index_activity_consumes_on_user_id"
  add_index "activity_consumes", ["vip_privilege_id"], :name => "index_activity_consumes_on_vip_privilege_id"

  create_table "activity_enrolls" do |t|
    t.integer  "activity_id",                    :null => false
    t.integer  "user_id",                        :null => false
    t.string   "username"
    t.string   "mobile"
    t.string   "email"
    t.string   "qq"
    t.string   "company_tel"
    t.string   "home_tel"
    t.string   "province_name"
    t.string   "city_name"
    t.string   "company_address"
    t.string   "company_name"
    t.string   "contact"
    t.string   "home_address"
    t.string   "gender"
    t.integer  "age"
    t.string   "job"
    t.datetime "booking_at"
    t.string   "remark"
    t.integer  "status",          :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "activity_enrolls", ["activity_id"], :name => "index_activity_enrolls_on_activity_id"
  add_index "activity_enrolls", ["user_id"], :name => "index_activity_enrolls_on_user_id"

  create_table "activity_feedbacks" do |t|
    t.integer  "activity_id",                     :null => false
    t.integer  "activity_user_id",                :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "feedback_type",    :default => 1, :null => false
    t.integer  "status",           :default => 1, :null => false
    t.text     "content"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "activity_feedbacks", ["activity_id"], :name => "index_activity_feedbacks_on_activity_id"
  add_index "activity_feedbacks", ["activity_user_id"], :name => "index_activity_feedbacks_on_activity_user_id"
  add_index "activity_feedbacks", ["feedback_type"], :name => "index_activity_feedbacks_on_feedback_type"
  add_index "activity_feedbacks", ["user_id"], :name => "index_activity_feedbacks_on_user_id"

  create_table "form_fields" do |t|
    t.integer  "account_id",                    :default => 0, :null => false
    t.string   "name",                                      :null => false
    t.string   "value",                                     :null => false
    t.integer  "sort",                       :default => 1, :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "field_type",    :limit => 1, :default => 1, :null => false
    t.string   "regular"
    t.string   "regular_alert"
  end

  add_index "form_fields", ["name", "account_id"], :name => "index_form_fields_on_name", :unique => true

  create_table "activity_forms" do |t|
    t.integer  "activity_id",                               :null => false
    t.integer  "form_field_id",                    :null => false
    t.string   "field_name"
    t.string   "field_value"
    t.integer  "sort",                   :default => 1,     :null => false
    t.integer  "status",                 :default => 1,     :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "required",               :default => false, :null => false
  end

  add_index "activity_forms", ["form_field_id"], :name => "index_activity_forms_on_form_field_id"
  add_index "activity_forms", ["activity_id"], :name => "index_activity_forms_on_activity_id"

  create_table "activity_groups" do |t|
    t.integer  "activity_id",                :null => false
    t.integer  "user_id",                    :null => false
    t.string   "name",                       :null => false
    t.string   "mobile",                     :null => false
    t.integer  "item_qty",    :default => 1, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "activity_groups", ["activity_id"], :name => "index_activity_groups_on_activity_id"
  add_index "activity_groups", ["item_qty"], :name => "index_activity_groups_on_item_qty"
  add_index "activity_groups", ["user_id"], :name => "index_activity_groups_on_user_id"

  create_table "activity_notices" do |t|
    t.integer  "activity_id",                                 :null => false
    t.string   "title"
    t.string   "pic_key"
    t.string   "summary"
    t.text     "description"
    t.integer  "activity_status", :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "activity_notices", ["activity_id"], :name => "index_activity_notices_on_activity_id"
  add_index "activity_notices", ["activity_status"], :name => "index_activity_notices_on_activity_status"

  create_table "activity_prize_elements" do |t|
    t.integer  "activity_id", :null => false
    t.string   "name"
    t.string   "pic_key"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "activity_prize_elements", ["activity_id"], :name => "index_activity_prize_elements_on_activity_id"

  create_table "activity_prizes" do |t|
    t.integer  "activity_id",                                                                                    :null => false
    t.integer  "status",                 :limit => 1,                                :default => 0,              :null => false
    t.string   "title",                                                                                          :null => false
    t.string   "prize_type",                                                         :default => "normal_prize"
    t.integer  "points"
    t.string   "prize"
    t.decimal  "prize_value",                         :precision => 10, :scale => 2
    t.integer  "prize_count",                                                        :default => 0
    t.decimal  "prize_rate",                          :precision => 10, :scale => 6, :default => 0.0,            :null => false
    t.integer  "time_limit",                                                         :default => 0,              :null => false
    t.integer  "limit_count",                                                        :default => -1,             :null => false
    t.integer  "day_limit_count",                                                    :default => -1,             :null => false
    t.integer  "people_limit_count",                                                 :default => -1,             :null => false
    t.integer  "people_day_limit_count",                                             :default => -1,             :null => false
    t.string   "activity_element_ids"
    t.integer  "recommends_count",                                                   :default => 10
    t.datetime "created_at",                                                                                     :null => false
    t.datetime "updated_at",                                                                                     :null => false
  end

  add_index "activity_prizes", ["activity_id"], :name => "index_activity_prizes_on_activity_id"

  create_table "activity_properties" do |t|
    t.integer  "activity_id",                                                                           :null => false
    t.integer  "activity_type_id",                                                                      :null => false
    t.string   "prize_pic"
    t.string   "pic_key"
    t.integer  "partake_limit",                                          :default => -1,                :null => false
    t.integer  "day_partake_limit",                                      :default => -1,                :null => false
    t.integer  "prize_limit",                                            :default => -1,                :null => false
    t.integer  "day_prize_limit",                                        :default => -1,                :null => false
    t.boolean  "is_show_prize_qty",                                      :default => true
    t.boolean  "enable_prepare_settings",                                :default => false
    t.string   "item_name"
    t.text     "special_warn"
    t.integer  "min_people_num",                                         :default => 0,                 :null => false
    t.decimal  "coupon_price",            :precision => 12, :scale => 2, :default => 0.0,               :null => false
    t.decimal  "item_price",              :precision => 12, :scale => 2, :default => 0.0,               :null => false
    t.integer  "coupon_count",                                           :default => 0,                 :null => false
    t.integer  "get_limit_count",                                        :default => 0,                 :null => false
    t.integer  "question_score",                                         :default => 10
    t.string   "meta"
    t.string   "repeat_draw_msg",                                        :default => "亲，抢券活动每人只能抽一次哦。"
    t.boolean  "vip_only",                                               :default => false
    t.string   "win_tip"
    t.text     "prize_description"
    t.text     "subscribe_description"
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
  end

  add_index "activity_properties", ["activity_id"], :name => "index_activity_properties_on_activity_id"
  add_index "activity_properties", ["activity_type_id"], :name => "index_activity_properties_on_activity_type_id"

  create_table "activity_questions" do |t|
    t.integer  "activity_type_id",              :default => 8
    t.integer  "site_id",                                      :null => false
    t.string   "title",                                        :null => false
    t.string   "pic_key"
    t.string   "answer_a",                                     :null => false
    t.string   "answer_b",                                     :null => false
    t.string   "answer_c"
    t.string   "answer_d"
    t.string   "answer_e"
    t.string   "correct_answer",                               :null => false
    t.integer  "status",           :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "activity_questions", ["site_id"], :name => "index_fight_questions_on_site_id"
  add_index "activity_questions", ["status"], :name => "index_fight_questions_on_status"

  create_table "activity_settings" do |t|
    t.integer  "activity_id"
    t.integer  "user_type",              :default => 1
    t.integer  "vote_result_sort_way",   :default => 2
    t.string   "vote_theme"
    t.integer  "associated_activity_id"
    t.boolean  "is_associated_activity", :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "activity_settings", ["activity_id"], :name => "index_activity_settings_on_activity_id"
  add_index "activity_settings", ["user_type"], :name => "index_activity_settings_on_user_type"

  create_table "activity_types" do |t|
    t.integer  "group_id"
    t.string   "name",                                    :null => false
    t.integer  "sort",                     :default => 0, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "activity_user_vote_items" do |t|
    t.integer  "activity_id"
    t.integer  "activity_user_id"
    t.integer  "activity_vote_item_id"
    t.integer  "user_id"
    t.string   "name",                  :null => false
    t.string   "mobile"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "activity_user_vote_items", ["activity_id"], :name => "index_activity_user_vote_items_on_activity_id"
  add_index "activity_user_vote_items", ["activity_vote_item_id"], :name => "index_activity_user_vote_items_on_activity_vote_item_id"
  add_index "activity_user_vote_items", ["user_id"], :name => "index_activity_user_vote_items_on_user_id"

  create_table "activity_users" do |t|
    t.integer  "site_id",                                   :null => false
    t.integer  "activity_id",                               :null => false
    t.integer  "user_id",                                   :null => false
    t.string   "name"
    t.string   "mobile"
    t.string   "email"
    t.string   "address"
    t.integer  "status",        :limit => 1, :default => 0, :null => false
    t.text     "vote_item_ids"
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "activity_users", ["site_id"], :name => "index_activity_users_on_site_id"
  add_index "activity_users", ["activity_id"], :name => "index_activity_users_on_activity_id"
  add_index "activity_users", ["user_id"], :name => "index_activity_users_on_user_id"

  create_table "activity_vote_items" do |t|
    t.integer  "activity_id"
    t.string   "name"
    t.integer  "activity_user_vote_items_count", :default => 0
    t.string   "item_no"
    t.string   "pic_key"
    t.integer  "adjust_votes",                   :default => 0
    t.string   "link"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "activity_vote_items", ["activity_id"], :name => "index_activity_vote_items_on_activity_id"

  create_table "admin_users", options: 'AUTO_INCREMENT = 10001' do |t|
    t.string   "code",                                                 :null => false
    t.string   "name",                                                 :null => false
    t.string   "token"
    t.string   "password_digest",                                      :null => false
    t.integer  "sign_in_count",                     :default => 0,     :null => false
    t.boolean  "is_password_modified",              :default => false
    t.datetime "password_modified_at"
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip"
    t.integer  "status",               :limit => 1, :default => 1,     :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "admin_users", ["code"], :name => "index_admin_users_on_code", :unique => true

  create_table "admin_users_roles" do |t|
    t.integer  "admin_user_id", :null => false
    t.integer  "role_id",       :null => false
    t.datetime "created_at",    :null => false
  end

  add_index "admin_users_roles", ["admin_user_id"], :name => "index_admin_users_roles_on_admin_user_id"
  add_index "admin_users_roles", ["role_id"], :name => "index_admin_users_roles_on_role_id"

  create_table "aid_results" do |t|
    t.integer  "user_id",          :null => false
    t.integer  "activity_user_id", :null => false
    t.integer  "points"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "album_photos" do |t|
    t.integer  "album_id"
    t.string   "name"
    t.string   "pic_key"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "album_photos", ["album_id"], :name => "index_album_photos_on_album_id"

  create_table "albums" do |t|
    t.integer  "site_id"
    t.integer  "activity_id"
    t.string   "name"
    t.integer  "photos_count",              :default => 0
    t.integer  "status",                    :default => 1
    t.text     "description"
    t.boolean  "visible",                   :default => true
    t.integer  "sort",                      :default => 0
    t.integer  "cover_id"
    t.integer  "browsing_way", :limit => 1, :default => 1,    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "albums", ["activity_id"], :name => "index_albums_on_activity_id"
  add_index "albums", ["site_id"], :name => "index_albums_on_site_id"

  create_table "assistants" do |t|
    t.string   "name",                                       :null => false
    t.string   "summary"
    t.integer  "assistant_type",              :default => 1, :null => false
    t.string   "code"
    t.string   "keyword"
    t.string   "url"
    t.string   "pic_key"
    t.string   "font_icon"
    t.integer  "sort",           :limit => 1, :default => 1, :null => false
    t.integer  "status",         :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "assistants", ["name"], :name => "index_assistants_on_name"

  create_table "assistants_sites" do |t|
    t.integer  "assistant_id"
    t.integer  "site_id"
    t.datetime "created_at",   :null => false
  end

  add_index "assistants_sites", ["assistant_id"], :name => "index_assistants_sites_on_assistant_id"
  add_index "assistants_sites", ["site_id"], :name => "index_assistants_sites_on_site_id"

  create_table "book_rules" do |t|
    t.integer  "shop_branch_id"
    t.string   "book_phone"
    t.integer  "preview_day",                                     :default => -1
    t.boolean  "is_send_captcha"
    t.text     "description"
    t.integer  "min_money",                                       :default => -1
    t.boolean  "is_in_branch",                                    :default => false
    t.boolean  "is_in_queue",                                     :default => false
    t.boolean  "is_in_normal",                                    :default => true
    t.boolean  "is_pay_online",                                   :default => false
    t.boolean  "is_pay_cash",                                     :default => true
    t.integer  "cancel_rule",                                     :default => -1
    t.integer  "created_minute",                                  :default => -1
    t.integer  "booked_minute",                                   :default => -1
    t.boolean  "is_open_hall",                                    :default => true
    t.boolean  "is_open_loge",                                    :default => true
    t.string   "type"
    t.integer  "rule_type"
    t.boolean  "is_limit_time",                                   :default => false
    t.boolean  "is_limit_money",                                  :default => false
    t.boolean  "is_limit_day",                                    :default => false
    t.decimal  "hall_limit_money", :precision => 12, :scale => 2
    t.decimal  "loge_limit_money", :precision => 12, :scale => 2
    t.boolean  "is_pay_balance",                                  :default => false
    t.text     "metadata"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  add_index "book_rules", ["shop_branch_id"], :name => "index_book_rules_on_shop_branch_id"

  create_table "book_time_ranges" do |t|
    t.integer  "book_rule_id"
    t.string   "start_time"
    t.string   "end_time"
    t.integer  "status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "book_time_ranges", ["book_rule_id"], :name => "index_book_time_ranges_on_book_rule_id"

  create_table "booking_ads" do |t|
    t.integer  "booking_id"
    t.string   "title"
    t.string   "pic_key"
    t.string   "url"
    t.integer  "sort",       :limit => 1, :default => 1
    t.integer  "status",     :limit => 1, :default => 1
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "booking_ads", :booking_id

  create_table "booking_categories" do |t|
    t.integer  "booking_id",                                 :null => false
    t.integer  "parent_id"
    t.string   "name",                                    :null => false
    t.integer  "sort",                     :default => 1, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "booking_categories", :name
  add_index "booking_categories", :parent_id
  add_index "booking_categories", :booking_id

  create_table "booking_comments" do |t|
    t.integer  "booking_item_id"
    t.integer  "user_id"
    t.text     "content"
    t.integer  "status",          :limit => 1, :default => 1
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "booking_comments", ["booking_item_id"], :name => "index_booking_comments_on_booking_item_id"
  add_index "booking_comments", ["user_id"], :name => "index_booking_comments_on_user_id"

  create_table "booking_item_pictures" do |t|
    t.integer  "booking_item_id",                :null => false
    t.string   "pic_key"
    t.integer  "sort",            :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "booking_item_pictures", ["booking_item_id"], :name => "index_booking_item_pictures_on_booking_item_id"

  create_table "booking_items" do |t|
    t.integer  "booking_id"
    t.integer  "booking_category_id"
    t.string   "name"
    t.decimal  "price",                            :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "qty",                                                             :default => 0,   :null => false
    t.string   "pic_key"
    t.integer  "limit_type",          :limit => 1,                                :default => 1,   :null => false
    t.integer  "limit_qty",                                                       :default => 0,   :null => false
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "status",              :limit => 1,                                :default => 1,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
  end

  add_index "booking_items", :booking_category_id
  add_index "booking_items", :name
  add_index "booking_items", :qty
  add_index "booking_items", :booking_id

  create_table "booking_orders" do |t|
    t.integer  "booking_id"
    t.integer  "user_id"
    t.integer  "booking_item_id"
    t.string   "order_no"
    t.integer  "qty",                                                         :default => 0,   :null => false
    t.decimal  "price",                        :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_amount",                 :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.string   "username"
    t.string   "tel"
    t.datetime "booking_at"
    t.datetime "completed_at"
    t.datetime "canceled_at"
    t.text     "description"
    t.string   "address"
    t.integer  "status",          :limit => 1,                                :default => 1
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
  end

  add_index "booking_orders", :booking_item_id
  add_index "booking_orders", :order_no
  add_index "booking_orders", :booking_id
  add_index "booking_orders", :user_id

  create_table "bookings" do |t|
    t.integer  "site_id",                                 :null => false
    t.string   "name"
    t.string   "tel"
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "metadata"
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "bookings", :name
  add_index "bookings", :site_id

  create_table "broche_photos" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "broche_id",                  :null => false
    t.string   "title"
    t.string   "pic_key"
    t.integer  "sort",        :default => 0
    t.text     "description"
    t.integer  "status",      :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "broche_photos", ["broche_id"], :name => "index_broche_photos_on_broche_id"
  add_index "broche_photos", ["site_id"], :name => "index_broche_photos_on_site_id"

  create_table "broches" do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "description"
    t.integer  "status",      :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "broches", ["site_id"], :name => "index_broches_on_site_id"

  create_table "brokerage_brokers" do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "mobile"
    t.integer  "settlement_type",      :limit => 1,                                :default => 1
    t.string   "bank_account_name"
    t.string   "bank_card_no"
    t.string   "bank_name"
    t.string   "alipay_account_name"
    t.string   "alipay_receiver"
    t.integer  "clients_count",                                                    :default => 0
    t.decimal  "settled_commission",                :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "unsettled_commission",              :precision => 12, :scale => 2, :default => 0.0
    t.integer  "status",               :limit => 1,                                :default => 1
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
  end

  add_index "brokerage_brokers", ["site_id"], :name => "index_brokerage_brokers_on_site_id"
  add_index "brokerage_brokers", ["user_id"], :name => "index_brokerage_brokers_on_user_id"

  create_table "brokerage_client_changes" do |t|
    t.integer  "client_id"
    t.integer  "commission_type_id"
    t.integer  "old_commission_type_id"
    t.decimal  "commission",                :precision => 12, :scale => 2, :default => 0.0
    t.integer  "commission_transaction_id"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  add_index "brokerage_client_changes", ["client_id"], :name => "index_brokerage_client_changes_on_client_id"
  add_index "brokerage_client_changes", ["commission_transaction_id"], :name => "index_brokerage_client_changes_on_commission_transaction_id"
  add_index "brokerage_client_changes", ["commission_type_id"], :name => "index_brokerage_client_changes_on_commission_type_id"

  create_table "brokerage_clients" do |t|
    t.integer  "broker_id"
    t.integer  "commission_type_id"
    t.string   "name"
    t.string   "mobile"
    t.text     "remarks"
    t.decimal  "total_commission",                :precision => 12, :scale => 2, :default => 0.0
    t.integer  "status",             :limit => 1,                                :default => 1
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
  end

  add_index "brokerage_clients", ["broker_id"], :name => "index_brokerage_clients_on_broker_id"
  add_index "brokerage_clients", ["commission_type_id"], :name => "index_brokerage_clients_on_commission_type_id"

  create_table "brokerage_commission_transactions" do |t|
    t.integer  "broker_id"
    t.decimal  "commission",         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "settled_commission", :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  add_index "brokerage_commission_transactions", ["broker_id"], :name => "index_brokerage_commission_transactions_on_broker_id"

  create_table "brokerage_commission_types" do |t|
    t.integer  "activity_id"
    t.integer  "mission_type",     :limit => 1
    t.integer  "commission_type",  :limit => 1
    t.decimal  "commission_value",              :precision => 12, :scale => 2, :default => 0.0
    t.integer  "status",           :limit => 1,                                :default => 1
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  add_index "brokerage_commission_types", ["activity_id"], :name => "index_brokerage_commission_types_on_activity_id"

  create_table "brokerage_settings" do |t|
    t.string   "logo_key"
    t.string   "pic_keys"
    t.text     "agreement"
    t.string   "tel"
    t.integer  "month_settlement_day"
    t.float    "min_settlement_amount"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "business_items" do |t|
    t.integer  "business_shop_id",                                                 :null => false
    t.string   "name",                                                             :null => false
    t.decimal  "price",            :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "sort",                                            :default => 1,   :null => false
    t.string   "pic_key"
    t.text     "description"
    t.integer  "status",                                          :default => 1,   :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "business_items", ["business_shop_id"], :name => "index_business_items_on_business_shop_id"

  create_table "business_privileges" do |t|
    t.integer  "business_shop_id",                :null => false
    t.string   "name",                            :null => false
    t.text     "description",                     :null => false
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "status",           :default => 1, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "business_privileges", ["business_shop_id"], :name => "index_business_privileges_on_business_shop_id"

  create_table "business_shop_admins" do |t|
    t.integer  "business_shop_id"
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "role",             :default => "admin"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "business_shop_admins", ["business_shop_id"], :name => "index_business_shop_admins_on_business_shop_id"
  add_index "business_shop_admins", ["email"], :name => "index_business_shop_admins_on_email"
  add_index "business_shop_admins", ["username"], :name => "index_business_shop_admins_on_username"

  create_table "business_shop_impressions" do |t|
    t.integer  "business_shop_id",                :null => false
    t.integer  "comment_id"
    t.integer  "total_star"
    t.integer  "service_star"
    t.integer  "env_star"
    t.integer  "costs_star"
    t.float    "avg_price"
    t.integer  "status",           :default => 1
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "business_shop_impressions", ["business_shop_id"], :name => "index_business_shop_impressions_on_business_shop_id"
  add_index "business_shop_impressions", ["comment_id"], :name => "index_business_shop_impressions_on_comment_id"

  create_table "business_shop_pictures" do |t|
    t.string   "pic_key"
    t.integer  "business_shop_id"
    t.integer  "sort"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "business_shop_pictures", ["business_shop_id"], :name => "index_business_shop_pictures_on_business_shop_id"

  create_table "business_shops" do |t|
    t.integer  "website_id",                                       :null => false
    t.integer  "template_id"
    t.string   "name",                                             :null => false
    t.string   "subtitle"
    t.string   "logo_key",                                         :null => false
    t.integer  "sort",                          :default => 1,     :null => false
    t.boolean  "open_function",                 :default => false
    t.text     "description",                                      :null => false
    t.string   "tel"
    t.string   "address",                                          :null => false
    t.integer  "location_status",               :default => 1,     :null => false
    t.string   "location_address"
    t.float    "location_x"
    t.float    "location_y"
    t.string   "location_pic_key"
    t.integer  "status",           :limit => 1, :default => 1,     :null => false
    t.boolean  "enable_vip_card",               :default => false, :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "business_shops", ["website_id"], :name => "index_business_shops_on_website_id"

  create_table "car_activity_notices" do |t|
    t.integer  "car_shop_id"
    t.integer  "notice_type", :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "car_activity_notices", ["car_shop_id"], :name => "index_car_activity_notices_on_car_shop_id"
  add_index "car_activity_notices", ["notice_type"], :name => "index_car_activity_notices_on_notice_type"

  create_table "car_articles" do |t|
    t.integer  "car_shop_id"
    t.string   "title",                                    :null => false
    t.text     "content",                                  :null => false
    t.integer  "status",       :limit => 1, :default => 1, :null => false
    t.integer  "article_type", :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "car_articles", ["article_type"], :name => "index_car_articles_on_article_type"
  add_index "car_articles", ["car_shop_id"], :name => "index_car_articles_on_car_shop_id"
  add_index "car_articles", ["status"], :name => "index_car_articles_on_status"

  create_table "car_bespeak_option_relationships" do |t|
    t.integer  "car_bespeak_id",        :null => false
    t.integer  "car_bespeak_option_id", :null => false
    t.datetime "created_at",            :null => false
  end

  add_index "car_bespeak_option_relationships", ["car_bespeak_id"], :name => "index_car_bespeak_option_relationships_on_car_bespeak_id"
  add_index "car_bespeak_option_relationships", ["car_bespeak_option_id"], :name => "index_car_bespeak_option_relationships_on_car_bespeak_option_id"

  create_table "car_bespeak_options" do |t|
    t.string   "name",                                     :null => false
    t.integer  "sort",                      :default => 0, :null => false
    t.integer  "bespeak_type", :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "car_bespeak_options", ["bespeak_type"], :name => "index_car_bespeak_options_on_bespeak_type"

  create_table "car_bespeaks" do |t|
    t.integer  "car_shop_id"
    t.integer  "car_brand_id",                               :null => false
    t.integer  "car_catena_id"
    t.integer  "car_type_id"
    t.integer  "user_id",                                    :null => false
    t.integer  "bespeak_type",  :limit => 1, :default => 1,  :null => false
    t.date     "bespeak_date",                               :null => false
    t.string   "plate_number"
    t.string   "name",                                       :null => false
    t.string   "mobile",                                     :null => false
    t.string   "description",                :default => ""
    t.integer  "order_date",                 :default => 1,  :null => false
    t.integer  "order_budget",               :default => 1,  :null => false
    t.integer  "status",        :limit => 1, :default => 1,  :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "car_bespeaks", ["bespeak_type"], :name => "index_car_bespeaks_on_bespeak_type"
  add_index "car_bespeaks", ["car_brand_id"], :name => "index_car_bespeaks_on_car_brand_id"
  add_index "car_bespeaks", ["car_catena_id"], :name => "index_car_bespeaks_on_car_catena_id"
  add_index "car_bespeaks", ["car_shop_id"], :name => "index_car_bespeaks_on_car_shop_id"
  add_index "car_bespeaks", ["order_budget"], :name => "index_car_bespeaks_on_order_budget"
  add_index "car_bespeaks", ["order_date"], :name => "index_car_bespeaks_on_order_date"
  add_index "car_bespeaks", ["user_id"], :name => "index_car_bespeaks_on_user_id"

  create_table "car_brands" do |t|
    t.integer  "car_shop_id"
    t.string   "name",                                    :null => false
    t.integer  "sort",                     :default => 0, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "logo"
    t.string   "logo_key"
  end

  add_index "car_brands", ["car_shop_id"], :name => "index_car_brands_on_car_shop_id"

  create_table "car_catenas" do |t|
    t.integer  "car_shop_id"
    t.integer  "car_brand_id"
    t.string   "name",                                     :null => false
    t.integer  "sort",                      :default => 0, :null => false
    t.integer  "status",       :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "short_name"
    t.string   "pic_key"
  end

  add_index "car_catenas", ["car_brand_id"], :name => "index_car_catenas_on_car_brand_id"
  add_index "car_catenas", ["car_shop_id"], :name => "index_car_catenas_on_car_shop_id"

  create_table "car_owners" do |t|
    t.integer  "user_id"
    t.integer  "car_shop_id"
    t.integer  "car_catena_id"
    t.integer  "car_type_id"
    t.string   "car_full_name"
    t.string   "car_license_no",                                         :null => false
    t.string   "car_owner",                                              :null => false
    t.datetime "car_license_time",                                       :null => false
    t.string   "pic_key"
    t.datetime "last_insurance_time",                                    :null => false
    t.decimal  "last_insurance_charge",   :precision => 12, :scale => 2, :null => false
    t.float    "last_maintenance_mile",                                  :null => false
    t.datetime "last_maintenance_time",                                  :null => false
    t.decimal  "last_maintenance_charge", :precision => 12, :scale => 2, :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "car_owners", ["car_catena_id"], :name => "index_car_owners_on_car_catena_id"
  add_index "car_owners", ["car_shop_id"], :name => "index_car_owners_on_car_shop_id"
  add_index "car_owners", ["car_type_id"], :name => "index_car_owners_on_car_type_id"
  add_index "car_owners", ["user_id"], :name => "index_car_owners_on_user_id"

  create_table "car_pictures" do |t|
    t.integer  "car_shop_id"
    t.integer  "car_catena_id"
    t.integer  "car_type_id"
    t.string   "name"
    t.string   "qiniu_path_key"
    t.boolean  "is_cover",       :default => false, :null => false
    t.integer  "sort",           :default => 1
    t.integer  "pic_type",       :default => 1
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "car_pictures", ["car_catena_id"], :name => "index_car_pictures_on_car_type_id"
  add_index "car_pictures", ["car_shop_id"], :name => "index_car_pictures_on_car_shop_id"
  add_index "car_pictures", ["is_cover"], :name => "index_car_pictures_on_is_cover"

  create_table "car_sellers" do |t|
    t.integer  "car_shop_id"
    t.integer  "seller_type",      :limit => 1, :default => 1, :null => false
    t.string   "name",                                         :null => false
    t.string   "phone",                                        :null => false
    t.string   "position",                                     :null => false
    t.string   "skilled_language",                             :null => false
    t.string   "pic_key"
    t.integer  "status",           :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "car_sellers", ["car_shop_id"], :name => "index_car_sellers_on_car_shop_id"
  add_index "car_sellers", ["seller_type"], :name => "index_car_sellers_on_seller_type"

  create_table "car_shops" do |t|
    t.integer  "site_id",                        :null => false
    t.string   "name",                           :null => false
    t.string   "tel"
    t.string   "tel_extension"
    t.integer  "province_id",   :default => 9
    t.integer  "city_id",       :default => 73
    t.integer  "district_id",   :default => 702
    t.string   "address"
    t.text     "intro"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "car_shops", ["city_id"], :name => "index_car_shops_on_city_id"
  add_index "car_shops", ["district_id"], :name => "index_car_shops_on_district_id"
  add_index "car_shops", ["province_id"], :name => "index_car_shops_on_province_id"
  add_index "car_shops", ["site_id"], :name => "index_car_shops_on_site_id"

  create_table "car_types" do |t|
    t.integer  "car_shop_id"
    t.integer  "car_brand_id"
    t.integer  "car_catena_id"
    t.string   "name"
    t.string   "level"
    t.string   "engine_isplacement"
    t.string   "engine_horsepower"
    t.string   "gear_box"
    t.string   "car_model"
    t.string   "drive"
    t.decimal  "price",                           :precision => 12, :scale => 2
    t.string   "warranty"
    t.string   "oil"
    t.string   "speed"
    t.string   "accelerate"
    t.string   "structure"
    t.string   "car_size"
    t.string   "engine"
    t.integer  "status",             :limit => 1,                                :default => 1
    t.integer  "gear_num"
    t.string   "output_volumne"
    t.decimal  "dealer_price",                    :precision => 12, :scale => 2
    t.integer  "sort"
    t.integer  "year"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  add_index "car_types", ["car_brand_id"], :name => "index_car_types_on_car_brand_id"
  add_index "car_types", ["car_catena_id"], :name => "index_car_types_on_car_catena_id"
  add_index "car_types", ["car_shop_id"], :name => "index_car_types_on_car_shop_id"
  add_index "car_types", ["level"], :name => "index_car_types_on_level"

  create_table "qrcode_channels" do |t|
    t.integer  "site_id",                                       :null => false
    t.integer  "qrcode_channel_type_id",                               :null => false
    t.integer  "qrcode_id",                                     :null => false
    t.string   "name",                                          :null => false
    t.integer  "channel_way",     :limit => 1, :default => 1
    t.string   "way_content"
    t.integer  "province_id",                  :default => 9,   :null => false
    t.integer  "city_id",                      :default => 73,  :null => false
    t.integer  "district_id",                  :default => 702, :null => false
    t.string   "pic_key"
    t.string   "description"
    t.integer  "scene_id",                     :default => 1,   :null => false
    t.integer  "status",                       :default => 1
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "qrcode_channels", ["qrcode_channel_type_id"], :name => "index_qrcode_channels_on_qrcode_channel_type_id"
  add_index "qrcode_channels", ["qrcode_id"], :name => "index_qrcode_channels_on_qrcode_id"
  add_index "qrcode_channels", ["scene_id"], :name => "index_qrcode_channels_on_scene_id"
  add_index "qrcode_channels", ["site_id"], :name => "index_qrcode_channels_on_site_id"

  create_table "qrcode_channel_types" do |t|
    t.integer  "site_id",                    :null => false
    t.string   "name",                       :null => false
    t.string   "description"
    t.integer  "status",      :default => 1, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "qrcode_channel_types", ["site_id"], :name => "index_qrcode_channel_types_on_site_id"

  create_table "cities" do |t|
    t.string   "name",                       :null => false
    t.string   "pinyin"
    t.integer  "province_id", :default => 9, :null => false
    t.integer  "sort",        :default => 0, :null => false
    t.datetime "created_at",                 :null => false
  end

  add_index "cities", ["province_id"], :name => "index_cities_on_province_id"

  create_table "ckeditor_assets" do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "college_attachments" do |t|
    t.integer  "micro_college_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "college_attachments", ["micro_college_id"], :name => "index_college_attachments_on_micro_college_id"

  create_table "college_branches" do |t|
    t.integer  "site_id",                                   :null => false
    t.integer  "college_id",                                :null => false
    t.string   "name",                                      :null => false
    t.string   "tel",                                       :null => false
    t.integer  "province_id",              :default => 9,   :null => false
    t.integer  "city_id",                  :default => 73,  :null => false
    t.integer  "district_id",              :default => 702, :null => false
    t.string   "address",                                   :null => false
    t.integer  "status",      :limit => 1, :default => 1,   :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "college_branches", ["city_id"], :name => "index_college_branches_on_city_id"
  add_index "college_branches", ["college_id"], :name => "index_college_branches_on_college_id"
  add_index "college_branches", ["district_id"], :name => "index_college_branches_on_district_id"
  add_index "college_branches", ["province_id"], :name => "index_college_branches_on_province_id"
  add_index "college_branches", ["site_id"], :name => "index_college_branches_on_site_id"

  create_table "college_enrolls" do |t|
    t.integer  "site_id",                                      :null => false
    t.integer  "college_id",                                   :null => false
    t.integer  "college_major_id",                             :null => false
    t.integer  "user_id",                                      :null => false
    t.string   "name",                                         :null => false
    t.string   "mobile",                                       :null => false
    t.text     "description",                                  :null => false
    t.integer  "status",           :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "college_enrolls", ["college_id"], :name => "index_college_enrolls_on_college_id"
  add_index "college_enrolls", ["college_major_id"], :name => "index_college_enrolls_on_college_major_id"
  add_index "college_enrolls", ["site_id"], :name => "index_college_enrolls_on_site_id"
  add_index "college_enrolls", ["user_id"], :name => "index_college_enrolls_on_user_id"

  create_table "college_majors" do |t|
    t.integer  "college_id",  :null => false
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "college_majors", ["college_id"], :name => "index_college_majors_on_college_id"

  create_table "college_photos" do |t|
    t.integer  "college_id",  :null => false
    t.string   "name",        :null => false
    t.string   "pic_key"
    t.string   "description"
    t.text     "meta"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "college_photos", ["college_id"], :name => "index_college_photos_on_college_id"

  create_table "college_teachers" do |t|
    t.integer  "college_id",  :null => false
    t.string   "name",        :null => false
    t.string   "position"
    t.string   "avatar"
    t.text     "intro"
    t.text     "description"
    t.text     "meta"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "college_teachers", ["college_id"], :name => "index_college_teachers_on_college_id"

  create_table "colleges" do |t|
    t.integer  "site_id",                                 :null => false
    t.string   "name",                                    :null => false
    t.string   "tel"
    t.text     "intro"
    t.text     "security"
    t.string   "logo"
    t.string   "ad_pic"
    t.integer  "status",      :limit => 1, :default => 1
    t.text     "description"
    t.text     "meta"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "colleges", ["site_id"], :name => "index_colleges_on_site_id"

  create_table "comments" do |t|
    t.integer  "site_id",                                        :null => false
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "commenter_id"
    t.string   "commenter_type"
    t.string   "nickname"
    t.string   "email"
    t.integer  "status",            :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                     :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["commenter_id"], :name => "index_comments_on_commenter_id"
  add_index "comments", ["commenter_type"], :name => "index_comments_on_commenter_type"
  add_index "comments", ["site_id"], :name => "index_comments_on_site_id"

  create_table "consumes" do |t|
    t.integer  "site_id",                                       :null => false
    t.integer  "user_id",                                       :null => false
    t.integer  "activity_prize_id"
    t.integer  "consumable_id"
    t.string   "consumable_type"
    t.integer  "applicable_id"
    t.string   "applicable_type"
    t.string   "code",                                          :null => false
    t.string   "mobile"
    t.datetime "used_at"
    t.datetime "expired_at"
    t.text     "description"
    t.integer  "status",            :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "consumes", ["activity_prize_id"], :name => "index_consumes_on_activity_prize_id"
  add_index "consumes", ["applicable_id"], :name => "index_consumes_on_applicable_id"
  add_index "consumes", ["code"], :name => "index_consumes_on_code", :unique => true
  add_index "consumes", ["consumable_id"], :name => "index_consumes_on_consumable_id"
  add_index "consumes", ["site_id"], :name => "index_consumes_on_site_id"
  add_index "consumes", ["user_id"], :name => "index_consumes_on_user_id"

  create_table "coupons" do |t|
    t.integer  "activity_id",                                                                        :null => false
    t.integer  "site_id",                                                                            :null => false
    t.string   "coupon_type",                                        :default => "deduction_coupon"
    t.string   "name"
    t.string   "logo_key"
    t.string   "bgcolor"
    t.integer  "limit_count"
    t.integer  "people_limit_count"
    t.integer  "day_limit_count"
    t.integer  "position",                                           :default => 0
    t.integer  "status",                                             :default => 1,                  :null => false
    t.boolean  "vip_only",                                           :default => false
    t.boolean  "shop_branch_limited",                                :default => false
    t.text     "description"
    t.decimal  "value",               :precision => 10, :scale => 0
    t.decimal  "value_by",            :precision => 10, :scale => 0
    t.datetime "apply_start"
    t.datetime "apply_end"
    t.datetime "use_start"
    t.datetime "use_end"
    t.text     "meta"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  create_table "coupons_shop_branches" do |t|
    t.integer  "coupon_id",      :null => false
    t.integer  "shop_branch_id", :null => false
    t.datetime "created_at"
  end

  add_index "coupons_shop_branches", ["coupon_id"], :name => "index_coupons_shop_branches_on_coupon_id"
  add_index "coupons_shop_branches", ["shop_branch_id"], :name => "index_coupons_shop_branches_on_shop_branch_id"

  create_table "coupons_vip_grades", :id => false do |t|
    t.integer  "coupon_id"
    t.integer  "vip_grade_id"
    t.datetime "created_at"
  end

  add_index "coupons_vip_grades", ["coupon_id"], :name => "index_coupons_vip_grades_on_coupon_id"
  add_index "coupons_vip_grades", ["vip_grade_id"], :name => "index_coupons_vip_grades_on_vip_grade_id"

  create_table "custom_fields" do |t|
    t.string  "field_type",      :limit => 30, :default => ""
    t.string  "name",            :limit => 30, :default => ""
    t.string  "field_format",    :limit => 30, :default => ""
    t.text    "possible_values"
    t.integer "customized_id"
    t.integer "status",                        :default => 1
    t.integer "position",                      :default => 1
    t.text    "default_value"
    t.boolean "editable",                      :default => true
    t.boolean "is_required",                   :default => true
    t.string  "customized_type"
    t.string  "placeholder"
    t.boolean "visible",                       :default => true
  end

  add_index "custom_fields", ["customized_id", "customized_type"], :name => "index_custom_fields_on_customized_id_and_customized_type"

  create_table "custom_values" do |t|
    t.integer "vip_user_id"
    t.integer "custom_field_id", :default => 0
    t.text    "value"
    t.integer "customized_id"
    t.string  "customized_type"
  end

  add_index "custom_values", ["custom_field_id"], :name => "index_custom_values_on_custom_field_id"
  add_index "custom_values", ["customized_id", "customized_type"], :name => "index_custom_values_on_customized_id_and_customized_type"
  add_index "custom_values", ["vip_user_id"], :name => "index_custom_values_on_vip_user_id"

  create_table "delayed_jobs" do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts" do |t|
    t.string   "name",                       :null => false
    t.string   "pinyin"
    t.integer  "city_id",    :default => 73, :null => false
    t.integer  "sort",       :default => 0,  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "districts", ["city_id"], :name => "index_districts_on_city_id"

  create_table "doctor_arrange_items" do |t|
    t.integer  "hospital_doctor_id"
    t.integer  "doctor_arrange_id"
    t.integer  "hospital_department_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "mobile"
    t.integer  "doctor_watch_id"
    t.string   "order_no"
    t.integer  "status",                 :default => 1
    t.integer  "shop_branch_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "doctor_arrange_items", ["doctor_arrange_id"], :name => "index_doctor_arrange_items_on_doctor_arrange_id"
  add_index "doctor_arrange_items", ["hospital_department_id"], :name => "index_doctor_arrange_items_on_hospital_department_id"
  add_index "doctor_arrange_items", ["hospital_doctor_id"], :name => "index_doctor_arrange_items_on_hospital_doctor_id"
  add_index "doctor_arrange_items", ["user_id"], :name => "index_doctor_arrange_items_on_user_id"

  create_table "doctor_arranges" do |t|
    t.integer  "time_limit"
    t.integer  "week"
    t.string   "start_time"
    t.string   "end_time"
    t.integer  "shop_branch_id"
    t.integer  "arrange_limit"
    t.integer  "hospital_department_id"
    t.integer  "hospital_doctor_id"
    t.integer  "hospital_id"
    t.integer  "site_id"
    t.integer  "is_success",             :default => 1
    t.integer  "status",                 :default => 1
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "doctor_arranges", ["hospital_department_id"], :name => "index_doctor_arranges_on_hospital_department_id"
  add_index "doctor_arranges", ["hospital_doctor_id"], :name => "index_doctor_arranges_on_hospital_doctor_id"
  add_index "doctor_arranges", ["shop_branch_id"], :name => "index_doctor_arranges_on_shop_branch_id"
  add_index "doctor_arranges", ["site_id"], :name => "index_doctor_arranges_on_site_id"

  create_table "doctor_watches" do |t|
    t.integer  "doctor_arrange_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "status"
    t.integer  "limit"
    t.integer  "shop_branch_id"
    t.integer  "hospital_doctor_id"
    t.integer  "is_success",         :default => 2
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "donation_orders" do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.string   "subject"
    t.string   "body"
    t.decimal  "fee",            :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.string   "trade_no"
    t.string   "transaction_id"
    t.string   "trade_state"
    t.string   "paid_at"
    t.string   "pay_info"
    t.integer  "status", limit: 1, :default => 0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "donation_id"
    t.string   "name"
    t.string   "mobile"
    t.boolean  "receipt",                                       :default => false
    t.string   "address"
    t.string   "zip"
    t.integer  "pay_type",                                      :default => 1
  end

  create_table "donations" do |t|
    t.integer  "site_id"
    t.integer  "activity_id"
    t.string   "name"
    t.integer  "order"
    t.decimal  "init_fee",      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "init_number",                                  :default => 0
    t.string   "target_money"
    t.string   "default_money"
    t.text     "summary"
    t.string   "pic_key"
    t.text     "detail"
    t.string   "group_name"
    t.string   "qualification"
    t.string   "video_url"
    t.text     "feedback"
    t.integer  "status", limit: 1, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fans_games" do |t|
    t.string   "name",                      :null => false
    t.integer  "sort",       :default => 1
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "feedbacks" do |t|
    t.integer  "account_id",                           :null => false
    t.integer  "sub_account_id"
    t.string   "user_id"
    t.string   "user_type"
    t.string   "source_type"
    t.string   "contact"
    t.string   "contact_info"
    t.integer  "feedback_type",  :default => 1,     :null => false
    t.text     "content"
    t.integer  "admin_user_id"
    t.text     "reply"
    t.datetime "reply_at"
    t.boolean  "is_read",        :default => false
    t.integer  "status",         :default => 1,     :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "feedbacks", ["admin_user_id"], :name => "index_feedbacks_on_admin_user_id"
  add_index "feedbacks", ["account_id"], :name => "index_feedbacks_on_account_id"
  add_index "feedbacks", ["sub_account_id"], :name => "index_feedbacks_on_sub_account_id"
  add_index "feedbacks", ["user_id", "user_type"], :name => "index_feedbacks_on_user_id_and_user_type"

  create_table "fight_answers" do |t|
    t.integer  "site_id",                                              :null => false
    t.integer  "user_id",                                              :null => false
    t.integer  "activity_id",                                          :null => false
    t.integer  "fight_paper_question_id",                              :null => false
    t.integer  "the_day",                                              :null => false
    t.string   "user_answer"
    t.string   "correct_answer",                                       :null => false
    t.integer  "score",                                :default => 0,  :null => false
    t.integer  "speed",                                :default => 20, :null => false
    t.integer  "status",                  :limit => 1, :default => 0,  :null => false
    t.text     "description"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "fight_answers", ["activity_id"], :name => "index_fight_answers_on_activity_id"
  add_index "fight_answers", ["fight_paper_question_id"], :name => "index_fight_answers_on_fight_paper_question_id"
  add_index "fight_answers", ["site_id"], :name => "index_fight_answers_on_site_id"
  add_index "fight_answers", ["user_id"], :name => "index_fight_answers_on_user_id"

  create_table "fight_paper_questions" do |t|
    t.integer  "fight_paper_id",    :null => false
    t.integer  "fight_question_id", :null => false
    t.datetime "created_at",        :null => false
  end

  add_index "fight_paper_questions", ["fight_paper_id"], :name => "index_fight_paper_questions_on_fight_paper_id"
  add_index "fight_paper_questions", ["fight_question_id"], :name => "index_fight_paper_questions_on_fight_question_id"

  create_table "fight_papers" do |t|
    t.integer  "site_id",     :null => false
    t.integer  "activity_id", :null => false
    t.integer  "the_day",     :null => false
    t.date     "active_date", :null => false
    t.integer  "read_time"
    t.text     "description"
    t.string   "pic_key"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "fight_papers", ["activity_id"], :name => "index_fight_papers_on_activity_id"
  add_index "fight_papers", ["site_id"], :name => "index_fight_papers_on_site_id"

  create_table "fight_report_cards" do |t|
    t.integer  "site_id",                                         :null => false
    t.integer  "user_id",                                         :null => false
    t.integer  "activity_id",                                     :null => false
    t.integer  "activity_user_id",                                :null => false
    t.integer  "score",                            :default => 0, :null => false
    t.integer  "speed",                            :default => 0, :null => false
    t.integer  "win_status",          :limit => 1, :default => 0, :null => false
    t.integer  "status",              :limit => 1, :default => 0, :null => false
    t.integer  "activity_prize_id"
    t.integer  "activity_consume_id"
    t.text     "description"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "fight_report_cards", ["activity_consume_id"], :name => "index_fight_report_cards_on_activity_consume_id"
  add_index "fight_report_cards", ["activity_id"], :name => "index_fight_report_cards_on_activity_id"
  add_index "fight_report_cards", ["activity_prize_id"], :name => "index_fight_report_cards_on_activity_prize_id"
  add_index "fight_report_cards", ["activity_user_id"], :name => "index_fight_report_cards_on_activity_user_id"
  add_index "fight_report_cards", ["site_id"], :name => "index_fight_report_cards_on_site_id"
  add_index "fight_report_cards", ["user_id"], :name => "index_fight_report_cards_on_user_id"

  create_table "govchats" do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "status",      :default => 1
    t.integer  "chat_type",   :default => 1
    t.integer  "parent_id"
    t.text     "body"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "govchats", ["activity_id"], :name => "index_govchats_on_activity_id"
  add_index "govchats", ["user_id"], :name => "index_govchats_on_user_id"

  create_table "govmailboxes" do |t|
    t.integer  "activity_id"
    t.string   "name"
    t.string   "logo_key"
    t.integer  "sort",              :default => 1
    t.integer  "status",            :default => 1
    t.integer  "incomes_basecount", :default => 0
    t.integer  "replies_basecount", :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "govmailboxes", ["activity_id"], :name => "index_govmailboxes_on_activity_id"

  create_table "govmails" do |t|
    t.integer  "govmailbox_id"
    t.integer  "user_id"
    t.integer  "status",        :default => 1
    t.text     "body"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "parent_id"
  end

  add_index "govmails", ["govmailbox_id"], :name => "index_govmails_on_govmailbox_id"
  add_index "govmails", ["user_id"], :name => "index_govmails_on_user_id"

  create_table "greet_card_items" do |t|
    t.integer  "greet_card_id"
    t.integer  "greet_voice_id"
    t.integer  "user_id"
    t.string   "title",          :null => false
    t.string   "sender_name",    :null => false
    t.string   "content",        :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "greet_card_items", ["greet_card_id"], :name => "index_greet_card_items_on_greet_card_id"
  add_index "greet_card_items", ["user_id"], :name => "index_greet_card_items_on_user_id"

  create_table "greet_cards" do |t|
    t.string   "title"
    t.integer  "card_type",           :default => 1
    t.text     "content"
    t.boolean  "has_audio",           :default => false
    t.integer  "material_id"
    t.integer  "greet_id"
    t.string   "recommand_title_pic"
    t.string   "recommand_card_pic"
    t.string   "qiniu_title_pic_key"
    t.string   "qiniu_card_pic_key"
    t.integer  "status",              :default => 1,     :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "greet_cards", ["material_id"], :name => "index_greet_cards_on_material_id"

  create_table "greet_voices" do |t|
    t.string   "name"
    t.string   "sound"
    t.integer  "user_id"
    t.string   "media_id"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "greet_voices", ["user_id"], :name => "index_greet_voices_on_user_id"

  create_table "greets" do |t|
    t.integer  "site_id"
    t.integer  "activity_id"
    t.string   "name"
    t.string   "greet_cover"
    t.string   "recommand_pic"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "greets", ["activity_id"], :name => "index_greets_on_activity_id"
  add_index "greets", ["site_id"], :name => "index_greets_on_site_id"

  create_table "group_categories" do |t|
    t.integer  "site_id",                                 :null => false
    t.integer  "group_id"
    t.integer  "parent_id"
    t.string   "name",                                    :null => false
    t.integer  "sort",                     :default => 1, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "group_categories", ["group_id"], :name => "index_group_categories_on_group_id"
  add_index "group_categories", ["name"], :name => "index_group_categories_on_name"
  add_index "group_categories", ["parent_id"], :name => "index_group_categories_on_parent_id"
  add_index "group_categories", ["site_id"], :name => "index_group_categories_on_site_id"
  add_index "group_categories", ["sort"], :name => "index_group_categories_on_sort"

  create_table "group_comments" do |t|
    t.integer  "group_item_id"
    t.integer  "group_order_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "content"
    t.integer  "status",         :limit => 1, :default => 1
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "group_comments", ["group_item_id"], :name => "index_group_comments_on_group_item_id"
  add_index "group_comments", ["group_order_id"], :name => "index_group_comments_on_group_order_id"
  add_index "group_comments", ["user_id"], :name => "index_group_comments_on_user_id"

  create_table "group_item_pictures" do |t|
    t.integer  "group_item_id",                :null => false
    t.string   "pic_key"
    t.integer  "sort",          :default => 0, :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "group_item_pictures", ["group_item_id"], :name => "index_group_item_pictures_on_group_item_id"
  add_index "group_item_pictures", ["sort"], :name => "index_group_item_pictures_on_sort"

  create_table "group_items" do |t|
    t.integer  "site_id",                                                                          :null => false
    t.integer  "group_id"
    t.integer  "group_category_id",                                                                :null => false
    t.integer  "group_type"
    t.integer  "groupable_id"
    t.string   "groupable_type"
    t.string   "name",                                                                             :null => false
    t.string   "summary"
    t.decimal  "price",                            :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "market_price",                     :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "coupon_count",                                                    :default => 0,   :null => false
    t.integer  "limit_coupon_count",                                              :default => -1,  :null => false
    t.integer  "qty",                                                             :default => 0,   :null => false
    t.string   "pic_key"
    t.integer  "status",              :limit => 1,                                :default => 1,   :null => false
    t.text     "special_warn"
    t.text     "package_description"
    t.text     "description"
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
  end

  add_index "group_items", ["coupon_count"], :name => "index_group_items_on_coupon_count"
  add_index "group_items", ["end_at"], :name => "index_group_items_on_end_at"
  add_index "group_items", ["group_category_id"], :name => "index_group_items_on_group_category_id"
  add_index "group_items", ["group_id"], :name => "index_group_items_on_group_id"
  add_index "group_items", ["group_type"], :name => "index_group_items_on_group_type"
  add_index "group_items", ["groupable_id"], :name => "index_group_items_on_groupable_id"
  add_index "group_items", ["groupable_type"], :name => "index_group_items_on_groupable_type"
  add_index "group_items", ["limit_coupon_count"], :name => "index_group_items_on_limit_coupon_count"
  add_index "group_items", ["name"], :name => "index_group_items_on_name"
  add_index "group_items", ["site_id"], :name => "index_group_items_on_site_id"
  add_index "group_items", ["start_at"], :name => "index_group_items_on_start_at"

  create_table "group_orders" do |t|
    t.integer  "site_id",                                                                      :null => false
    t.integer  "user_id",                                                                      :null => false
    t.integer  "payment_type_id"
    t.integer  "group_id"
    t.integer  "group_item_id",                                                                :null => false
    t.string   "order_no"
    t.string   "code"
    t.string   "mobile"
    t.string   "username"
    t.integer  "qty",                                                         :default => 0,   :null => false
    t.decimal  "price",                        :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_amount",                 :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.datetime "completed_at"
    t.datetime "canceled_at"
    t.datetime "consume_at"
    t.text     "description"
    t.integer  "status",          :limit => 1,                                :default => 1
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
  end

  add_index "group_orders", ["group_id"], :name => "index_group_orders_on_group_id"
  add_index "group_orders", ["group_item_id"], :name => "index_group_orders_on_group_item_id"
  add_index "group_orders", ["mobile"], :name => "index_group_orders_on_mobile"
  add_index "group_orders", ["order_no"], :name => "index_group_orders_on_order_no"
  add_index "group_orders", ["payment_type_id"], :name => "index_group_orders_on_payment_type_id"
  add_index "group_orders", ["site_id"], :name => "index_group_orders_on_site_id"
  add_index "group_orders", ["user_id"], :name => "index_group_orders_on_user_id"

  create_table "groups" do |t|
    t.integer  "site_id",                                 :null => false
    t.string   "name",                                    :null => false
    t.string   "tel"
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"
  add_index "groups", ["site_id"], :name => "index_groups_on_site_id"

  create_table "guess_activity_questions" do |t|
    t.integer  "activity_id"
    t.integer  "question_id"
    t.integer  "view_count",  :default => 0
    t.boolean  "visible",     :default => true
    t.datetime "created_at"
  end

  add_index "guess_activity_questions", ["activity_id"], :name => "index_guess_activity_questions_on_activity_id"
  add_index "guess_activity_questions", ["question_id"], :name => "index_guess_activity_questions_on_question_id"

  create_table "guess_participations" do |t|
    t.integer  "activity_question_id"
    t.integer  "activity_id"
    t.integer  "question_id"
    t.integer  "user_id"
    t.integer  "activity_user_id"
    t.string   "answer"
    t.boolean  "answer_correct"
    t.integer  "consume_id"
    t.date     "created_date"
    t.datetime "created_at"
  end

  add_index "guess_participations", ["activity_id"], :name => "index_guess_participations_on_activity_id"
  add_index "guess_participations", ["activity_question_id"], :name => "index_guess_participations_on_activity_question_id"
  add_index "guess_participations", ["activity_user_id"], :name => "index_guess_participations_on_activity_user_id"
  add_index "guess_participations", ["consume_id"], :name => "index_guess_participations_on_consume_id"
  add_index "guess_participations", ["question_id"], :name => "index_guess_participations_on_question_id"
  add_index "guess_participations", ["user_id"], :name => "index_guess_participations_on_user_id"

  create_table "guess_settings" do |t|
    t.integer  "activity_id"
    t.integer  "user_day_answer_limit",                :default => 1
    t.integer  "user_total_answer_limit",              :default => 5
    t.integer  "question_answer_limit",                :default => 5
    t.integer  "user_type",               :limit => 1, :default => 1
    t.string   "user_info_columns"
    t.boolean  "use_points",                           :default => false
    t.integer  "answer_points",                        :default => 0
    t.string   "prize_type"
    t.integer  "prize_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "guess_settings", ["activity_id"], :name => "index_guess_settings_on_activity_id", :unique => true

  create_table "help_menus" do |t|
    t.string   "title",                      :null => false
    t.string   "help_url"
    t.integer  "sort",        :default => 0, :null => false
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "help_posts" do |t|
    t.integer  "help_menu_id",                                    :null => false
    t.string   "title",                                           :null => false
    t.text     "content",      :limit => 16777215
    t.integer  "sort",                             :default => 0, :null => false
    t.integer  "status",                           :default => 1, :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "help_posts", ["help_menu_id"], :name => "index_help_posts_on_help_menu_id"

  create_table "hospital_comments" do |t|
    t.integer  "site_id"
    t.integer  "hospital_id"
    t.integer  "hospital_doctor_id"
    t.integer  "user_id"
    t.string   "nickname"
    t.text     "content"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hospital_comments", ["hospital_doctor_id"], :name => "index_hospital_comments_on_hospital_doctor_id"
  add_index "hospital_comments", ["hospital_id"], :name => "index_hospital_comments_on_hospital_id"
  add_index "hospital_comments", ["site_id"], :name => "index_hospital_comments_on_site_id"
  add_index "hospital_comments", ["user_id"], :name => "index_hospital_comments_on_user_id"

  create_table "hospital_departments" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "hospital_id",                :null => false
    t.string   "name",                       :null => false
    t.integer  "parent_id",   :default => 0, :null => false
    t.integer  "sort",        :default => 1, :null => false
    t.integer  "status",      :default => 1, :null => false
    t.text     "road"
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "hospital_departments", ["hospital_id"], :name => "index_hospital_departments_on_hospital_id"
  add_index "hospital_departments", ["parent_id"], :name => "index_hospital_departments_on_parent_id"
  add_index "hospital_departments", ["site_id"], :name => "index_hospital_departments_on_site_id"
  add_index "hospital_departments", ["sort"], :name => "index_hospital_departments_on_sort"

  create_table "hospital_doctor_departments" do |t|
    t.integer  "hospital_doctor_id",     :null => false
    t.integer  "hospital_department_id", :null => false
    t.datetime "created_at",             :null => false
  end

  add_index "hospital_doctor_departments", ["hospital_department_id"], :name => "index_hospital_doctor_departments_on_hospital_department_id"
  add_index "hospital_doctor_departments", ["hospital_doctor_id"], :name => "index_hospital_doctor_departments_on_hospital_doctor_id"

  create_table "hospital_doctor_job_titles" do |t|
    t.integer  "hospital_doctor_id",    :null => false
    t.integer  "hospital_job_title_id", :null => false
    t.datetime "created_at",            :null => false
  end

  add_index "hospital_doctor_job_titles", ["hospital_doctor_id"], :name => "index_hospital_doctor_job_titles_on_hospital_doctor_id"
  add_index "hospital_doctor_job_titles", ["hospital_job_title_id"], :name => "index_hospital_doctor_job_titles_on_hospital_job_title_id"

  create_table "hospital_doctors" do |t|
    t.integer  "site_id",                                 :null => false
    t.integer  "hospital_id",                             :null => false
    t.string   "name",                                    :null => false
    t.integer  "gender",               :default => 1,     :null => false
    t.string   "avatar_key"
    t.string   "work_time"
    t.boolean  "is_online",            :default => false, :null => false
    t.integer  "limit_register_count", :default => -1,    :null => false
    t.integer  "status",               :default => 1,     :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "sort",                 :default => 0
  end

  add_index "hospital_doctors", ["hospital_id"], :name => "index_hospital_doctors_on_hospital_id"
  add_index "hospital_doctors", ["name"], :name => "index_hospital_doctors_on_name"
  add_index "hospital_doctors", ["site_id"], :name => "index_hospital_doctors_on_site_id"

  create_table "hospital_job_titles" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "hospital_id",                :null => false
    t.string   "name",                       :null => false
    t.integer  "sort",        :default => 1, :null => false
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "hospital_job_titles", ["hospital_id"], :name => "index_hospital_job_titles_on_hospital_id"
  add_index "hospital_job_titles", ["site_id"], :name => "index_hospital_job_titles_on_site_id"

  create_table "hospital_orders" do |t|
    t.integer  "site_id",                                                                :null => false
    t.integer  "user_id",                                                                :null => false
    t.integer  "hospital_id"
    t.integer  "hospital_department_id",                                                 :null => false
    t.integer  "hospital_doctor_id",                                                     :null => false
    t.string   "order_no",                                                               :null => false
    t.datetime "booking_at"
    t.datetime "expired_at"
    t.datetime "completed_at"
    t.datetime "canceled_at"
    t.decimal  "total_amount",           :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.string   "username"
    t.string   "tel"
    t.integer  "status",                                                :default => 1,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  add_index "hospital_orders", ["hospital_department_id"], :name => "index_hospital_orders_on_hospital_department_id"
  add_index "hospital_orders", ["hospital_doctor_id"], :name => "index_hospital_orders_on_hospital_doctor_id"
  add_index "hospital_orders", ["hospital_id"], :name => "index_hospital_orders_on_hospital_id"
  add_index "hospital_orders", ["order_no"], :name => "index_hospital_orders_on_order_no"
  add_index "hospital_orders", ["site_id"], :name => "index_hospital_orders_on_site_id"
  add_index "hospital_orders", ["user_id"], :name => "index_hospital_orders_on_user_id"

  create_table "hospitals" do |t|
    t.integer  "site_id",                    :null => false
    t.string   "name",                       :null => false
    t.string   "logo"
    t.string   "tel"
    t.string   "address"
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "hospitals", ["site_id"], :name => "index_hospitals_on_site_id"

  create_table "hotel_branches" do |t|
    t.integer  "site_id",                              :null => false
    t.integer  "hotel_id",                             :null => false
    t.string   "name",                                 :null => false
    t.string   "tel",                                  :null => false
    t.string   "tel_extension"
    t.boolean  "is_default",        :default => false, :null => false
    t.integer  "province_id",       :default => 9,     :null => false
    t.integer  "city_id",           :default => 73,    :null => false
    t.integer  "district_id",       :default => 702,   :null => false
    t.string   "address",                              :null => false
    t.string   "business_district",                    :null => false
    t.integer  "status",            :default => 1,     :null => false
    t.text     "description"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "mobile"
  end

  add_index "hotel_branches", ["city_id"], :name => "index_hotel_branches_on_city_id"
  add_index "hotel_branches", ["district_id"], :name => "index_hotel_branches_on_district_id"
  add_index "hotel_branches", ["hotel_id"], :name => "index_hotel_branches_on_hotel_id"
  add_index "hotel_branches", ["name"], :name => "index_hotel_branches_on_name"
  add_index "hotel_branches", ["province_id"], :name => "index_hotel_branches_on_province_id"
  add_index "hotel_branches", ["site_id"], :name => "index_hotel_branches_on_site_id"

  create_table "hotel_comments" do |t|
    t.integer  "hotel_id",                       :null => false
    t.integer  "hotel_branch_id",                :null => false
    t.integer  "site_id",                        :null => false
    t.integer  "user_id",                        :null => false
    t.integer  "hotel_order_id"
    t.string   "name",                           :null => false
    t.string   "mobile",                         :null => false
    t.text     "content",                        :null => false
    t.text     "reply_content"
    t.integer  "status",          :default => 0, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "hotel_comments", ["hotel_branch_id"], :name => "index_hotel_comments_on_hotel_branch_id"
  add_index "hotel_comments", ["hotel_id"], :name => "index_hotel_comments_on_hotel_id"
  add_index "hotel_comments", ["hotel_order_id"], :name => "index_hotel_comments_on_hotel_order_id"
  add_index "hotel_comments", ["site_id"], :name => "index_hotel_comments_on_site_id"
  add_index "hotel_comments", ["user_id"], :name => "index_hotel_comments_on_user_id"

  create_table "hotel_order_items" do |t|
    t.integer  "site_id",                           :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "hotel_id",                          :null => false
    t.integer  "hotel_branch_id",                   :null => false
    t.integer  "hotel_room_type_id",                :null => false
    t.integer  "hotel_order_id",                    :null => false
    t.date     "check_in_date",                     :null => false
    t.integer  "status",             :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "hotel_order_items", ["hotel_branch_id"], :name => "index_hotel_order_items_on_hotel_branch_id"
  add_index "hotel_order_items", ["hotel_id"], :name => "index_hotel_order_items_on_hotel_id"
  add_index "hotel_order_items", ["hotel_order_id"], :name => "index_hotel_order_items_on_hotel_order_id"
  add_index "hotel_order_items", ["hotel_room_type_id"], :name => "index_hotel_order_items_on_hotel_room_type_id"
  add_index "hotel_order_items", ["site_id"], :name => "index_hotel_order_items_on_site_id"
  add_index "hotel_order_items", ["user_id"], :name => "index_hotel_order_items_on_user_id"

  create_table "hotel_orders" do |t|
    t.integer  "site_id",                                                            :null => false
    t.integer  "user_id",                                                            :null => false
    t.integer  "hotel_id",                                                           :null => false
    t.integer  "hotel_branch_id",                                                    :null => false
    t.integer  "hotel_room_type_id",                                                 :null => false
    t.string   "order_no",                                                           :null => false
    t.datetime "expired_at",                                                         :null => false
    t.string   "name",                                                               :null => false
    t.string   "mobile",                                                             :null => false
    t.integer  "qty",                                               :default => 0,   :null => false
    t.date     "check_in_date",                                                      :null => false
    t.date     "check_out_date",                                                     :null => false
    t.integer  "check_in_days",                                     :default => 1,   :null => false
    t.decimal  "price",              :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_amount",       :precision => 10, :scale => 0,                  :null => false
    t.integer  "status",                                            :default => 1,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  add_index "hotel_orders", ["check_in_date"], :name => "index_hotel_orders_on_check_in_date"
  add_index "hotel_orders", ["expired_at"], :name => "index_hotel_orders_on_expired_at"
  add_index "hotel_orders", ["hotel_branch_id"], :name => "index_hotel_orders_on_hotel_branch_id"
  add_index "hotel_orders", ["hotel_id"], :name => "index_hotel_orders_on_hotel_id"
  add_index "hotel_orders", ["hotel_room_type_id"], :name => "index_hotel_orders_on_hotel_room_type_id"
  add_index "hotel_orders", ["mobile"], :name => "index_hotel_orders_on_mobile"
  add_index "hotel_orders", ["name"], :name => "index_hotel_orders_on_name"
  add_index "hotel_orders", ["order_no"], :name => "index_hotel_orders_on_order_no"
  add_index "hotel_orders", ["site_id"], :name => "index_hotel_orders_on_site_id"
  add_index "hotel_orders", ["user_id"], :name => "index_hotel_orders_on_user_id"

  create_table "hotel_pictures" do |t|
    t.integer  "hotel_id",                           :null => false
    t.integer  "hotel_branch_id",                    :null => false
    t.string   "name"
    t.string   "path"
    t.string   "qiniu_path_key"
    t.boolean  "is_cover",        :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "hotel_pictures", ["hotel_branch_id"], :name => "index_hotel_pictures_on_hotel_branch_id"
  add_index "hotel_pictures", ["hotel_id"], :name => "index_hotel_pictures_on_hotel_id"

  create_table "hotel_room_settings" do |t|
    t.integer  "hotel_id",                          :null => false
    t.integer  "hotel_branch_id",                   :null => false
    t.integer  "hotel_room_type_id",                :null => false
    t.date     "date",                              :null => false
    t.integer  "open_qty",           :default => 0, :null => false
    t.integer  "booked_qty",         :default => 0, :null => false
    t.integer  "available_qty",      :default => 0, :null => false
    t.integer  "status",             :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "hotel_room_settings", ["date"], :name => "index_hotel_room_settings_on_date"
  add_index "hotel_room_settings", ["hotel_branch_id"], :name => "index_hotel_room_settings_on_hotel_branch_id"
  add_index "hotel_room_settings", ["hotel_id"], :name => "index_hotel_room_settings_on_hotel_id"
  add_index "hotel_room_settings", ["hotel_room_type_id"], :name => "index_hotel_room_settings_on_hotel_room_type_id"

  create_table "hotel_room_types" do |t|
    t.integer  "hotel_id",                                                      :null => false
    t.integer  "hotel_branch_id",                                               :null => false
    t.string   "name",                                                          :null => false
    t.decimal  "price",           :precision => 10, :scale => 0,                :null => false
    t.decimal  "discount_price",  :precision => 10, :scale => 0
    t.integer  "open_qty",                                       :default => 0
    t.string   "pic_key"
    t.integer  "status",                                         :default => 1, :null => false
    t.boolean  "is_breakfast"
    t.boolean  "is_broadband"
    t.decimal  "area",            :precision => 10, :scale => 0
    t.string   "floor"
    t.boolean  "is_big_bed"
    t.string   "big_bed_spec"
    t.integer  "big_bed_count"
    t.boolean  "is_small_bed"
    t.string   "small_bed_spec"
    t.integer  "small_bed_count"
    t.text     "description"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "hotel_room_types", ["hotel_branch_id"], :name => "index_hotel_room_types_on_hotel_branch_id"
  add_index "hotel_room_types", ["hotel_id"], :name => "index_hotel_room_types_on_hotel_id"
  add_index "hotel_room_types", ["is_big_bed"], :name => "index_hotel_room_types_on_is_big_bed"
  add_index "hotel_room_types", ["is_breakfast"], :name => "index_hotel_room_types_on_is_breakfast"
  add_index "hotel_room_types", ["is_broadband"], :name => "index_hotel_room_types_on_is_broadband"
  add_index "hotel_room_types", ["is_small_bed"], :name => "index_hotel_room_types_on_is_small_bed"
  add_index "hotel_room_types", ["name"], :name => "index_hotel_room_types_on_name"

  create_table "hotels" do |t|
    t.integer  "site_id",                      :null => false
    t.string   "name",                         :null => false
    t.integer  "status",        :default => 1, :null => false
    t.string   "obligate_time",                :null => false
    t.string   "cancel_time",                  :null => false
    t.text     "description"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "hotels", ["site_id"], :name => "index_hotels_on_site_id"

  create_table "house_bespeaks" do |t|
    t.integer  "house_id",                                  :null => false
    t.integer  "user_id",                                   :null => false
    t.string   "name",                                      :null => false
    t.string   "mobile",       :limit => 15,                :null => false
    t.datetime "order_time",                                :null => false
    t.integer  "people_count",               :default => 1, :null => false
    t.integer  "status",       :limit => 1,  :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "house_bespeaks", ["house_id"], :name => "index_house_bespeaks_on_house_id"
  add_index "house_bespeaks", ["user_id"], :name => "index_house_bespeaks_on_user_id"

  create_table "house_comments" do |t|
    t.integer  "house_id",                                  :null => false
    t.integer  "site_id",                                   :null => false
    t.integer  "user_id",                                   :null => false
    t.string   "name",                                      :null => false
    t.string   "mobile",                                    :null => false
    t.text     "content",                                   :null => false
    t.text     "reply_content"
    t.integer  "status",        :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "house_comments", ["house_id"], :name => "index_house_comments_on_house_id"
  add_index "house_comments", ["site_id"], :name => "index_house_comments_on_site_id"
  add_index "house_comments", ["user_id"], :name => "index_house_comments_on_user_id"

  create_table "house_expert_comments" do |t|
    t.integer  "house_id",                                    :null => false
    t.integer  "house_expert_id",                             :null => false
    t.text     "content",                                     :null => false
    t.integer  "status",          :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "house_expert_comments", ["house_expert_id"], :name => "index_house_expert_comments_on_house_expert_id"
  add_index "house_expert_comments", ["house_id"], :name => "index_house_expert_comments_on_house_id"

  create_table "house_experts" do |t|
    t.integer  "site_id",                                 :null => false
    t.integer  "house_id",                                :null => false
    t.string   "name",                                    :null => false
    t.string   "intro",                                   :null => false
    t.string   "pic_key",                                 :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "house_experts", ["house_id"], :name => "index_house_experts_on_house_id"
  add_index "house_experts", ["site_id"], :name => "index_house_experts_on_site_id"

  create_table "house_impressions" do |t|
    t.integer  "house_id"
    t.integer  "ratio"
    t.string   "content"
    t.boolean  "predefined", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "house_impressions", ["house_id"], :name => "index_house_impressions_on_house_id"

  create_table "house_intro_pictures" do |t|
    t.integer  "house_intro_id"
    t.string   "pic_key"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "house_intros" do |t|
    t.integer "house_id"
    t.string  "pic_key"
    t.text    "description"
    t.string  "address"
    t.float   "location_x"
    t.float   "location_y"
    t.text    "video_url"
    t.text    "project_description"
    t.text    "traffic"
    t.string  "typed_address"
  end

  add_index "house_intros", ["house_id"], :name => "index_house_intros_on_house_id"

  create_table "house_layout_panoramas" do |t|
    t.integer "house_layout_id"
    t.string  "tile0"
    t.string  "tile1"
    t.string  "tile2"
    t.string  "tile3"
    t.string  "tile4"
    t.string  "tile5"
    t.string  "name"
  end

  add_index "house_layout_panoramas", ["house_layout_id"], :name => "index_house_layout_panoramas_on_house_layout_id"

  create_table "house_layouts" do |t|
    t.integer  "house_id",                                                                    :null => false
    t.string   "layout_number"
    t.string   "name",                                                                        :null => false
    t.decimal  "reference_area",                :precision => 12, :scale => 2,                :null => false
    t.decimal  "floor_height",                  :precision => 12, :scale => 2,                :null => false
    t.string   "orientation",                                                                 :null => false
    t.decimal  "price",                         :precision => 12, :scale => 2,                :null => false
    t.integer  "sales_heat",       :limit => 1,                                :default => 0, :null => false
    t.integer  "house_picture_id"
    t.text     "intro",                                                                       :null => false
    t.string   "view_link"
    t.integer  "status",           :limit => 1,                                :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  add_index "house_layouts", ["house_id"], :name => "index_house_layouts_on_house_id"
  add_index "house_layouts", ["house_picture_id"], :name => "index_house_layouts_on_house_picture_id"
  add_index "house_layouts", ["status"], :name => "index_house_layouts_on_status"

  create_table "house_live_photos" do |t|
    t.integer  "house_id"
    t.string   "wx_media_id"
    t.string   "pic_url"
    t.string   "status"
    t.integer  "user_id"
    t.float    "location_x"
    t.float    "location_y"
    t.float    "distance"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "house_live_photos", ["house_id"], :name => "index_house_live_photos_on_house_id"
  add_index "house_live_photos", ["user_id"], :name => "index_house_live_photos_on_user_id"

  create_table "house_pictures" do |t|
    t.integer  "house_id",                           :null => false
    t.integer  "house_layout_id"
    t.string   "name"
    t.string   "path"
    t.string   "pic_key"
    t.boolean  "is_cover",        :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "house_pictures", ["house_id"], :name => "index_house_pictures_on_house_id"
  add_index "house_pictures", ["house_layout_id"], :name => "index_house_pictures_on_house_layout_id"

  create_table "house_properties" do |t|
    t.integer  "house_id",                                          :null => false
    t.datetime "opening_at"
    t.string   "building_type"
    t.string   "decorate_condition"
    t.string   "region"
    t.string   "developer"
    t.string   "investors"
    t.string   "sales_address"
    t.string   "property_type"
    t.integer  "property_right"
    t.string   "link_position"
    t.decimal  "planning_area",      :precision => 12, :scale => 2
    t.decimal  "covered_area",       :precision => 12, :scale => 2
    t.integer  "household_count"
    t.integer  "parking_count"
    t.integer  "plot_ratio"
    t.decimal  "greening_rate",      :precision => 6,  :scale => 2
    t.string   "floor_condition"
    t.string   "progress_rate"
    t.text     "description"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "house_properties", ["house_id"], :name => "index_house_properties_on_house_id"

  create_table "house_reviews" do |t|
    t.integer  "house_id"
    t.string   "title"
    t.string   "author"
    t.string   "avatar_key"
    t.integer  "position"
    t.integer  "display_mode"
    t.text     "author_description"
    t.string   "author_title"
    t.text     "content"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "house_reviews", ["house_id"], :name => "index_house_reviews_on_house_id"

  create_table "house_sellers" do |t|
    t.integer  "house_id",                                     :null => false
    t.string   "name",                                         :null => false
    t.string   "phone",                                        :null => false
    t.string   "position",                                     :null => false
    t.string   "skilled_language",                             :null => false
    t.string   "pic_key"
    t.integer  "status",           :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "house_sellers", ["house_id"], :name => "index_house_sellers_on_house_id"

  create_table "houses" do |t|
    t.integer  "site_id",                                                                    :null => false
    t.string   "name",                                                                       :null => false
    t.integer  "house_type",    :limit => 1,                                :default => 0,   :null => false
    t.decimal  "price",                      :precision => 10, :scale => 0, :default => 0
    t.string   "tel"
    t.string   "tel_extension"
    t.integer  "province_id",                                               :default => 9,   :null => false
    t.integer  "city_id",                                                   :default => 73,  :null => false
    t.integer  "district_id",                                               :default => 702, :null => false
    t.string   "address"
    t.text     "intro_content"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  add_index "houses", ["city_id"], :name => "index_houses_on_city_id"
  add_index "houses", ["district_id"], :name => "index_houses_on_district_id"
  add_index "houses", ["house_type"], :name => "index_houses_on_house_type"
  add_index "houses", ["province_id"], :name => "index_houses_on_province_id"
  add_index "houses", ["site_id"], :name => "index_houses_on_site_id"

  create_table "igetui_messages" do |t|
    t.integer  "userable_id"
    t.string   "userable_type"
    t.integer  "messageable_id"
    t.string   "messageable_type"
    t.string   "source"
    t.string   "message"
    t.boolean  "is_read",          :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "interlocution_one_levels" do |t|
    t.string   "name",                       :null => false
    t.integer  "sort",        :default => 1, :null => false
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "interlocution_two_levels" do |t|
    t.integer  "interlocution_one_level_id"
    t.string   "name",                                      :null => false
    t.integer  "sort",                       :default => 1, :null => false
    t.integer  "status",                     :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "interlocution_two_levels", ["interlocution_one_level_id"], :name => "index_interlocution_two_levels_on_interlocution_one_level_id"

  create_table "interlocutions" do |t|
    t.integer  "interlocution_one_level_id"
    t.integer  "interlocution_two_level_id"
    t.text     "question",                                  :null => false
    t.text     "answer",                                    :null => false
    t.integer  "sort",                       :default => 1, :null => false
    t.integer  "status",                     :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "interlocutions", ["interlocution_one_level_id"], :name => "index_interlocutions_on_interlocution_one_level_id"
  add_index "interlocutions", ["interlocution_two_level_id"], :name => "index_interlocutions_on_interlocution_two_level_id"

  create_table "keywords" do |t|
    t.integer  "site_id",                          :null => false
    t.integer  "msg_type", :limit => 11, :default => 1, :null => false
    t.integer  "match_type", :limit => 11, :default => 1, :null => false
    t.string   "name"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "keywords", ["site_id"], :name => "index_keywords_on_site_id"

  create_table "replies" do |t|
    t.integer  "site_id"
    t.integer  "replier_id"
    t.string   "replier_type"
    t.string   "event_type",     :default => "text", :null => false
    t.integer  "reply_type",     :default => 1,      :null => false
    t.integer  "replyable_id"
    t.string   "replyable_type"
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "replies", ["site_id"], :name => "index_replies_on_site_id"
  add_index "replies", ["replier_id", "replier_type"], :name => "index_replies_replier"
  add_index "replies", ["replyable_id", "replyable_type"], :name => "index_replies_replyable"

  create_table "leaving_message_templates" do |t|
    t.integer  "site_id",                                 :null => false
    t.string   "header_bg"
    t.integer  "template_id", :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "leaving_message_templates", ["site_id"], :name => "site_id", :unique => true

  create_table "leaving_messages" do |t|
    t.integer  "site_id",                                  :null => false
    t.integer  "replier_id"
    t.string   "replier_type"
    t.string   "contact"
    t.string   "nickname"
    t.integer  "parent_id"
    t.integer  "status",       :limit => 1, :default => 1, :null => false
    t.text     "body",                                     :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "leaving_messages", ["nickname"], :name => "index_leaving_messages_on_nickname"
  add_index "leaving_messages", ["parent_id"], :name => "index_micro_leaving_messages_on_parent_id"
  add_index "leaving_messages", ["replier_id", "replier_type"], :name => "index_message_replier"
  add_index "leaving_messages", ["site_id"], :name => "index_leaving_messages_on_site_id"
  add_index "leaving_messages", ["status"], :name => "index_micro_leaving_messages_on_status"

  create_table "likes" do |t|
    t.integer  "site_id",                                   :null => false
    t.integer  "user_id",                                   :null => false
    t.integer  "likeable_id"
    t.string   "likeable_type"
    t.datetime "created_at",                                :null => false
  end

  add_index "likes", ["site_id"], :name => "index_likes_on_site_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "logged_exceptions" do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "lottery_draws" do |t|
    t.integer  "site_id",                                       :null => false
    t.integer  "user_id",                                       :null => false
    t.integer  "activity_id",                                   :null => false
    t.integer  "activity_prize_id"
    t.integer  "status",            :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "lottery_draws", ["activity_id"], :name => "index_lottery_draws_on_activity_id"
  add_index "lottery_draws", ["activity_prize_id"], :name => "index_lottery_draws_on_activity_prize_id"
  add_index "lottery_draws", ["site_id"], :name => "index_lottery_draws_on_site_id"
  add_index "lottery_draws", ["user_id"], :name => "index_lottery_draws_on_user_id"

  create_table "material_contents" do |t|
    t.integer "material_id"
    t.text    "content",     :limit => 16777215
  end

  add_index "material_contents", ["material_id"], :name => "index_material_contents_on_material_id"

  create_table "materials" do |t|
    t.integer  "parent_id",         :default => 0,    :null => false
    t.integer  "site_id",                             :null => false
    t.integer  "material_type",     :default => 1,    :null => false
    t.string   "title"
    t.string   "pic_key"
    t.boolean  "is_show_pic",       :default => true
    t.string   "source_url"
    t.text     "summary"
    t.string   "audio"
    t.string   "video"
    t.integer  "reply_type",        :default => 1,    :null => false
    t.integer  "materialable_id"
    t.string   "materialable_type"
    t.string   "qiniu_audio_url"
    t.integer  "fsize"
    t.text     "description"
    t.integer  "sort",              :default => 0,    :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "materials", ["materialable_id", "materialable_type"], :name => "index_materials_materialable"
  add_index "materials", ["parent_id"], :name => "index_materials_on_parent_id"
  add_index "materials", ["site_id"], :name => "index_materials_on_site_id"

  create_table "news" do |t|
    t.string   "title",                                         :null => false
    t.text     "content",                                       :null => false
    t.string   "short_content",              :default => ""
    t.integer  "content_type",  :limit => 1, :default => 1,     :null => false
    t.string   "link_url",                   :default => ""
    t.boolean  "top_line",                   :default => false, :null => false
    t.string   "pic_key"
    t.integer  "admin_user_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "news", ["admin_user_id"], :name => "index_news_on_admin_user_id"

  create_table "operation_records" do |t|
    t.string   "operator_code"
    t.string   "operator_name"
    t.integer  "operation_type", :limit => 1, :default => 10, :null => false
    t.integer  "module_type",    :limit => 1, :default => 1,  :null => false
    t.string   "comment"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "operation_records", ["module_type"], :name => "index_operation_records_on_module_type"
  add_index "operation_records", ["operation_type"], :name => "index_operation_records_on_operation_type"
  add_index "operation_records", ["operator_code"], :name => "index_operation_records_on_operator_code"
  add_index "operation_records", ["operator_name"], :name => "index_operation_records_on_operator_name"

  create_table "pair_maps" do |t|
    t.string   "paired_type"
    t.integer  "paired_id"
    t.string   "pairing_type"
    t.text     "pairing_value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "panoramagram_items" do |t|
    t.integer  "site_id",                        :null => false
    t.integer  "panoramagram_id",                :null => false
    t.integer  "sort",            :default => 1, :null => false
    t.string   "pic_key"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "panoramagram_items", ["panoramagram_id"], :name => "index_panoramagram_items_on_panoramagram_id"
  add_index "panoramagram_items", ["site_id"], :name => "index_panoramagram_items_on_site_id"

  create_table "panoramagrams" do |t|
    t.integer  "site_id",                                :null => false
    t.string   "name"
    t.string   "pic_key"
    t.integer  "sort",                    :default => 1, :null => false
    t.integer  "status",     :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "panoramagrams", ["site_id"], :name => "index_panoramagrams_on_site_id"

  create_table "panoramas" do |t|
    t.integer  "site_id",                                 :null => false
    t.string   "name"
    t.string   "file"
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "panoramas", ["site_id"], :name => "index_panoramas_on_site_id"

  create_table "pay_accounts" do |t|
    t.integer  "account_id",                                                                             :null => false
    t.decimal  "withdrawed_amount",                     :precision => 12, :scale => 2, :default => 0.0,  :null => false
    t.decimal  "balance",                               :precision => 12, :scale => 2, :default => 0.0,  :null => false
    t.decimal  "froze_amount",                          :precision => 12, :scale => 2, :default => 0.0,  :null => false
    t.string   "company_name"
    t.string   "bank_name"
    t.string   "bank_branch"
    t.string   "bank_account"
    t.string   "username"
    t.string   "contact"
    t.string   "tel"
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "status",                   :limit => 1,                                :default => 0,    :null => false
    t.text     "deny_remark"
    t.text     "description"
    t.string   "business_lisence"
    t.string   "business_address"
    t.datetime "business_affilicated_to"
    t.text     "business_scope"
    t.string   "organization_code"
    t.string   "business_lisence_pic_key"
    t.string   "identity_type"
    t.string   "identity_number"
    t.string   "email"
    t.datetime "identity_avaliable_to"
    t.string   "identity_pic_key"
    t.decimal  "settle_fee_rate",                       :precision => 6,  :scale => 4, :default => 0.02, :null => false
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
  end

  create_table "pay_transactions" do |t|
    t.integer  "account_id",                                                                        :null => false
    t.integer  "pay_account_id",                                                                    :null => false
    t.integer  "transactionable_id"
    t.string   "transactionable_type"
    t.string   "trade_no"
    t.decimal  "froze_amount",                      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "amount",                            :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "balance",                           :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "withdrawed_amount",                 :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "direction",            :limit => 1,                                :default => 1,   :null => false
    t.integer  "direction_type",       :limit => 1,                                :default => 11,  :null => false
    t.integer  "status",               :limit => 1,                                :default => 0,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
  end

  add_index "pay_transactions", ["account_id"], :name => "index_pay_transactions_on_account_id"
  add_index "pay_transactions", ["direction"], :name => "index_pay_transactions_on_direction"
  add_index "pay_transactions", ["direction_type"], :name => "index_pay_transactions_on_direction_type"
  add_index "pay_transactions", ["pay_account_id"], :name => "index_pay_transactions_on_pay_account_id"
  add_index "pay_transactions", ["status"], :name => "index_pay_transactions_on_status"
  add_index "pay_transactions", ["transactionable_id", "transactionable_type"], :name => "index_pay_transactionable"

  create_table "pay_withdraws" do |t|
    t.integer  "account_id",                                                                  :null => false
    t.integer  "pay_account_id"
    t.string   "trade_no"
    t.decimal  "amount",                      :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "fee",                         :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "receive_amount",              :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.datetime "pay_at"
    t.string   "bank_name"
    t.string   "bank_branch"
    t.string   "bank_account"
    t.integer  "admin_user_id"
    t.integer  "status",         :limit => 1,                                :default => 0,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  add_index "pay_withdraws", ["account_id"], :name => "index_pay_withdraws_on_account_id"
  add_index "pay_withdraws", ["admin_user_id"], :name => "index_pay_withdraws_on_admin_user_id"
  add_index "pay_withdraws", ["pay_account_id"], :name => "index_pay_withdraws_on_pay_account_id"
  add_index "pay_withdraws", ["trade_no"], :name => "index_pay_withdraws_on_trade_no"
  add_index "pay_withdraws", ["status"], :name => "index_pay_withdraws_on_status"

  create_table "payment_settings" do |t|
    t.integer  "site_id"
    t.string   "type"
    t.integer  "payment_type_id"
    t.string   "partner_id"
    t.text     "partner_key"
    t.string   "partner_account"
    t.string   "app_id"
    t.string   "app_secret"
    t.text     "pay_sign_key"
    t.text     "pay_private_key"
    t.text     "pay_public_key"
    t.text     "api_client_cert"
    t.text     "api_client_key"
    t.string   "product_catalog"
    t.integer  "sort",            :default => 1
    t.integer  "status",          :default => 1
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "payment_settings", ["payment_type_id"], :name => "index_payment_settings_on_payment_type_id"
  add_index "payment_settings", ["site_id"], :name => "index_payment_settings_on_site_id"

  create_table "payment_syncs" do |t|
    t.string   "status"
    t.integer  "payment_id"
    t.integer  "frequency_level"
    t.integer  "occur_count"
    t.string   "response_status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "payment_types" do |t|
    t.string   "name",                                    :null => false
    t.integer  "sort",        :limit => 1, :default => 1, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "payments" do |t|
    t.integer  "account_id"
    t.integer  "customer_id"
    t.string   "customer_type"
    t.integer  "paymentable_id"
    t.string   "paymentable_type"
    t.integer  "payment_type_id"
    t.string   "out_trade_no",                                                                                     :null => false
    t.string   "trade_no"
    t.string   "prepay_id"
    t.string   "trade_status",                                                    :default => "WAIT_BUYER_PAY",    :null => false
    t.decimal  "amount",                           :precision => 12, :scale => 2, :default => 0.0,                 :null => false
    t.decimal  "total_fee",                        :precision => 12, :scale => 2, :default => 0.0,                 :null => false
    t.string   "payment_type",        :limit => 1,                                :default => "1",                 :null => false
    t.string   "subject"
    t.string   "body"
    t.string   "quantity",                                                        :default => "1",                 :null => false
    t.decimal  "price",                            :precision => 12, :scale => 2, :default => 0.0,                 :null => false
    t.decimal  "discount",                         :precision => 12, :scale => 2, :default => 0.0,                 :null => false
    t.string   "is_total_fee_adjust", :limit => 1,                                :default => "N",                 :null => false
    t.string   "use_coupon",          :limit => 1,                                :default => "N",                 :null => false
    t.datetime "gmt_create"
    t.datetime "gmt_payment"
    t.datetime "gmt_close"
    t.string   "buyer_id"
    t.string   "buyer_email"
    t.string   "seller_id"
    t.string   "seller_email"
    t.string   "sign_type",                                                       :default => "MD5",               :null => false
    t.string   "sign"
    t.string   "notify_type",                                                     :default => "trade_status_sync", :null => false
    t.string   "notify_id"
    t.datetime "notify_time"
    t.boolean  "is_delivery",                                                     :default => false,               :null => false
    t.string   "callback_url"
    t.string   "merchant_url"
    t.string   "notify_url"
    t.string   "account_url"
    t.text     "order_msg"
    t.text     "pay_params"
    t.integer  "status",                                                          :default => 0,                   :null => false
    t.integer  "settle_status",                                                   :default => 0,                   :null => false
    t.decimal  "settle_fee_rate",                  :precision => 6,  :scale => 4, :default => 0.0,                 :null => false
    t.datetime "settle_at"
    t.string   "state"
    t.string   "open_id"
    t.string   "source"
    t.boolean  "is_trade_synced"
    t.datetime "created_at",                                                                                       :null => false
    t.datetime "updated_at",                                                                                       :null => false
  end

  add_index "payments", ["customer_id", "customer_type"], :name => "index_payments_on_customer_id_and_customer_type"
  add_index "payments", ["out_trade_no"], :name => "index_payments_on_out_trade_no"
  add_index "payments", ["paymentable_id", "paymentable_type"], :name => "index_payments_on_paymentable_id_and_paymentable_type"
  add_index "payments", ["prepay_id"], :name => "index_payments_on_prepay_id"
  add_index "payments", ["settle_at"], :name => "index_payments_on_settle_at"
  add_index "payments", ["settle_status"], :name => "index_payments_on_settle_status"
  add_index "payments", ["trade_no"], :name => "index_payments_on_trade_no"

  create_table "piwik_sites" do |t|
    t.integer  "site_id"
    t.date     "date"
    t.integer  "nb_uniq_visitors",     :default => 0, :null => false
    t.integer  "nb_visits",            :default => 0, :null => false
    t.integer  "nb_actions",           :default => 0, :null => false
    t.integer  "nb_visits_converted",  :default => 0, :null => false
    t.integer  "bounce_count",         :default => 0, :null => false
    t.integer  "sum_visit_length",     :default => 0, :null => false
    t.integer  "max_actions",          :default => 0, :null => false
    t.integer  "bounce_rate",          :default => 0, :null => false
    t.integer  "nb_actions_per_visit", :default => 0, :null => false
    t.integer  "avg_time_on_site",     :default => 0, :null => false
    t.datetime "updated_at"
  end

  add_index "piwik_sites", ["date", "site_id"], :name => "uni_date_and_site_id", :unique => true
  add_index "piwik_sites", ["nb_actions"], :name => "index_piwik_sites_on_nb_actions"
  add_index "piwik_sites", ["nb_uniq_visitors"], :name => "index_piwik_sites_on_nb_uniq_visitors"
  add_index "piwik_sites", ["nb_visits"], :name => "index_piwik_sites_on_nb_visits"

  create_table "point_gift_exchanges" do |t|
    t.integer  "site_id"
    t.integer  "vip_user_id",                               :null => false
    t.integer  "point_gift_id",                             :null => false
    t.integer  "total_points",               :default => 0, :null => false
    t.integer  "qty",                        :default => 0, :null => false
    t.integer  "status",        :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "point_gift_exchanges", ["point_gift_id"], :name => "index_point_gift_exchanges_on_point_gift_id"
  add_index "point_gift_exchanges", ["site_id"], :name => "index_point_gift_exchanges_on_site_id"
  add_index "point_gift_exchanges", ["vip_user_id"], :name => "index_point_gift_exchanges_on_vip_user_id"

  create_table "point_gifts" do |t|
    t.integer  "site_id",                                                                               :null => false
    t.string   "gift_no"
    t.string   "name",                                                                                  :null => false
    t.text     "description"
    t.integer  "points",                                                             :default => 0,     :null => false
    t.integer  "sku",                                                                :default => -1
    t.boolean  "all_grades",                                                         :default => true
    t.boolean  "normal_grade",                                                       :default => false
    t.integer  "people_limit_count",                                                 :default => -1
    t.boolean  "shop_branch_limited",                                                :default => false
    t.string   "shop_branch_ids",     :limit => 1000
    t.datetime "exchange_start_at"
    t.datetime "exchange_end_at"
    t.boolean  "award_time_limited",                                                 :default => false
    t.integer  "award_in_days",                                                      :default => 0
    t.decimal  "price",                               :precision => 12, :scale => 2
    t.string   "pic_key"
    t.integer  "status",              :limit => 1,                                   :default => 1,     :null => false
    t.text     "meta"
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
  end

  add_index "point_gifts", ["points"], :name => "index_point_gifts_on_points"
  add_index "point_gifts", ["site_id"], :name => "index_point_gifts_on_site_id"

  create_table "point_gifts_shop_branches" do |t|
    t.integer  "point_gift_id",  :null => false
    t.integer  "shop_branch_id", :null => false
    t.datetime "created_at"
  end

  add_index "point_gifts_shop_branches", ["point_gift_id"], :name => "index_point_gifts_shop_branches_on_point_gift_id"
  add_index "point_gifts_shop_branches", ["shop_branch_id"], :name => "index_point_gifts_shop_branches_on_shop_branch_id"

  create_table "point_gifts_vip_grades", :id => false do |t|
    t.integer  "point_gift_id"
    t.integer  "vip_grade_id"
    t.datetime "created_at"
  end

  add_index "point_gifts_vip_grades", ["point_gift_id"], :name => "index_point_gifts_vip_grades_on_point_gift_id"
  add_index "point_gifts_vip_grades", ["vip_grade_id"], :name => "index_point_gifts_vip_grades_on_vip_grade_id"

  create_table "point_transactions" do |t|
    t.integer  "site_id",                                    :null => false
    t.integer  "vip_user_id",                                :null => false
    t.integer  "shop_branch_id"
    t.integer  "point_type_id"
    t.integer  "direction_type",              :default => 1, :null => false
    t.integer  "points",                                     :null => false
    t.integer  "pointable_id"
    t.string   "pointable_type"
    t.integer  "status",         :limit => 1, :default => 1, :null => false
    t.string   "out_trade_no"
    t.text     "description"
    t.text     "meta"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "point_transactions", ["point_type_id", "pointable_type"], :name => "pointable_index"
  add_index "point_transactions", ["point_type_id"], :name => "index_point_transactions_on_point_type_id"
  add_index "point_transactions", ["shop_branch_id"], :name => "index_point_transactions_on_shop_branch_id"
  add_index "point_transactions", ["site_id"], :name => "index_point_transactions_on_site_id"
  add_index "point_transactions", ["vip_user_id"], :name => "index_point_transactions_on_vip_user_id"

  create_table "point_types" do |t|
    t.integer  "site_id",                                              :null => false
    t.integer  "category",             :limit => 1, :default => 3,     :null => false
    t.float    "amount",                            :default => 0.0,   :null => false
    t.integer  "points",                            :default => 0,     :null => false
    t.boolean  "accumulative",                      :default => false
    t.boolean  "checkin_enabled",                   :default => true
    t.boolean  "succ_checkin_enabled",              :default => false
    t.integer  "succ_checkin_days",                 :default => 0
    t.integer  "succ_checkin_points",               :default => 0
    t.integer  "sort",                              :default => 0,     :null => false
    t.integer  "status",               :limit => 1, :default => 1,     :null => false
    t.text     "description"
    t.text     "meta"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "point_types", ["site_id"], :name => "index_point_types_on_site_id"

  create_table "print_orders" do |t|
    t.integer  "status"
    t.integer  "shop_order_id"
    t.integer  "site_id"
    t.integer  "shop_branch_id"
    t.string   "address"
    t.integer  "shop_branch_print_template_id"
    t.text     "content"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "print_orders", ["shop_branch_id"], :name => "index_print_orders_on_shop_branch_id"
  add_index "print_orders", ["shop_order_id"], :name => "index_print_orders_on_shop_order_id"
  add_index "print_orders", ["site_id"], :name => "index_print_orders_on_site_id"

  create_table "prints" do |t|
    t.integer  "account_id"
    t.string   "token"
    t.string   "url"
    t.integer  "status",         :default => 1, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "provinces" do |t|
    t.string   "name",                      :null => false
    t.string   "pinyin"
    t.integer  "sort",       :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "qiniu_pictures" do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "sn"
    t.datetime "created_at"
  end

  create_table "qrcode_invitations" do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "created_at"
  end

  create_table "qrcode_logs" do |t|
    t.integer  "site_id",                        :null => false
    t.integer  "user_id",                        :null => false
    t.integer  "qrcode_id",                      :null => false
    t.integer  "qrcodeable_id"
    t.string   "qrcodeable_type"
    t.string   "event"
    t.string   "event_key"
    t.integer  "status",          :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "qrcode_logs", ["qrcode_id"], :name => "index_qrcode_logs_on_qrcode_id"
  add_index "qrcode_logs", ["qrcodeable_id", "qrcodeable_type"], :name => "qrcodeable_index"
  add_index "qrcode_logs", ["site_id"], :name => "index_qrcode_logs_on_site_id"
  add_index "qrcode_logs", ["user_id"], :name => "index_qrcode_logs_on_user_id"

  create_table "qrcode_users" do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.integer  "qrcode_id"
    t.decimal  "vip_amount",        :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "ec_amount",         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "restaurant_amount", :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "take_out_amount",   :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "hotel_amount",      :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "total_amount",      :precision => 12, :scale => 2, :default => 0.0
    t.date     "created_date"
    t.integer  "status",                                           :default => 1,   :null => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  add_index "qrcode_users", ["qrcode_id"], :name => "index_qrcode_users_on_qrcode_id"
  add_index "qrcode_users", ["site_id"], :name => "index_qrcode_users_on_site_id"
  add_index "qrcode_users", ["user_id"], :name => "index_qrcode_users_on_user_id"

  create_table "qrcodes" do |t|
    t.integer  "site_id"
    t.string   "name"
    t.integer  "expire_seconds"
    t.integer  "action_name"
    t.string   "scene_id"
    t.string   "ticket"
    t.text     "description"
    t.integer  "status",         :default => 1, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "qrcode_source"
  end

  create_table "red_packet_releases" do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "activity_user_id"
    t.float    "award_amount"
    t.datetime "used_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "red_packet_releases", ["activity_id"], :name => "index_red_packet_releases_on_activity_id"
  add_index "red_packet_releases", ["activity_user_id"], :name => "index_red_packet_releases_on_activity_user_id"
  add_index "red_packet_releases", ["user_id"], :name => "index_red_packet_releases_on_user_id"

  create_table "red_packet_send_records" do |t|
    t.integer  "site_id"
    t.integer  "activity_id"
    t.integer  "activity_user_id"
    t.integer  "user_id"
    t.integer  "red_packet_id"
    t.integer  "activity_consume_id"
    t.string   "out_trade_no"
    t.string   "trade_no"
    t.string   "trans_id"
    t.string   "detail_id"
    t.string   "openid"
    t.decimal  "total_amount",        :precision => 10, :scale => 2
    t.integer  "total_num",                                          :default => 1, :null => false
    t.integer  "status"
    t.string   "fault_reason"
    t.string   "hb_type"
    t.string   "send_type"
    t.datetime "send_at"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "refunded_at"
    t.decimal  "refund_amount",       :precision => 10, :scale => 2
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  add_index "red_packet_send_records", ["red_packet_id"], :name => "index_red_packet_send_record_on_red_packet"
  add_index "red_packet_send_records", ["site_id", "openid"], :name => "index_red_packet_send_records_on_site_id_and_openid"

  create_table "red_packet_settings" do |t|
    t.integer  "packet_num"
    t.float    "amount"
    t.boolean  "amount_random"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "share_award"
    t.float    "people_amount_limit"
    t.float    "share_add_amount"
    t.boolean  "share_add_amount_random"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "red_packets" do |t|
    t.integer  "activity_id"
    t.integer  "activity_prize_id"
    t.integer  "site_id"
    t.integer  "payment_type_id"
    t.integer  "status",                                           :default => 1,     :null => false
    t.integer  "records_count",                                    :default => 0,     :null => false
    t.decimal  "total_amount",      :precision => 10, :scale => 2
    t.decimal  "min_value",         :precision => 10, :scale => 2
    t.decimal  "max_value",         :precision => 10, :scale => 2
    t.integer  "total_num",                                        :default => 1,     :null => false
    t.decimal  "total_budget",      :precision => 10, :scale => 2
    t.decimal  "budget_balance",    :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "random",                                           :default => false, :null => false
    t.string   "type"
    t.integer  "receive_type"
    t.string   "name"
    t.string   "act_name"
    t.string   "nick_name"
    t.string   "send_name"
    t.string   "wishing"
    t.string   "remark"
    t.string   "logo_imgurl"
    t.string   "share_content"
    t.string   "share_url"
    t.string   "share_imgurl"
    t.datetime "send_at"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
  end

  create_table "reservation_orders" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "activity_id",                :null => false
    t.integer  "user_id",                    :null => false
    t.integer  "status",      :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "role_assets" do |t|
    t.integer  "role_id",            :null => false
    t.integer  "system_function_id"
    t.datetime "created_at"
  end

  add_index "role_assets", ["role_id"], :name => "index_role_assets_on_role_id"
  add_index "role_assets", ["system_function_id"], :name => "index_role_assets_on_system_function_id"

  create_table "roles" do |t|
    t.string   "key"
    t.string   "name",                      :null => false
    t.integer  "sort",       :default => 0, :null => false
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "scene_htmls" do |t|
    t.integer  "activity_id"
    t.string   "version"
    t.text     "content",     :limit => 16777215
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "scene_htmls", ["activity_id"], :name => "index_scene_htmls_on_activity_id"

  create_table "scenes" do |t|
    t.integer  "activity_id"
    t.integer  "position",        :default => 0
    t.integer  "scene_type",      :default => 0
    t.string   "pic_key"
    t.string   "button_pic_key"
    t.string   "location_x"
    t.string   "location_y"
    t.string   "address"
    t.integer  "button_position", :default => 0
    t.integer  "menuable_id"
    t.integer  "menuable_type"
    t.string   "url"
    t.string   "tel"
    t.text     "related_text"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "scenes", ["activity_id"], :name => "index_scenes_on_activity_id"

  create_table "session_users" do |t|
    t.integer  "site_id"
    t.string   "openid"
    t.integer  "status",     :limit => 1, :default => 1
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "session_users", ["site_id", "openid"], :name => "index_session_users_on_site_id_and_openid"

  create_table "share_photo_comments" do |t|
    t.integer  "site_id",                       :null => false
    t.integer  "share_photo_id",                :null => false
    t.integer  "user_id"
    t.string   "nickname"
    t.text     "content",                       :null => false
    t.integer  "status",         :default => 1, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "share_photo_comments", ["share_photo_id"], :name => "index_share_photo_comments_on_share_photo_id"
  add_index "share_photo_comments", ["site_id"], :name => "index_share_photo_comments_on_site_id"
  add_index "share_photo_comments", ["user_id"], :name => "index_share_photo_comments_on_user_id"

  create_table "share_photo_likes" do |t|
    t.integer  "site_id",                       :null => false
    t.integer  "share_photo_id",                :null => false
    t.integer  "user_id"
    t.integer  "status",         :default => 1, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "share_photo_likes", ["share_photo_id"], :name => "index_share_photo_likes_on_share_photo_id"
  add_index "share_photo_likes", ["site_id"], :name => "index_share_photo_likes_on_site_id"
  add_index "share_photo_likes", ["user_id"], :name => "index_share_photo_likes_on_user_id"

  create_table "share_photo_settings" do |t|
    t.integer  "site_id",                            :null => false
    t.string   "name"
    t.text     "upload_description"
    t.text     "add_tag_description"
    t.integer  "request_expired_at",  :default => 2, :null => false
    t.integer  "status",              :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "share_photo_settings", ["site_id"], :name => "index_share_photo_settings_on_site_id"

  create_table "share_photo_subjects" do |t|
    t.integer  "share_photo_setting_id",                :null => false
    t.string   "name",                                  :null => false
    t.string   "keyword",                               :null => false
    t.integer  "sort",                   :default => 0, :null => false
    t.text     "content",                               :null => false
    t.integer  "status",                 :default => 1, :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "share_photo_subjects", ["share_photo_setting_id"], :name => "index_share_photo_subjects_on_share_photo_setting_id"

  create_table "share_photos" do |t|
    t.integer  "site_id",                                   :null => false
    t.integer  "user_id",                                   :null => false
    t.integer  "share_photo_setting_id",                    :null => false
    t.integer  "share_photo_subject_id"
    t.string   "title"
    t.string   "pic_url"
    t.integer  "comments_count",         :default => 0,     :null => false
    t.integer  "likes_count",            :default => 0,     :null => false
    t.boolean  "is_choice",              :default => false, :null => false
    t.integer  "pv_count",               :default => 0,     :null => false
    t.integer  "status",                 :default => 1,     :null => false
    t.text     "description"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "share_photos", ["share_photo_setting_id"], :name => "index_share_photos_on_share_photo_setting_id"
  add_index "share_photos", ["site_id"], :name => "index_share_photos_on_site_id"
  add_index "share_photos", ["user_id"], :name => "index_share_photos_on_user_id"

  create_table "share_settings" do |t|
    t.string   "title"
    t.string   "summary"
    t.string   "pic_key"
    t.integer  "shareable_id"
    t.string   "shareable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "shop_branch_print_templates" do |t|
    t.integer  "shop_branch_id"
    t.text     "content"
    t.integer  "template_type"
    t.boolean  "is_open",          :default => false
    t.string   "title"
    t.text     "description"
    t.boolean  "is_print_kitchen", :default => false
    t.integer  "print_type"
    t.boolean  "is_auto_print",    :default => true
    t.string   "open_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "shop_branch_print_templates", ["shop_branch_id"], :name => "index_shop_branch_print_templates_on_shop_branch_id"

  create_table "shop_branches" do |t|
    t.integer  "site_id",                             :null => false
    t.integer  "shop_id",                             :null => false
    t.string   "name",                                :null => false
    t.string   "tel",                                 :null => false
    t.integer  "province_id",      :default => 9
    t.integer  "city_id",          :default => 73
    t.integer  "district_id",      :default => 702
    t.string   "address"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "hall_count",       :default => 0,     :null => false
    t.integer  "loge_count",       :default => 0,     :null => false
    t.integer  "open_hall_count",  :default => 0,     :null => false
    t.integer  "open_loge_count",  :default => 0,     :null => false
    t.datetime "open_at"
    t.integer  "status",           :default => 1,     :null => false
    t.text     "book_table_rule"
    t.text     "book_dinner_rule"
    t.text     "description"
    t.string   "mobile"
    t.string   "password_digest"
    t.string   "location_address"
    t.float    "location_x"
    t.float    "location_y"
    t.text     "metadata"
    t.integer  "print_type"
    t.integer  "government_type",  :default => 1,     :null => false
    t.integer  "shop_menu_id"
    t.string   "print_title"
    t.boolean  "is_auto_print",    :default => false
    t.string   "print_no"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "shop_branches", ["city_id"], :name => "index_shop_branches_on_city_id"
  add_index "shop_branches", ["district_id"], :name => "index_shop_branches_on_district_id"
  add_index "shop_branches", ["name"], :name => "index_shop_branches_on_name"
  add_index "shop_branches", ["shop_id"], :name => "index_shop_branches_on_shop_id"
  add_index "shop_branches", ["site_id"], :name => "index_shop_branches_on_site_id"
  add_index "shop_branches", ["tel"], :name => "index_shop_branches_on_tel"

  create_table "shop_branches_vip_packages" do |t|
    t.integer  "shop_branch_id", :null => false
    t.integer  "vip_package_id", :null => false
    t.datetime "created_at"
  end

  add_index "shop_branches_vip_packages", ["shop_branch_id"], :name => "index_shop_branches_vip_packages_on_shop_branch_id"
  add_index "shop_branches_vip_packages", ["vip_package_id"], :name => "index_shop_branches_vip_packages_on_vip_package_id"

  create_table "shop_categories" do |t|
    t.integer  "site_id",                       :null => false
    t.integer  "shop_id",                       :null => false
    t.integer  "shop_menu_id"
    t.integer  "shop_branch_id"
    t.string   "name",                          :null => false
    t.integer  "sort",           :default => 0, :null => false
    t.integer  "status",         :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "parent_id",      :default => 0
  end

  add_index "shop_categories", ["shop_branch_id"], :name => "index_shop_categories_on_shop_branch_id"
  add_index "shop_categories", ["shop_id"], :name => "index_shop_categories_on_shop_id"
  add_index "shop_categories", ["site_id"], :name => "index_shop_categories_on_site_id"

  create_table "shop_menus" do |t|
    t.integer  "shop_id"
    t.string   "menu_no"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "shop_menus", ["shop_id"], :name => "index_shop_menus_on_shop_id"

  create_table "shop_order_items" do |t|
    t.integer  "site_id",                                                         :null => false
    t.integer  "shop_id",                                                         :null => false
    t.integer  "shop_branch_id",                                                  :null => false
    t.integer  "shop_order_id",                                                   :null => false
    t.integer  "shop_product_id",                                                 :null => false
    t.string   "product_name",                                                    :null => false
    t.integer  "qty",                                            :default => 0,   :null => false
    t.decimal  "price",           :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "discount",        :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_price",     :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_pay_price", :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "status",                                         :default => 1,   :null => false
    t.text     "description"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  add_index "shop_order_items", ["shop_branch_id"], :name => "index_shop_order_items_on_shop_branch_id"
  add_index "shop_order_items", ["shop_id"], :name => "index_shop_order_items_on_shop_id"
  add_index "shop_order_items", ["shop_order_id"], :name => "index_shop_order_items_on_shop_order_id"
  add_index "shop_order_items", ["shop_product_id"], :name => "index_shop_order_items_on_shop_product_id"
  add_index "shop_order_items", ["site_id"], :name => "index_shop_order_items_on_site_id"

  create_table "shop_order_reports" do |t|
    t.integer  "site_id",                                                        :null => false
    t.integer  "shop_id",                                                        :null => false
    t.integer  "shop_branch_id",                                                 :null => false
    t.date     "date",                                                           :null => false
    t.integer  "orders_count",                                  :default => 0,   :null => false
    t.decimal  "total_amount",   :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "pay_amount",     :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.integer  "order_type"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  add_index "shop_order_reports", ["date"], :name => "index_shop_order_reports_on_date"
  add_index "shop_order_reports", ["shop_branch_id"], :name => "index_shop_order_reports_on_shop_branch_id"
  add_index "shop_order_reports", ["shop_id"], :name => "index_shop_order_reports_on_shop_id"
  add_index "shop_order_reports", ["site_id"], :name => "index_shop_order_reports_on_site_id"

  create_table "shop_orders" do |t|
    t.integer  "site_id",                                                          :null => false
    t.integer  "user_id"
    t.integer  "shop_id",                                                          :null => false
    t.integer  "shop_branch_id",                                                   :null => false
    t.integer  "order_type",                                    :default => 1,     :null => false
    t.string   "order_no",                                                         :null => false
    t.decimal  "total_amount",   :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "pay_amount",     :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.string   "mobile"
    t.string   "address"
    t.datetime "expired_at"
    t.integer  "status",                                        :default => 1,     :null => false
    t.text     "description"
    t.boolean  "is_print",                                      :default => false
    t.boolean  "print_finish",                                  :default => false
    t.string   "username"
    t.integer  "ref_order_id"
    t.integer  "pay_type",                                      :default => 0
    t.integer  "pay_status"
    t.datetime "book_at"
    t.integer  "book_status"
    t.string   "captcha"
    t.string   "queue_no"
    t.string   "desk_no"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "shop_orders", ["mobile"], :name => "index_shop_orders_on_mobile"
  add_index "shop_orders", ["order_no"], :name => "index_shop_orders_on_order_no"
  add_index "shop_orders", ["shop_branch_id"], :name => "index_shop_orders_on_shop_branch_id"
  add_index "shop_orders", ["shop_id"], :name => "index_shop_orders_on_shop_id"
  add_index "shop_orders", ["site_id"], :name => "index_shop_orders_on_site_id"

  create_table "shop_product_comments" do |t|
    t.integer  "shop_product_id",                             :null => false
    t.integer  "user_id",                                     :null => false
    t.text     "content",                                     :null => false
    t.integer  "status",          :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "shop_product_comments", ["shop_product_id"], :name => "index_shop_product_comments_on_shop_product_id"
  add_index "shop_product_comments", ["user_id"], :name => "index_shop_product_comments_on_user_id"

  create_table "shop_products" do |t|
    t.integer  "site_id",                                                              :null => false
    t.integer  "shop_id",                                                              :null => false
    t.integer  "shop_branch_id"
    t.integer  "shop_category_id"
    t.string   "name",                                                                 :null => false
    t.string   "code",                                                                 :null => false
    t.decimal  "price",              :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "discount",           :precision => 6,  :scale => 2, :default => 0.0,   :null => false
    t.boolean  "is_new",                                            :default => false, :null => false
    t.boolean  "is_hot",                                            :default => false, :null => false
    t.boolean  "is_current_price",                                  :default => false
    t.string   "pic_url"
    t.integer  "status",                                            :default => 1,     :null => false
    t.text     "description"
    t.string   "pic_key"
    t.integer  "shop_menu_id"
    t.integer  "sort",                                              :default => 0
    t.integer  "category_parent_id"
    t.boolean  "is_category_top",                                   :default => false
    t.integer  "quantity"
    t.integer  "shelve_status",                                     :default => 1
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  add_index "shop_products", ["name"], :name => "index_shop_products_on_name"
  add_index "shop_products", ["shop_branch_id"], :name => "index_shop_products_on_shop_branch_id"
  add_index "shop_products", ["shop_category_id"], :name => "index_shop_products_on_shop_category_id"
  add_index "shop_products", ["shop_id"], :name => "index_shop_products_on_shop_id"
  add_index "shop_products", ["site_id"], :name => "index_shop_products_on_site_id"

  create_table "shop_table_orders" do |t|
    t.integer  "site_id",                           :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "shop_id",                           :null => false
    t.integer  "shop_branch_id",                    :null => false
    t.integer  "table_type",     :default => 1,     :null => false
    t.string   "order_no",                          :null => false
    t.datetime "booking_at",                        :null => false
    t.integer  "booking_count",  :default => 0,     :null => false
    t.string   "mobile",                            :null => false
    t.integer  "status",         :default => 1,     :null => false
    t.text     "description"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_print",       :default => false
    t.boolean  "print_finish",   :default => false
    t.string   "username"
    t.integer  "ref_order_id"
    t.integer  "pay_status"
  end

  add_index "shop_table_orders", ["mobile"], :name => "index_shop_table_orders_on_mobile"
  add_index "shop_table_orders", ["order_no"], :name => "index_shop_table_orders_on_order_no"
  add_index "shop_table_orders", ["shop_branch_id"], :name => "index_shop_table_orders_on_shop_branch_id"
  add_index "shop_table_orders", ["shop_id"], :name => "index_shop_table_orders_on_shop_id"
  add_index "shop_table_orders", ["site_id"], :name => "index_shop_table_orders_on_site_id"
  add_index "shop_table_orders", ["user_id"], :name => "index_shop_table_orders_on_user_id"

  create_table "shop_table_settings" do |t|
    t.integer  "site_id",                                     :null => false
    t.integer  "shop_id",                                     :null => false
    t.integer  "shop_branch_id",                              :null => false
    t.date     "date",                                        :null => false
    t.integer  "open_hall_count",              :default => 0, :null => false
    t.integer  "open_loge_count",              :default => 0, :null => false
    t.integer  "status",          :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "shop_table_settings", ["date"], :name => "index_shop_table_settings_on_date"
  add_index "shop_table_settings", ["shop_branch_id"], :name => "index_shop_table_settings_on_shop_branch_id"
  add_index "shop_table_settings", ["shop_id"], :name => "index_shop_table_settings_on_shop_id"
  add_index "shop_table_settings", ["site_id"], :name => "index_shop_table_settings_on_site_id"

  create_table "shops" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "shop_type",   :default => 1, :null => false
    t.string   "name",                       :null => false
    t.string   "logo"
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "metadata"
  end

  add_index "shops", ["name"], :name => "index_shops_on_name"
  add_index "shops", ["site_id"], :name => "index_shops_on_site_id"

  create_table "sms_expenses" do |t|
    t.integer  "account_id"
    t.date     "date"
    t.string   "phone"
    t.string   "content",      :limit => 512, :default => "1"
    t.integer  "operation_id", :limit => 1
    t.integer  "status",       :limit => 1,   :default => 1,   :null => false
    t.datetime "created_at"
  end

  add_index "sms_expenses", ["account_id", "date"]

  create_table "sms_logs" do |t|
    t.integer  "account_id"
    t.date     "date"
    t.string   "phone"
    t.string   "content",       :limit => 512, :default => "1"
    t.string   "provider"
    t.string   "return_code"
    t.integer  "userable_id"
    t.string   "userable_type"
    t.string   "source"
    t.datetime "created_at"
  end

  add_index :sms_logs, [:account_id, :date]

  create_table "sms_orders" do |t|
    t.integer  "account_id"
    t.date     "date"
    t.string   "plan_name",                              :null => false
    t.integer  "plan_type",  :limit => 1, :default => 1, :null => false
    t.integer  "plan_sms",                :default => 0, :null => false
    t.integer  "plan_id",                                :null => false
    t.integer  "plan_cost"
    t.string   "order_no",                               :null => false
    t.integer  "status",                  :default => 0, :null => false
    t.text     "remark"
    t.datetime "created_at"
  end

  add_index "sms_orders", ["account_id"], :name => "index_sms_orders_on_account_id"

  create_table "sn_code_scan_logs" do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.string   "code"
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "sn_codes" do |t|
    t.integer  "site_id"
    t.string   "code"
    t.datetime "expired_at"
    t.integer  "status",     :default => 1, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "sn_codes", ["code"], :name => "index_sn_codes_on_code"

  create_table "spread_records" do |t|
    t.string   "model_name",                                   :null => false
    t.integer  "model_id",                                     :null => false
    t.string   "attr_name",                                    :null => false
    t.integer  "attr_class_id", :limit => 1,    :default => 1, :null => false
    t.string   "attr_value",    :limit => 2000
    t.datetime "updated_at"
  end

  add_index "spread_records", ["model_name", "model_id", "attr_name"], :name => "uni_mma", :unique => true

  create_table "standalone_panoramas" do |t|
    t.integer  "panoramic_id"
    t.string   "panoramic_type"
    t.string   "file_url"
    t.string   "name"
    t.string   "preview_url"
    t.string   "file_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "sub_accounts" do |t|
    t.integer  "account_type",    :limit => 1, :default => 1
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username",                                    :null => false
    t.string   "email"
    t.string   "auth_token"
    t.string   "password_digest"
    t.text     "permissions"
    t.text     "meta"
    t.integer  "status",          :limit => 1, :default => 1
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "sub_accounts", ["user_id", "user_type"], :name => "index_sub_accounts_on_user_id_and_user_type"
  add_index "sub_accounts", ["username"], :name => "index_sub_accounts_on_username"

  create_table "survey_answers" do |t|
    t.integer  "activity_id"
    t.integer  "activity_user_id"
    t.integer  "survey_question_id"
    t.integer  "user_id"
    t.string   "answer"
    t.string   "summary"
    t.integer  "survey_question_choice_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "survey_answers", ["activity_id"], :name => "index_survey_answers_on_activity_id"
  add_index "survey_answers", ["survey_question_id"], :name => "index_survey_answers_on_survey_question_id"
  add_index "survey_answers", ["activity_user_id"], :name => "index_survey_answers_on_activity_user_id"
  add_index "survey_answers", ["survey_question_choice_id"], :name => "index_survey_answers_on_survey_question_choice_id"
  add_index "survey_answers", ["user_id"], :name => "index_survey_answers_on_user_id"

  create_table "survey_questions" do |t|
    t.integer  "activity_id"
    t.string   "name"
    t.integer  "limit_select",         :default => 1,     :null => false
    t.string   "answer_a"
    t.string   "answer_b"
    t.string   "answer_c"
    t.string   "answer_d"
    t.string   "answer_e"
    t.boolean  "answer_other",         :default => false
    t.string   "answer_a_pic"
    t.string   "answer_b_pic"
    t.integer  "survey_question_type", :default => 1
    t.integer  "position",             :default => 0
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "survey_questions", ["activity_id"], :name => "index_survey_questions_on_activity_id"

  create_table "survey_question_choices" do |t|
    t.integer  "survey_question_id"
    t.string   "name"
    t.string   "pic_key"
    t.integer  "position",                    :default => 0
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "survey_question_choices", ["survey_question_id"], :name => "index_survey_question_choices_on_survey_question_id"

  create_table "system_functions" do |t|
    t.integer  "system_module_id",                :null => false
    t.string   "name",                            :null => false
    t.integer  "group_id",         :default => 1, :null => false
    t.string   "url"
    t.integer  "sort",             :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "system_functions", ["system_module_id"], :name => "index_system_functions_on_system_module_id"

  create_table "system_message_modules" do |t|
    t.string   "name"
    t.integer  "module_id"
    t.datetime "created_at"
  end

  create_table "system_message_settings" do |t|
    t.integer  "site_id"
    t.integer  "system_message_module_id"
    t.string   "voice"
    t.boolean  "is_open_voice",            :default => false
    t.boolean  "is_open",                  :default => true
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "system_message_settings", ["site_id"], :name => "index_system_message_settings_on_site_id"
  add_index "system_message_settings", ["system_message_module_id"], :name => "index_system_message_settings_on_system_message_module_id"

  create_table "system_messages" do |t|
    t.integer  "site_id"
    t.integer  "system_message_setting_id"
    t.integer  "system_message_module_id"
    t.string   "content"
    t.string   "meta"
    t.boolean  "is_read",                   :default => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "system_messages", ["site_id"], :name => "index_system_messages_on_site_id"
  add_index "system_messages", ["system_message_module_id"], :name => "index_system_messages_on_system_message_module_id"
  add_index "system_messages", ["system_message_setting_id"], :name => "index_system_messages_on_system_message_setting_id"

  create_table "system_modules" do |t|
    t.string   "name",                      :null => false
    t.string   "html_rel"
    t.string   "url"
    t.integer  "sort",       :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "taggings" do |t|
    t.integer  "tag_id"
    t.integer  "position"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.text     "description"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true

  create_table "tags" do |t|
    t.integer "parent_id"
    t.integer "children_count", :default => 0
    t.integer "position"
    t.string  "name"
    t.integer "taggings_count", :default => 0
    t.integer "copy_id"
    t.integer "copy_count",     :default => 0
  end

  create_table "thermal_printers" do |t|
    t.integer  "shop_branch_print_template_id"
    t.string   "no"
    t.string   "address"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "trip_ads" do |t|
    t.integer  "site_id",                                 :null => false
    t.integer  "trip_id"
    t.string   "title"
    t.string   "url"
    t.string   "pic_key"
    t.integer  "sort",                     :default => 0, :null => false
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "trip_ads", ["site_id"], :name => "index_trip_ads_on_site_id"
  add_index "trip_ads", ["sort"], :name => "index_trip_ads_on_sort"
  add_index "trip_ads", ["trip_id"], :name => "index_trip_ads_on_trip_id"

  create_table "trip_orders" do |t|
    t.integer  "site_id",                                                                     :null => false
    t.integer  "user_id",                                                                     :null => false
    t.integer  "trip_id"
    t.integer  "trip_ticket_id"
    t.string   "order_no",                                                                    :null => false
    t.datetime "booking_at"
    t.datetime "expired_at"
    t.datetime "canceled_at"
    t.integer  "qty",                                                        :default => 0,   :null => false
    t.decimal  "price",                       :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total_amount",                :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.string   "username"
    t.string   "tel"
    t.integer  "status",         :limit => 1,                                :default => 1,   :null => false
    t.text     "description"
    t.string   "ticket_name"
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  add_index "trip_orders", ["order_no"], :name => "index_trip_orders_on_order_no"
  add_index "trip_orders", ["site_id"], :name => "index_trip_orders_on_site_id"
  add_index "trip_orders", ["trip_id"], :name => "index_trip_orders_on_trip_id"
  add_index "trip_orders", ["trip_ticket_id"], :name => "index_trip_orders_on_trip_ticket_id"
  add_index "trip_orders", ["user_id"], :name => "index_trip_orders_on_user_id"

  create_table "trip_ticket_categories" do |t|
    t.integer  "site_id"
    t.string   "name"
    t.integer  "children_count", :default => 0
    t.integer  "parent_id"
    t.integer  "position",       :default => 1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "trip_ticket_categories", ["site_id"], :name => "index_trip_ticket_categories_on_site_id"

  create_table "trip_tickets" do |t|
    t.integer  "site_id",                                                                              :null => false
    t.integer  "trip_id"
    t.integer  "trip_ticket_category_id"
    t.string   "name",                                                                                 :null => false
    t.decimal  "price",                                :precision => 12, :scale => 2, :default => 0.0, :null => false
    t.string   "tel"
    t.integer  "valid_day"
    t.string   "pic_key"
    t.integer  "status",                  :limit => 1,                                :default => 1,   :null => false
    t.text     "description"
    t.text     "content"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
  end

  add_index "trip_tickets", ["name"], :name => "index_trip_tickets_on_name"
  add_index "trip_tickets", ["site_id"], :name => "index_trip_tickets_on_site_id"
  add_index "trip_tickets", ["trip_id"], :name => "index_trip_tickets_on_trip_id"
  add_index "trip_tickets", ["trip_ticket_category_id"], :name => "index_trip_tickets_on_trip_ticket_category_id"

  create_table "trips" do |t|
    t.integer  "site_id",                    :null => false
    t.string   "name",                       :null => false
    t.string   "logo"
    t.string   "tel"
    t.string   "address"
    t.integer  "status",      :default => 1, :null => false
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "trips", ["site_id"], :name => "index_trips_on_site_id"

  create_table "users" do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "mobile"
    t.integer  "gender",     :default => 1, :null => false
    t.string   "address"
    t.integer  "status",     :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "users", ["site_id"], :name => "index_users_on_site_id"

  create_table "vip_api_settings" do |t|
    t.integer  "site_id"
    t.integer  "vip_card_id"
    t.string   "callback_domain"
    t.string   "auth_type"
    t.string   "auth_username"
    t.string   "auth_password"
    t.string   "auth_token"
    t.text     "metadata"
    t.integer  "status",          :limit => 1
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "vip_api_settings", ["site_id"], :name => "index_vip_api_settings_on_site_id"
  add_index "vip_api_settings", ["vip_card_id"], :name => "index_vip_api_settings_on_vip_card_id"

  create_table "vip_card_branches" do |t|
    t.integer  "vip_card_id",                         :null => false
    t.string   "name",                                :null => false
    t.string   "pic_key"
    t.string   "discount_name",                       :null => false
    t.string   "discount_description"
    t.string   "address"
    t.string   "tel"
    t.string   "name_bg_color"
    t.string   "card_bg_color"
    t.string   "cardable_type"
    t.integer  "cardable_id"
    t.integer  "status",               :default => 1, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "vip_card_branches", ["name"], :name => "index_vip_card_branches_on_name"
  add_index "vip_card_branches", ["vip_card_id"], :name => "index_vip_card_branches_on_vip_card_id"

  create_table "vip_cards" do |t|
    t.integer  "site_id",                                               :null => false
    t.integer  "template_id",                        :default => 1
    t.integer  "activity_id",                                           :null => false
    t.string   "name"
    t.string   "merchant_name"
    t.string   "mobile"
    t.string   "tel"
    t.string   "name_bg_color"
    t.string   "card_bg_color"
    t.string   "background_pic"
    t.string   "logo_key"
    t.string   "cover_pic_key"
    t.string   "cover_pic_name"
    t.integer  "limit_privilege_count", :limit => 1, :default => 0,     :null => false
    t.integer  "status",                :limit => 1, :default => 1,     :null => false
    t.boolean  "audited",                            :default => false, :null => false
    t.boolean  "is_open_points",                     :default => true,  :null => false
    t.integer  "province_id",                        :default => 9,     :null => false
    t.integer  "city_id",                            :default => 73,    :null => false
    t.integer  "district_id",                        :default => 702,   :null => false
    t.string   "address"
    t.string   "location_x"
    t.string   "location_y"
    t.text     "description"
    t.text     "points_description"
    t.text     "metadata"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "vip_cards", ["activity_id"], :name => "index_vip_cards_on_activity_id"
  add_index "vip_cards", ["city_id"], :name => "index_vip_cards_on_city_id"
  add_index "vip_cards", ["district_id"], :name => "index_vip_cards_on_district_id"
  add_index "vip_cards", ["province_id"], :name => "index_vip_cards_on_province_id"
  add_index "vip_cards", ["site_id"], :name => "index_vip_cards_on_site_id"

  create_table "vip_cares" do |t|
    t.integer  "vip_card_id",                                              :null => false
    t.string   "name",                                                     :null => false
    t.integer  "category",         :limit => 1,    :default => 1,          :null => false
    t.integer  "care_month",       :limit => 1,    :default => 1
    t.date     "care_day"
    t.integer  "given_type",       :limit => 1,    :default => 1,          :null => false
    t.integer  "given_points",                     :default => 0
    t.string   "given_coupon_ids", :limit => 1000
    t.string   "given_gift_ids",   :limit => 1000
    t.integer  "given_coupon_id"
    t.string   "given_group_type",                 :default => "VipGroup"
    t.integer  "given_group_id"
    t.datetime "message_send_at"
    t.text     "message_body",                                             :null => false
    t.integer  "status",           :limit => 1,    :default => 1,          :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  add_index "vip_cares", ["vip_card_id"], :name => "index_vip_cares_on_vip_card_id"

  create_table "vip_external_http_apis" do |t|
    t.integer  "site_id"
    t.integer  "vip_card_id"
    t.integer  "api_type",    :limit => 2
    t.string   "name"
    t.string   "path"
    t.string   "http_method"
    t.text     "description"
    t.text     "metadata"
    t.integer  "status",      :limit => 1
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "vip_external_http_apis", ["site_id"], :name => "index_vip_external_http_apis_on_site_id"
  add_index "vip_external_http_apis", ["vip_card_id"], :name => "index_vip_external_http_apis_on_vip_card_id"

  create_table "vip_givens" do |t|
    t.integer  "vip_care_id",                 :null => false
    t.integer  "vip_user_id",                 :null => false
    t.integer  "category",     :default => 1, :null => false
    t.integer  "value"
    t.integer  "used_value",   :default => 0
    t.integer  "givable_id"
    t.string   "givable_type"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "description"
    t.integer  "status",       :default => 1, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "vip_givens", ["vip_care_id"], :name => "index_vip_givens_on_vip_care_id"
  add_index "vip_givens", ["vip_user_id"], :name => "index_vip_givens_on_vip_user_id"

  create_table "vip_grade_logs" do |t|
    t.integer  "site_id",            :null => false
    t.integer  "vip_user_id",        :null => false
    t.integer  "old_vip_grade_id"
    t.string   "old_vip_grade_name"
    t.integer  "now_vip_grade_id"
    t.string   "now_vip_grade_name"
    t.string   "description"
    t.string   "operater_type"
    t.integer  "operater_id"
    t.integer  "shop_branch_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "vip_grade_logs", ["operater_id"], :name => "index_vip_grade_logs_on_operater_id"
  add_index "vip_grade_logs", ["shop_branch_id"], :name => "index_vip_grade_logs_on_shop_branch_id"
  add_index "vip_grade_logs", ["site_id"], :name => "index_vip_grade_logs_on_site_id"
  add_index "vip_grade_logs", ["vip_user_id"], :name => "index_vip_grade_logs_on_vip_user_id"

  create_table "vip_grades" do |t|
    t.integer  "vip_card_id",                                  :null => false
    t.integer  "vip_users_count",              :default => 0
    t.string   "name",                                         :null => false
    t.string   "cover",                        :default => ""
    t.integer  "category",        :limit => 1, :default => 1,  :null => false
    t.integer  "value",                        :default => 1,  :null => false
    t.integer  "sort",                         :default => 1,  :null => false
    t.text     "description"
    t.integer  "status",          :limit => 1, :default => 1,  :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "vip_grades", ["vip_card_id"], :name => "index_vip_grades_on_vip_card_id"

  create_table "vip_grades_vip_privileges", :id => false do |t|
    t.integer  "vip_grade_id",     :null => false
    t.integer  "vip_privilege_id", :null => false
    t.datetime "created_at",       :null => false
  end

  add_index "vip_grades_vip_privileges", ["vip_grade_id"], :name => "index_vip_grades_vip_privileges_on_vip_grade_id"
  add_index "vip_grades_vip_privileges", ["vip_privilege_id"], :name => "index_vip_grades_vip_privileges_on_vip_privilege_id"

  create_table "vip_groups" do |t|
    t.integer  "vip_card_id",                    :null => false
    t.integer  "vip_users_count", :default => 0
    t.string   "name",                           :null => false
    t.integer  "sort",            :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "vip_groups", ["vip_card_id"], :name => "index_vip_user_groups_on_site_id"

  create_table "vip_importing_logs" do |t|
    t.integer  "site_id"
    t.integer  "error_type"
    t.text     "error_msg"
    t.text     "line"
    t.text     "meta"
    t.datetime "created_at"
  end

  add_index "vip_importing_logs", ["site_id"], :name => "index_vip_importing_logs_on_site_id"

  create_table "vip_importings" do |t|
    t.integer  "site_id"
    t.integer  "vip_user_id"
    t.integer  "vip_grade_id"
    t.string   "vip_grade_name"
    t.string   "user_no"
    t.string   "name"
    t.string   "mobile"
    t.integer  "age"
    t.datetime "birthday"
    t.float    "total_amount",          :default => 0.0
    t.float    "total_recharge_amount", :default => 0.0
    t.float    "total_consume_amount",  :default => 0.0
    t.float    "usable_amount",         :default => 0.0
    t.integer  "total_points",          :default => 0
    t.integer  "usable_points",         :default => 0
    t.datetime "open_card_time"
    t.integer  "status",                :default => 1
    t.datetime "created_at"
  end

  add_index "vip_importings", ["site_id", "mobile"], :name => "index_vip_importings_on_site_id_and_mobile", :unique => true
  add_index "vip_importings", ["site_id", "user_no"], :name => "index_vip_importings_on_site_id_and_user_no", :unique => true
  add_index "vip_importings", ["vip_user_id"], :name => "index_vip_importings_on_vip_user_id"

  create_table "vip_message_plans" do |t|
    t.integer  "vip_card_id",                              :null => false
    t.string   "title",                                    :null => false
    t.string   "given_group_type", :default => "VipGroup"
    t.integer  "given_group_id"
    t.integer  "vip_users_count",  :default => 0,          :null => false
    t.text     "content",                                  :null => false
    t.boolean  "scheduled",        :default => false,      :null => false
    t.datetime "send_at"
    t.integer  "status",           :default => 1,          :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "vip_message_plans", ["given_group_id"], :name => "index_vip_message_plans_on_vip_user_group_id"
  add_index "vip_message_plans", ["vip_card_id"], :name => "index_vip_message_plans_on_site_id"

  create_table "vip_package_item_consumes" do |t|
    t.integer  "site_id"
    t.integer  "vip_user_id"
    t.integer  "shop_branch_id"
    t.integer  "vip_package_id"
    t.integer  "vip_packages_vip_user_id"
    t.integer  "vip_package_item_id"
    t.string   "package_item_name"
    t.decimal  "package_item_price",       :precision => 10, :scale => 0
    t.text     "metadata"
    t.string   "sn_code"
    t.integer  "status"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "vip_package_item_consumes", ["shop_branch_id"], :name => "index_vip_package_item_consumes_on_shop_branch_id"
  add_index "vip_package_item_consumes", ["site_id"], :name => "index_vip_package_item_consumes_on_site_id"
  add_index "vip_package_item_consumes", ["vip_package_id"], :name => "index_vip_package_item_consumes_on_vip_package_id"
  add_index "vip_package_item_consumes", ["vip_package_item_id"], :name => "index_vip_package_item_consumes_on_vip_package_item_id"
  add_index "vip_package_item_consumes", ["vip_packages_vip_user_id"], :name => "index_vip_package_item_consumes_on_vip_packages_vip_user_id"
  add_index "vip_package_item_consumes", ["vip_user_id"], :name => "index_vip_package_item_consumes_on_vip_user_id"

  create_table "vip_package_items" do |t|
    t.integer  "site_id"
    t.integer  "vip_card_id"
    t.string   "name"
    t.decimal  "price",       :precision => 12, :scale => 2
    t.text     "description"
    t.integer  "status",                                     :default => 1, :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
  end

  add_index "vip_package_items", ["site_id"], :name => "index_vip_package_items_on_site_id"
  add_index "vip_package_items", ["vip_card_id"], :name => "index_vip_package_items_on_vip_card_id"

  create_table "vip_package_items_vip_packages" do |t|
    t.integer  "vip_package_id",                     :null => false
    t.integer  "vip_package_item_id",                :null => false
    t.integer  "items_count",         :default => 1, :null => false
    t.datetime "created_at",                         :null => false
  end

  add_index "vip_package_items_vip_packages", ["vip_package_id"], :name => "index_vip_package_items_vip_packages_on_vip_package_id"
  add_index "vip_package_items_vip_packages", ["vip_package_item_id"], :name => "index_vip_package_items_vip_packages_on_vip_package_item_id"

  create_table "vip_packages" do |t|
    t.integer  "site_id"
    t.integer  "vip_card_id"
    t.string   "name"
    t.decimal  "price",               :precision => 12, :scale => 2
    t.integer  "expiry_num"
    t.string   "expiry_unit"
    t.text     "description"
    t.boolean  "shop_branch_limited",                                :default => false
    t.integer  "status",                                             :default => 1,     :null => false
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
  end

  add_index "vip_packages", ["site_id"], :name => "index_vip_packages_on_site_id"
  add_index "vip_packages", ["vip_card_id"], :name => "index_vip_packages_on_vip_card_id"

  create_table "vip_packages_vip_users" do |t|
    t.integer  "site_id"
    t.integer  "vip_user_id"
    t.integer  "vip_package_id"
    t.integer  "shop_branch_id"
    t.text     "description"
    t.datetime "expired_at"
    t.string   "package_name"
    t.decimal  "package_price",  :precision => 10, :scale => 0
    t.text     "metadata"
    t.integer  "status"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "vip_packages_vip_users", ["site_id"], :name => "index_vip_packages_vip_users_on_site_id"
  add_index "vip_packages_vip_users", ["vip_package_id"], :name => "index_vip_packages_vip_users_on_vip_package_id"
  add_index "vip_packages_vip_users", ["vip_user_id"], :name => "index_vip_packages_vip_users_on_vip_user_id"

  create_table "vip_privilege_transactions", :id => false do |t|
    t.integer  "vip_user_id",      :null => false
    t.integer  "vip_privilege_id", :null => false
    t.datetime "created_at"
  end

  add_index "vip_privilege_transactions", ["vip_privilege_id"], :name => "index_vip_privilege_transactions_on_vip_privilege_id"
  add_index "vip_privilege_transactions", ["vip_user_id"], :name => "index_vip_privilege_transactions_on_vip_user_id"

  create_table "vip_privileges" do |t|
    t.integer  "vip_card_id",                                     :null => false
    t.string   "title",                                           :null => false
    t.integer  "category",        :limit => 1, :default => 1,     :null => false
    t.float    "amount",                       :default => 0.0
    t.integer  "value_by",        :limit => 1, :default => 1,     :null => false
    t.float    "value",                        :default => 0.0,   :null => false
    t.boolean  "normal_grade",                 :default => false, :null => false
    t.boolean  "always_valid",                 :default => true,  :null => false
    t.text     "content",                                         :null => false
    t.integer  "limit_count",                  :default => -1,    :null => false
    t.integer  "day_limit_count",              :default => -1,    :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "status",                       :default => 0,     :null => false
    t.text     "description"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "vip_privileges", ["vip_card_id"], :name => "index_vip_privileges_on_vip_card_id"

  create_table "vip_recharge_orders" do |t|
    t.integer  "site_id",                                                       :null => false
    t.integer  "vip_user_id",                                                   :null => false
    t.string   "order_no",                                                      :null => false
    t.string   "vip_user_name"
    t.string   "vip_user_mobile"
    t.decimal  "amount",          :precision => 12, :scale => 2,                :null => false
    t.decimal  "pay_amount",      :precision => 12, :scale => 2,                :null => false
    t.integer  "pay_type"
    t.integer  "given_points",                                   :default => 0
    t.text     "description"
    t.integer  "status",                                         :default => 1, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "vip_recharge_orders", ["site_id"], :name => "index_vip_recharge_orders_on_site_id"
  add_index "vip_recharge_orders", ["vip_user_id"], :name => "index_vip_recharge_orders_on_vip_user_id"

  create_table "vip_user_messages" do |t|
    t.integer  "site_id",                                     :null => false
    t.integer  "vip_user_id",                                 :null => false
    t.boolean  "is_read",                  :default => false, :null => false
    t.integer  "msg_type",    :limit => 1, :default => 1,     :null => false
    t.integer  "send_type",   :limit => 1, :default => 1,     :null => false
    t.string   "title",                                       :null => false
    t.text     "content",                                     :null => false
    t.integer  "status",      :limit => 1, :default => 1,     :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "vip_user_messages", ["site_id"], :name => "index_vip_user_messages_on_site_id"
  add_index "vip_user_messages", ["vip_user_id"], :name => "index_vip_user_messages_on_vip_user_id"

  create_table "vip_user_payments" do |t|
    t.integer  "site_id"
    t.integer  "vip_user_id"
    t.integer  "user_id"
    t.string   "open_id"
    t.integer  "status"
    t.string   "trade_no"
    t.decimal  "amount",       :precision => 12, :scale => 2
    t.string   "subject"
    t.string   "source"
    t.text     "body"
    t.text     "raw_data"
    t.string   "out_trade_no"
    t.string   "callback_url"
    t.string   "notify_url"
    t.string   "account_url"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "vip_user_payments", ["site_id"], :name => "index_vip_user_payments_on_site_id"
  add_index "vip_user_payments", ["user_id"], :name => "index_vip_user_payments_on_user_id"
  add_index "vip_user_payments", ["vip_user_id"], :name => "index_vip_user_payments_on_vip_user_id"

  create_table "vip_user_signs" do |t|
    t.integer  "site_id",                    :null => false
    t.integer  "vip_user_id",                :null => false
    t.date     "date",                       :null => false
    t.integer  "points",      :default => 0, :null => false
    t.datetime "created_at",                 :null => false
  end

  add_index "vip_user_signs", ["site_id"], :name => "index_vip_user_signs_on_site_id"
  add_index "vip_user_signs", ["vip_user_id"], :name => "index_vip_user_signs_on_vip_user_id"

  create_table "vip_user_transactions" do |t|
    t.integer  "site_id",                                                                         :null => false
    t.integer  "vip_user_id",                                                                     :null => false
    t.integer  "shop_branch_id"
    t.integer  "amount_source"
    t.integer  "direction",            :limit => 1,                                :default => 1, :null => false
    t.string   "direction_type",                                                                  :null => false
    t.integer  "payment_type",         :limit => 1
    t.decimal  "amount",                            :precision => 12, :scale => 2,                :null => false
    t.decimal  "total_amount",                      :precision => 12, :scale => 2,                :null => false
    t.decimal  "usable_amount",                     :precision => 12, :scale => 2,                :null => false
    t.integer  "transactionable_id"
    t.string   "transactionable_type"
    t.string   "order_no"
    t.text     "description"
    t.text     "meta"
    t.integer  "status",                                                           :default => 1, :null => false
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
  end

  add_index "vip_user_transactions", ["shop_branch_id"], :name => "index_vip_user_transactions_on_shop_branch_id"
  add_index "vip_user_transactions", ["site_id"], :name => "index_vip_user_transactions_on_site_id"
  add_index "vip_user_transactions", ["vip_user_id"], :name => "index_vip_user_transactions_on_vip_user_id"

  create_table "vip_users" do |t|
    t.integer  "site_id",                                                                           :null => false
    t.integer  "user_id",                                                                           :null => false
    t.integer  "vip_group_id"
    t.integer  "vip_grade_id",                                                   :default => 0
    t.boolean  "vip_grade_adjusted",                                             :default => false, :null => false
    t.integer  "succ_checkin_days",                                              :default => 0,     :null => false
    t.string   "user_no"
    t.string   "custom_user_no"
    t.string   "password_digest"
    t.string   "password_email"
    t.string   "trade_token"
    t.string   "name",                                                                              :null => false
    t.string   "mobile",                                                                            :null => false
    t.integer  "age",                                                            :default => 0,     :null => false
    t.integer  "gender",                                                         :default => 0,     :null => false
    t.date     "birthday"
    t.decimal  "total_amount",                    :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "usable_amount",                   :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "froze_amount",                    :precision => 12, :scale => 2, :default => 0.0,   :null => false
    t.integer  "total_points",                                                   :default => 0,     :null => false
    t.integer  "usable_points",                                                  :default => 0,     :null => false
    t.integer  "froze_points",                                                   :default => 0,     :null => false
    t.integer  "province_id",                                                    :default => 9
    t.integer  "city_id",                                                        :default => 73
    t.integer  "district_id",                                                    :default => 702
    t.string   "address"
    t.boolean  "is_sync",                                                        :default => false, :null => false
    t.integer  "status",             :limit => 1,                                :default => 1,     :null => false
    t.text     "description"
    t.text     "meta"
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
  end

  add_index "vip_users", ["city_id"], :name => "index_vip_users_on_city_id"
  add_index "vip_users", ["district_id"], :name => "index_vip_users_on_district_id"
  add_index "vip_users", ["gender"], :name => "index_vip_users_on_gender"
  add_index "vip_users", ["password_email"], :name => "index_vip_users_on_password_email"
  add_index "vip_users", ["province_id"], :name => "index_vip_users_on_province_id"
  add_index "vip_users", ["site_id"], :name => "index_vip_users_on_site_id"
  add_index "vip_users", ["status"], :name => "index_vip_users_on_status"
  add_index "vip_users", ["trade_token"], :name => "index_vip_users_on_trade_token"
  add_index "vip_users", ["user_id"], :name => "index_vip_users_on_user_id"
  add_index "vip_users", ["user_no"], :name => "index_vip_users_on_user_no"
  add_index "vip_users", ["vip_grade_id"], :name => "index_vip_users_on_vip_grade_id"
  add_index "vip_users", ["vip_group_id"], :name => "index_vip_users_on_vip_user_group_id"

  create_table "wave_participations" do |t|
    t.integer  "activity_id",                     :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "activity_user_id"
    t.integer  "value"
    t.integer  "used_quantity",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wbbs_communities" do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "logo"
    t.boolean  "need_check", :default => false
    t.integer  "view_count", :default => 0
    t.text     "metadata"
    t.integer  "status",     :default => 1,     :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "wbbs_communities", ["site_id"], :name => "index_wbbs_communities_on_site_id"

  create_table "wbbs_notifications" do |t|
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.string   "notifier_type"
    t.integer  "notifier_id"
    t.integer  "notice_type",        :default => 1
    t.string   "notifier_name"
    t.string   "notifier_avatar"
    t.text     "notifiable_content"
    t.text     "content"
    t.text     "metadata"
    t.integer  "status",             :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "wbbs_notifications", ["notifiable_id"], :name => "index_wbbs_notifications_on_notifiable_id"
  add_index "wbbs_notifications", ["notifier_id"], :name => "index_wbbs_notifications_on_notifier_id"

  create_table "wbbs_replies" do |t|
    t.integer  "wbbs_community_id",                :null => false
    t.integer  "wbbs_topic_id",                    :null => false
    t.integer  "parent_id"
    t.string   "replier_type"
    t.integer  "replier_id"
    t.string   "replier_name"
    t.string   "replier_avatar"
    t.text     "content"
    t.integer  "up_count",          :default => 0
    t.integer  "reports_count",     :default => 0
    t.integer  "status",            :default => 1, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "wbbs_replies", ["replier_id"], :name => "index_wbbs_replies_on_replier_id"
  add_index "wbbs_replies", ["wbbs_topic_id"], :name => "index_wbbs_replies_on_wbbs_topic_id"

  create_table "wbbs_topics" do |t|
    t.integer  "site_id",                                            :null => false
    t.integer  "wbbs_community_id",                                  :null => false
    t.string   "poster_type"
    t.integer  "poster_id"
    t.string   "receiver_type"
    t.string   "receiver_id"
    t.string   "poster_name"
    t.string   "poster_avatar"
    t.text     "content"
    t.integer  "wbbs_replies_count",              :default => 0
    t.integer  "reports_count",                   :default => 0
    t.boolean  "top",                             :default => false
    t.integer  "up_count",                        :default => 0,     :null => false
    t.integer  "view_count",                      :default => 0
    t.integer  "status",             :limit => 1, :default => 1,     :null => false
    t.text     "metadata"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "wbbs_topics", ["poster_id"], :name => "index_wbbs_topics_on_poster_id"
  add_index "wbbs_topics", ["site_id"], :name => "index_wbbs_topics_on_site_id"
  add_index "wbbs_topics", ["wbbs_community_id"], :name => "index_wbbs_topics_on_wbbs_community_id"

  create_table "wbbs_votables" do |t|
    t.string   "votable_type"
    t.integer  "votable_id"
    t.string   "voter_type"
    t.integer  "voter_id"
    t.integer  "vote_type",    :limit => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "wbbs_votables", ["votable_id"], :name => "index_wbbs_votables_on_votable_id"
  add_index "wbbs_votables", ["voter_id"], :name => "index_wbbs_votables_on_voter_id"

  create_table "website_article_categories" do |t|
    t.integer  "website_id"
    t.integer  "category_type",      :default => 1
    t.integer  "parent_id",          :default => 0
    t.string   "name"
    t.string   "pic_key"
    t.integer  "children_count",     :default => 0
    t.integer  "list_template_id",   :default => 1
    t.integer  "detail_template_id", :default => 1
    t.integer  "position",           :default => 1
    t.integer  "status",             :default => 1
    t.integer  "copy_id"
    t.integer  "copy_count",         :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "website_article_contents" do |t|
    t.integer  "website_article_id"
    t.text     "content",            :limit => 16777215
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "website_article_contents", ["website_article_id"], :name => "index_website_article_contents_on_website_article_id"

  create_table "website_articles" do |t|
    t.integer  "article_type",                              :default => 1
    t.integer  "site_id",                                                      :null => false
    t.integer  "website_id",                                                   :null => false
    t.integer  "website_menu_id"
    t.integer  "website_article_category_id"
    t.boolean  "is_recommend",                              :default => false, :null => false
    t.string   "title",                                                        :null => false
    t.integer  "subtitle_type",               :limit => 1,  :default => 1
    t.string   "subtitle"
    t.string   "pic_key"
    t.integer  "sort",                                      :default => 1,     :null => false
    t.boolean  "show_author",                               :default => false
    t.string   "author",                      :limit => 50
    t.string   "link"
    t.integer  "status",                      :limit => 1,  :default => 1
    t.integer  "copy_id"
    t.integer  "copy_count",                                :default => 0
    t.boolean  "is_top",                                    :default => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "website_articles", ["site_id"], :name => "index_website_articles_on_site_id"
  add_index "website_articles", ["sort"], :name => "index_website_articles_on_sort"
  add_index "website_articles", ["website_id"], :name => "index_website_articles_on_website_id"
  add_index "website_articles", ["website_menu_id"], :name => "index_website_articles_on_website_menu_id"

  create_table "website_comments" do |t|
    t.integer  "website_article_id",                :null => false
    t.string   "name"
    t.text     "content"
    t.integer  "status",             :default => 0, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "website_comments", ["website_article_id"], :name => "index_website_comments_on_website_article_id"

  create_table "website_menu_contents" do |t|
    t.integer  "website_menu_id"
    t.text     "content",         :limit => 16777215
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "website_menu_contents", ["website_menu_id"], :name => "index_on_website_menu_contents_website_menu_id", :unique => true

  create_table "website_menus" do |t|
    t.integer  "website_id",                                   :null => false
    t.integer  "parent_id",                    :default => 0,  :null => false
    t.integer  "children_count",               :default => 0
    t.integer  "sort",                         :default => 0,  :null => false
    t.integer  "sort_type",                    :default => 1
    t.string   "name",                                         :null => false
    t.string   "summary"
    t.integer  "summary_type",                 :default => 1
    t.integer  "menu_type",       :limit => 1, :default => 1,  :null => false
    t.integer  "menuable_id"
    t.string   "menuable_type"
    t.string   "url"
    t.string   "tel"
    t.string   "qq"
    t.string   "address"
    t.string   "location_x"
    t.string   "location_y"
    t.string   "font_icon"
    t.string   "icon_key"
    t.string   "pic_key"
    t.string   "cover_pic_key"
    t.string   "preview_pic_key",              :default => ""
    t.integer  "sort_style",                   :default => 1,  :null => false
    t.integer  "subtitle_type",                :default => 1
    t.string   "subtitle"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "website_menus", ["menuable_id", "menuable_type"], :name => "index_website_menu_menuable"
  add_index "website_menus", ["parent_id"], :name => "index_website_menus_on_parent_id"
  add_index "website_menus", ["sort"], :name => "index_website_menus_on_sort"
  add_index "website_menus", ["website_id"], :name => "index_website_menus_on_website_id"

  create_table "website_pictures" do |t|
    t.integer  "website_id"
    t.string   "pic_key"
    t.string   "title"
    t.string   "url"
    t.integer  "sort",             :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "menu_type"
    t.integer  "menuable_id"
    t.string   "menuable_type"
    t.string   "tel"
    t.string   "address"
    t.string   "location_x"
    t.string   "location_y"
    t.integer  "docking_type",     :default => 1
    t.integer  "docking_function", :default => 1
  end

  add_index "website_pictures", ["menuable_id", "menuable_type"], :name => "index_website_picture_menuable"
  add_index "website_pictures", ["sort"], :name => "index_website_pictures_on_sort"
  add_index "website_pictures", ["website_id"], :name => "index_website_pictures_on_website_id"

  create_table "website_popup_menus" do |t|
    t.integer  "website_id"
    t.integer  "parent_id",     :default => 0
    t.string   "name"
    t.string   "summary"
    t.integer  "sort",          :default => 0, :null => false
    t.integer  "menu_type",     :default => 1, :null => false
    t.integer  "menuable_id"
    t.string   "menuable_type"
    t.integer  "nav_type",      :default => 0, :null => false
    t.string   "pic_key"
    t.string   "icon_key"
    t.string   "font_icon"
    t.string   "tel"
    t.string   "url"
    t.string   "address"
    t.string   "location_x"
    t.string   "location_y"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "website_popup_menus", ["menuable_id", "menuable_type"], :name => "index_website_pop_menu_menuable"
  add_index "website_popup_menus", ["parent_id"], :name => "index_website_popup_menus_on_parent_id"
  add_index "website_popup_menus", ["sort"], :name => "index_website_popup_menus_on_sort"
  add_index "website_popup_menus", ["website_id"], :name => "index_website_popup_menus_on_website_id"

  create_table "website_settings" do |t|
    t.integer  "website_id",                                :null => false
    t.integer  "home_template_id"
    t.integer  "list_template_id"
    t.integer  "detail_template_id"
    t.integer  "index_nav_template_id", :default => 0,      :null => false
    t.integer  "nav_template_id"
    t.integer  "menu_template_id"
    t.boolean  "is_change_template",    :default => false
    t.string   "bg_music"
    t.string   "bg_pic_key"
    t.integer  "bg_pic_template_id"
    t.integer  "bg_animation_type",     :default => 0,      :null => false
    t.integer  "begin_animation_type",  :default => 0,      :null => false
    t.boolean  "open_nav",              :default => false,  :null => false
    t.boolean  "open_menu",             :default => false,  :null => false
    t.boolean  "open_bg_pic",           :default => false,  :null => false
    t.boolean  "open_bg_music",         :default => false,  :null => false
    t.boolean  "open_bg_animation",     :default => false,  :null => false
    t.boolean  "open_begin_animation",  :default => false,  :null => false
    t.text     "analytic_script"
    t.boolean  "is_wp_open_bottom",     :default => true
    t.string   "wp_bottom_color"
    t.integer  "wp_bottom_opacity"
    t.string   "wp_font_color"
    t.integer  "wp_font_opacity"
    t.string   "as_article_sort",       :default => "DESC"
    t.string   "as_product_sort",       :default => "ASC"
    t.boolean  "first_display",         :default => false
    t.string   "bg_music_qiniu_url"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "website_settings", ["detail_template_id"], :name => "index_website_settings_on_detail_templte_id"
  add_index "website_settings", ["home_template_id"], :name => "index_website_settings_on_home_template_id"
  add_index "website_settings", ["index_nav_template_id"], :name => "index_website_settings_on_index_nav_template_id"
  add_index "website_settings", ["list_template_id"], :name => "index_website_settings_on_list_template_id"
  add_index "website_settings", ["menu_template_id"], :name => "index_website_settings_on_menu_template_id"
  add_index "website_settings", ["nav_template_id"], :name => "index_website_settings_on_nav_template_id"
  add_index "website_settings", ["website_id"], :name => "index_website_settings_on_website_id"

  create_table "website_tags" do |t|
    t.string   "name",                        :null => false
    t.string   "sort",       :default => "1", :null => false
    t.datetime "created_at"
  end

  create_table "website_templates" do |t|
    t.string   "name",                                             :null => false
    t.integer  "template_type",                 :default => 1,     :null => false
    t.integer  "website_tag_id"
    t.integer  "style_index",                   :default => 1,     :null => false
    t.integer  "sort",                          :default => 1,     :null => false
    t.integer  "status",           :limit => 1, :default => 1,     :null => false
    t.string   "pic_key"
    t.text     "description"
    t.boolean  "support_bg_image",              :default => false
    t.boolean  "support_slide",                 :default => false
    t.boolean  "support_ws_logo",               :default => false
    t.boolean  "support_wm_pic",                :default => false
    t.boolean  "support_bg_music",              :default => false
    t.integer  "icon_shape",                    :default => 0
    t.integer  "scroll_way",                    :default => 0
    t.boolean  "is_boutique",                   :default => false
    t.integer  "series",                        :default => 0
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "website_templates", ["template_type", "style_index"], :name => "index_website_templates_on_template_type", :unique => true
  add_index "website_templates", ["website_tag_id"], :name => "index_website_templates_on_website_tag_id"

  create_table "websites" do |t|
    t.integer  "site_id",                                                       :null => false
    t.integer  "activity_id"
    t.string   "name",                                                          :null => false
    t.string   "tel"
    t.string   "domain"
    t.string   "logo_key"
    t.string   "qrcode_qiniu_key"
    t.boolean  "is_open_popup_menu",                         :default => false, :null => false
    t.boolean  "is_open_life_popup",                         :default => false, :null => false
    t.boolean  "is_open_business_circle_popup",              :default => true,  :null => false
    t.boolean  "is_open_cover_pic",                          :default => true,  :null => false
    t.integer  "template_id",                                :default => 1,     :null => false
    t.string   "home_cover_pic_key"
    t.string   "preview_pic_key",                            :default => ""
    t.integer  "website_type",                               :default => 1,     :null => false
    t.integer  "province_id",                                :default => 9,     :null => false
    t.integer  "city_id",                                    :default => 73,    :null => false
    t.integer  "district_id",                                :default => 702,   :null => false
    t.string   "address"
    t.integer  "status",                        :limit => 1, :default => 1,     :null => false
    t.integer  "website_menus_sort_type",                    :default => 1
    t.text     "baidu_app_js"
    t.text     "analytic_scripts"
    t.boolean  "attention_tips",                             :default => true
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "websites", ["activity_id"], :name => "index_websites_on_activity_id"
  add_index "websites", ["city_id"], :name => "index_websites_on_city_id"
  add_index "websites", ["district_id"], :name => "index_websites_on_district_id"
  add_index "websites", ["domain"], :name => "index_websites_on_domain"
  add_index "websites", ["province_id"], :name => "index_websites_on_province_id"
  add_index "websites", ["site_id"], :name => "index_websites_on_site_id"

  create_table "wedding_guests" do |t|
    t.integer  "wedding_id",                  :null => false
    t.integer  "user_id",                     :null => false
    t.string   "username",                    :null => false
    t.string   "phone"
    t.integer  "people_count", :default => 1, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "wedding_guests", ["phone"], :name => "index_wedding_guests_on_phone"
  add_index "wedding_guests", ["user_id"], :name => "index_wedding_guests_on_user_id"
  add_index "wedding_guests", ["username"], :name => "index_wedding_guests_on_username"
  add_index "wedding_guests", ["wedding_id"], :name => "index_wedding_guests_on_wedding_id"

  create_table "wedding_pictures" do |t|
    t.integer  "wedding_id",                    :null => false
    t.string   "name"
    t.string   "pic_key"
    t.boolean  "is_cover",   :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "wedding_pictures", ["wedding_id"], :name => "index_wedding_pictures_on_wedding_id"

  create_table "wedding_qr_codes" do |t|
    t.integer  "wedding_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "wedding_seats" do |t|
    t.integer  "wedding_id",                 :null => false
    t.string   "name",                       :null => false
    t.integer  "seats_count", :default => 1, :null => false
    t.string   "people",                     :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "wedding_seats", ["name"], :name => "index_wedding_seats_on_name"
  add_index "wedding_seats", ["wedding_id"], :name => "index_wedding_seats_on_wedding_id"

  create_table "wedding_wishes" do |t|
    t.integer  "wedding_id",                             :null => false
    t.string   "username",                               :null => false
    t.string   "mobile"
    t.integer  "gender",     :limit => 1, :default => 1, :null => false
    t.text     "content",                                :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "wedding_wishes", ["username"], :name => "index_wedding_wishes_on_username"
  add_index "wedding_wishes", ["wedding_id"], :name => "index_wedding_wishes_on_wedding_id"

  create_table "weddings" do |t|
    t.integer  "site_id",                                      :null => false
    t.integer  "template_id",                  :default => 1,  :null => false
    t.string   "groom",                                        :null => false
    t.string   "bride",                                        :null => false
    t.datetime "wedding_at",                                   :null => false
    t.string   "phone"
    t.string   "address",                                      :null => false
    t.string   "hotel_name"
    t.integer  "province_id",                  :default => 9,  :null => false
    t.integer  "city_id",                      :default => 73, :null => false
    t.integer  "district_id"
    t.string   "music_url"
    t.string   "video_url"
    t.string   "story_title",                                  :null => false
    t.text     "story_content",                                :null => false
    t.integer  "seats_status",    :limit => 1, :default => 1,  :null => false
    t.string   "music_file_name"
    t.boolean  "music_enabled"
    t.boolean  "phone_enable"
    t.text     "description"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "weddings", ["bride"], :name => "index_weddings_on_bride"
  add_index "weddings", ["city_id"], :name => "index_weddings_on_city_id"
  add_index "weddings", ["district_id"], :name => "index_weddings_on_district_id"
  add_index "weddings", ["groom"], :name => "index_weddings_on_groom"
  add_index "weddings", ["province_id"], :name => "index_weddings_on_province_id"
  add_index "weddings", ["site_id"], :name => "index_weddings_on_site_id"
  add_index "weddings", ["template_id"], :name => "index_weddings_on_template_id"
  add_index "weddings", ["wedding_at"], :name => "index_weddings_on_wedding_at"

  create_table "wifi_clients" do |t|
    t.integer  "site_id"
    t.boolean  "is_login_join"
    t.string   "ip_address"
    t.string   "mobile"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "wifi_clients", ["site_id"], :name => "index_wifi_clients_on_site_id"

  create_table "wifi_messages" do |t|
    t.integer  "msg_id"
    t.string   "param_pure"
    t.string   "param_des"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "wmall_activities" do |t|
    t.string   "name"
    t.string   "pic_key"
    t.text     "description"
    t.string   "pre_pic_url"
    t.integer  "mall_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "status"
    t.string   "sn"
    t.integer  "mark"
    t.boolean  "enabled"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "wmall_categories" do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "status"
    t.integer  "mall_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "wmall_comments" do |t|
    t.string   "commentable_type"
    t.string   "commentable_id"
    t.string   "nickname"
    t.text     "content"
    t.integer  "rank"
    t.decimal  "average_spend",    :precision => 12, :scale => 2
    t.integer  "created_by"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  create_table "wmall_coupon_logs" do |t|
    t.integer  "coupon_id"
    t.integer  "user_id"
    t.string   "sn"
    t.datetime "consumed_at"
    t.integer  "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "wmall_coupon_logs", ["coupon_id"], :name => "index_wmall_coupon_logs_on_coupon_id"
  add_index "wmall_coupon_logs", ["sn"], :name => "index_wmall_coupon_logs_on_sn"
  add_index "wmall_coupon_logs", ["status"], :name => "index_wmall_coupon_logs_on_status"
  add_index "wmall_coupon_logs", ["user_id"], :name => "index_wmall_coupon_logs_on_user_id"

  create_table "wmall_coupons" do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.decimal  "consume_amount",     :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "min_consume_amount", :precision => 12, :scale => 2, :default => 0.0
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "description"
    t.integer  "status"
    t.integer  "position",                                          :default => 0
    t.integer  "limit_max"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  add_index "wmall_coupons", ["shop_id"], :name => "index_wmall_coupons_on_shop_id"
  add_index "wmall_coupons", ["status"], :name => "index_wmall_coupons_on_status"

  create_table "wmall_malls" do |t|
    t.integer  "account_id"
    t.integer  "site_id"
    t.integer  "wx_mp_user_id"
    t.string   "wx_mp_user_open_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "wmall_navigations" do |t|
    t.integer  "mall_id"
    t.string   "name"
    t.string   "pic_key"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "wmall_pictures" do |t|
    t.string   "pic_key"
    t.integer  "pictureable_id"
    t.string   "pictureable_type"
    t.integer  "status",           :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "wmall_pictures", ["pictureable_id"], :name => "index_wmall_pictures_on_pictureable_id"
  add_index "wmall_pictures", ["pictureable_type"], :name => "index_wmall_pictures_on_pictureable_type"

  create_table "wmall_products" do |t|
    t.string   "name"
    t.string   "pic_key"
    t.string   "pre_pic_url"
    t.integer  "shop_id"
    t.decimal  "price",       :precision => 12, :scale => 2
    t.integer  "mall_id"
    t.text     "description"
    t.string   "sn"
    t.boolean  "enabled"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "wmall_qrcodes" do |t|
    t.integer  "mall_id"
    t.integer  "qrcodeable_id"
    t.string   "qrcodeable_type"
    t.string   "name"
    t.string   "expire_seconds"
    t.integer  "action_name",                    :null => false
    t.integer  "scene_id",                       :null => false
    t.string   "ticket",                         :null => false
    t.integer  "status",          :default => 1, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "wmall_qrcodes", ["scene_id"], :name => "index_wmall_qrcodes_on_scene_id"
  add_index "wmall_qrcodes", ["ticket"], :name => "index_wmall_qrcodes_on_ticket"

  create_table "wmall_shop_accounts" do |t|
    t.string   "name"
    t.string   "password_digest"
    t.boolean  "enabled"
    t.integer  "shop_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "wmall_shop_activities" do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.string   "sn"
    t.integer  "status"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "mark"
    t.text     "description"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "wmall_shop_cards" do |t|
    t.string   "pic_key"
    t.string   "name"
    t.boolean  "enabled"
    t.integer  "shop_id"
    t.string   "pre_pic_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "wmall_shop_pictures" do |t|
    t.string   "pic_key"
    t.integer  "shop_id"
    t.string   "name"
    t.string   "pre_pic_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "wmall_shops" do |t|
    t.string   "name"
    t.string   "pre_pic_url"
    t.string   "pic_key"
    t.integer  "site_id"
    t.integer  "mall_id"
    t.string   "phone"
    t.string   "card_pic_key"
    t.text     "description"
    t.text     "address"
    t.string   "sn"
    t.string   "subtitle"
    t.integer  "enable_vip_card"
    t.integer  "location_status"
    t.string   "location_address"
    t.float    "location_x"
    t.float    "location_y"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "wmall_slide_pictures" do |t|
    t.string   "pic_key"
    t.string   "pre_pic_url"
    t.integer  "mall_id"
    t.integer  "position"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "wx_cards" do |t|
    t.integer  "wx_mp_user_id"
    t.string   "card_id"
    t.string   "card_type"
    t.string   "logo_url"
    t.string   "code_type"
    t.string   "brand_name"
    t.string   "title"
    t.string   "sub_title"
    t.string   "color"
    t.string   "notice"
    t.string   "service_phone"
    t.string   "source"
    t.text     "description"
    t.integer  "date_info_type",                             :default => 1
    t.datetime "date_info_start_at"
    t.datetime "date_info_end_at"
    t.integer  "date_info_fixed_term"
    t.integer  "date_info_fixed_begin_term"
    t.integer  "sku_quantity"
    t.integer  "use_limit"
    t.integer  "get_limit"
    t.boolean  "use_custom_code",                            :default => false
    t.boolean  "bind_openid",                                :default => false
    t.boolean  "can_share",                                  :default => true
    t.boolean  "can_give_friend",                            :default => true
    t.string   "location_id_list"
    t.string   "url_name_type"
    t.string   "custom_url"
    t.text     "general_coupon_default_detail"
    t.text     "groupon_deal_detail"
    t.string   "gift_gift"
    t.integer  "cash_least_cost"
    t.integer  "cash_reduce_cost"
    t.integer  "discount_discount"
    t.boolean  "member_card_supply_bonus",                   :default => false
    t.boolean  "member_card_supply_balance",                 :default => false
    t.text     "member_card_bonus_cleared"
    t.text     "member_card_bonus_rules"
    t.text     "member_card_balance_rules"
    t.text     "member_card_prerogative"
    t.string   "member_card_bind_old_card_url"
    t.string   "member_card_activate_url"
    t.string   "scenic_ticket_ticket_class"
    t.string   "scenic_ticket_gopenide_url"
    t.text     "movie_ticket_detail"
    t.string   "boarding_pass_from"
    t.string   "boarding_pass_to"
    t.string   "boarding_pass_flight"
    t.string   "boarding_pass_departure_time"
    t.string   "boarding_pass_landing_time"
    t.string   "boarding_pass_check_in_url"
    t.string   "boarding_pass_gate"
    t.string   "boarding_pass_boarding_time"
    t.string   "boarding_pass_air_model"
    t.integer  "status",                        :limit => 1, :default => 0,     :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "wx_cards", ["card_id"], :name => "index_wx_cards_on_card_id"
  add_index "wx_cards", ["wx_mp_user_id"], :name => "index_wx_cards_on_wx_mp_user_id"

  create_table "wx_feedbacks" do |t|
    t.integer  "wx_mp_user_id",               :null => false
    t.integer  "wx_user_id",                  :null => false
    t.string   "feed_back_id",                :null => false
    t.string   "trans_id",                    :null => false
    t.integer  "msg_type"
    t.text     "reason"
    t.text     "solution"
    t.text     "ext_info"
    t.text     "pic_info"
    t.integer  "status",       :default => 0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "wx_feedbacks", ["feed_back_id"], :name => "index_wx_feedbacks_on_feed_back_id"
  add_index "wx_feedbacks", ["trans_id"], :name => "index_wx_feedbacks_on_trans_id"
  add_index "wx_feedbacks", ["wx_user_id"], :name => "index_wx_feedbacks_on_wx_user_id"

  create_table "wx_invites" do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.integer  "wx_invitable_id"
    t.string   "wx_invitable_type"
    t.boolean  "is_recommend",      :default => false
    t.boolean  "is_recommended",    :default => false
    t.integer  "wx_participate_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "wx_invites", ["from_user_id", "to_user_id", "wx_invitable_id", "wx_invitable_type"], :name => "index_uniq_for_wx_invites", :unique => true

  create_table "wx_menus" do |t|
    t.integer  "wx_mp_user_id",                      :null => false
    t.integer  "parent_id",     :default => 0,       :null => false
    t.integer  "sort",          :default => 0,       :null => false
    t.string   "name"
    t.string   "key"
    t.string   "url"
    t.string   "event_type",    :default => "click", :null => false
    t.integer  "menu_type",     :default => "1",     :null => false
    t.integer  "menuable_id"
    t.string   "menuable_type"
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "wx_menus", ["key"], :name => "index_wx_menus_on_key"
  add_index "wx_menus", ["menuable_id", "menuable_type"], :name => "menuable_index"
  add_index "wx_menus", ["parent_id"], :name => "index_wx_menus_on_parent_id"
  add_index "wx_menus", ["sort"], :name => "index_wx_menus_on_sort"
  add_index "wx_menus", ["wx_mp_user_id"], :name => "index_wx_menus_on_wx_mp_user_id"

  create_table "wx_mp_users" do |t|
    t.integer  "account_id"
    t.integer  "site_id",                                                 :null => false
    t.integer  "status",                :limit => 1,   :default => 0,     :null => false
    t.string   "nickname",                                                :null => false
    t.string   "openid"
    t.string   "app_id"
    t.string   "app_secret"
    t.string   "token"
    t.string   "url"
    t.string   "code"
    t.string   "head_img"
    t.string   "alias"
    t.string   "qrcode_key"
    t.string   "qrcode_url"
    t.integer  "user_type",             :limit => 1,   :default => 0,     :null => false
    t.integer  "bind_type",                            :default => 1
    t.boolean  "is_sync",                              :default => false, :null => false
    t.boolean  "is_oauth",                             :default => false, :null => false
    t.datetime "expires_in"
    t.string   "access_token",          :limit => 512
    t.string   "wx_jsapi_ticket"
    t.datetime "wx_jsapi_expires_in"
    t.string   "auth_code"
    t.string   "refresh_token"
    t.integer  "encrypt_mode",          :limit => 1,   :default => 0
    t.string   "encoding_aes_key",                     :default => ""
    t.string   "last_encoding_aes_key",                :default => ""
    t.string   "username"
    t.string   "password"
    t.text     "func_info"
    t.text     "metatada"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "wx_mp_users", ["account_id"], :name => "index_wx_mp_users_on_account_id"
  add_index "wx_mp_users", ["code"], :name => "index_wx_mp_users_on_code"
  add_index "wx_mp_users", ["openid"], :name => "index_wx_mp_users_on_openid"
  add_index "wx_mp_users", ["site_id"], :name => "index_wx_mp_users_on_site_id"

  create_table "wx_participates" do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "prize_status", :default => -2
    t.integer  "status",       :default => 0
    t.string   "prize_title"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "wx_plot_bulletins" do |t|
    t.integer  "wx_plot_id",                   :null => false
    t.string   "title",                        :null => false
    t.string   "summary"
    t.string   "subtitle"
    t.integer  "subtitle_type", :default => 1
    t.string   "pic_key"
    t.string   "font_icon"
    t.text     "content"
    t.integer  "status",        :default => 0, :null => false
    t.datetime "done_date_at"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "wx_plot_bulletins", ["wx_plot_id"], :name => "index_wx_plot_bulletins_on_wx_plot_id"

  create_table "wx_plot_categories" do |t|
    t.integer  "wx_plot_id",                :null => false
    t.string   "name",                      :null => false
    t.integer  "sort"
    t.integer  "category",   :default => 1, :null => false
    t.integer  "status",     :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "wx_plot_categories", ["category"], :name => "index_wx_plot_categories_on_category"
  add_index "wx_plot_categories", ["sort"], :name => "index_wx_plot_categories_on_sort"
  add_index "wx_plot_categories", ["wx_plot_id"], :name => "index_wx_plot_categories_on_wx_plot_id"

  create_table "wx_plot_lives" do |t|
    t.integer  "wx_plot_id",                         :null => false
    t.integer  "wx_plot_category_id",                :null => false
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.text     "content"
    t.integer  "sort"
    t.integer  "status",              :default => 0, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "wx_plot_lives", ["wx_plot_category_id"], :name => "index_wx_plot_lives_on_wx_plot_category_id"
  add_index "wx_plot_lives", ["wx_plot_id"], :name => "index_wx_plot_lives_on_wx_plot_id"

  create_table "wx_plot_repair_complain_messages" do |t|
    t.integer  "wx_plot_repair_complain_id", :null => false
    t.integer  "messageable_id"
    t.string   "messageable_type"
    t.text     "content"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "wx_plot_repair_complain_messages", ["wx_plot_repair_complain_id"], :name => "index_repair_complain_messages_on_repair_complain_id"

  create_table "wx_plot_repair_complain_statuses" do |t|
    t.integer  "wx_plot_repair_complain_id",                :null => false
    t.integer  "status",                     :default => 0, :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "wx_plot_repair_complain_statuses", ["wx_plot_repair_complain_id"], :name => "index_repair_complain_statuses_on_repair_complain_id"

  create_table "wx_plot_repair_complains" do |t|
    t.integer  "wx_plot_id",                         :null => false
    t.integer  "wx_plot_category_id",                :null => false
    t.integer  "user_id",                            :null => false
    t.string   "nickname",                           :null => false
    t.integer  "gender",              :default => 1, :null => false
    t.string   "phone"
    t.string   "room_no"
    t.text     "content"
    t.text     "reply_content"
    t.integer  "category",            :default => 1, :null => false
    t.integer  "status",              :default => 0, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "wx_plot_repair_complains", ["category"], :name => "index_wx_plot_repair_complains_on_category"
  add_index "wx_plot_repair_complains", ["status"], :name => "index_wx_plot_repair_complains_on_status"
  add_index "wx_plot_repair_complains", ["user_id"], :name => "index_wx_plot_repair_complains_on_user_id"
  add_index "wx_plot_repair_complains", ["wx_plot_category_id"], :name => "index_wx_plot_repair_complains_on_wx_plot_category_id"
  add_index "wx_plot_repair_complains", ["wx_plot_id"], :name => "index_wx_plot_repair_complains_on_wx_plot_id"

  create_table "wx_plot_sms_settings" do |t|
    t.integer  "wx_plot_id",          :null => false
    t.integer  "wx_plot_category_id", :null => false
    t.string   "phone"
    t.string   "start_at"
    t.string   "end_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "wx_plot_sms_settings", ["wx_plot_category_id"], :name => "index_wx_plot_sms_settings_on_wx_plot_category_id"
  add_index "wx_plot_sms_settings", ["wx_plot_id"], :name => "index_wx_plot_sms_settings_on_wx_plot_id"

  create_table "wx_plot_telephones" do |t|
    t.integer  "wx_plot_id",                         :null => false
    t.integer  "wx_plot_category_id",                :null => false
    t.string   "name"
    t.string   "phone"
    t.integer  "sort"
    t.integer  "status",              :default => 0, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "wx_plot_telephones", ["wx_plot_category_id"], :name => "index_wx_plot_telephones_on_wx_plot_category_id"
  add_index "wx_plot_telephones", ["wx_plot_id"], :name => "index_wx_plot_telephones_on_wx_plot_id"

  create_table "wx_plots" do |t|
    t.integer  "site_id",                                  :null => false
    t.string   "name",                                     :null => false
    t.string   "bulletin",             :default => "小区公告"
    t.string   "repair",               :default => "报修管理"
    t.string   "complain",             :default => "投诉建议"
    t.string   "telephone",            :default => "常用电话"
    t.string   "owner",                :default => "业主中心"
    t.string   "life",                 :default => "周边生活"
    t.string   "cover_pic"
    t.string   "repair_phone"
    t.string   "complain_phone"
    t.boolean  "is_open_complain_sms", :default => false
    t.boolean  "is_open_repair_sms",   :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "wx_plots", ["site_id"], :name => "index_wx_plots_on_site_id"

  create_table "wx_prizes" do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "prize_id"
    t.string   "prize_type"
    t.string   "prize_name"
    t.integer  "status",      :limit => 1, :default => 0
    t.string   "name"
    t.string   "mobile"
    t.integer  "consume_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "wx_request_hits" do |t|
    t.integer  "wx_mp_user_id"
    t.date     "date"
    t.string   "smg_type"
    t.string   "content"
    t.integer  "hit_count",   :default => 0, :null => false
    t.boolean  "is_hit",      :default => 1, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "wx_request_hits", ["date", "wx_mp_user_id"], :name => "uni_wx_request_hits_on_date_wx_mp_user_id", :unique => true
  add_index "wx_request_hits", ["wx_mp_user_id"], :name => "index_wx_request_hits_on_wx_mp_user_id"

  create_table "wx_requests", :force => true do |t|
    t.integer  "wx_mp_user_id"
    t.date     "date"
    t.integer  "text",                                            :default => 0,   :null => false
    t.integer  "text_hit",                                        :default => 0,   :null => false
    t.integer  "event",                                           :default => 0,   :null => false
    t.integer  "image",                                           :default => 0,   :null => false
    t.integer  "voice",                                           :default => 0,   :null => false
    t.integer  "video",                                           :default => 0,   :null => false
    t.integer  "shortvideo",                                      :default => 0
    t.integer  "location",                                        :default => 0,   :null => false
    t.integer  "link",                                            :default => 0,   :null => false
    t.integer  "total",                                           :default => 0,   :null => false
    t.integer  "subscribe",                                       :default => 0,   :null => false
    t.integer  "unsubscribe",                                     :default => 0,   :null => false
    t.integer  "increase",                                        :default => 0,   :null => false
    t.integer  "message_users",                                   :default => 0
    t.integer  "message_nums",                                    :default => 0
    t.decimal  "message_user_mean", :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "keyword_per",       :precision => 5, :scale => 2, :default => 0.0
    t.datetime "updated_at"
  end

  add_index "wx_requests", ["date", "wx_mp_user_id"], :name => "uni_date_wx_mp_user_id", :unique => true
  add_index "wx_requests", ["wx_mp_user_id"], :name => "index_wx_requests_on_wx_mp_user_id"
  add_index "wx_requests", ["total"], :name => "index_wx_requests_on_total"

  create_table "shake_prizes" do |t|
    t.integer  "site_id",                                       :null => false
    t.integer  "user_id",                                       :null => false
    t.integer  "shake_id",                                   :null => false
    t.integer  "shake_user_id",                              :null => false
    t.integer  "shake_round_id",                             :null => false
    t.integer  "user_rank"
    t.string   "sn_code"
    t.integer  "status",            :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "shake_prizes", ["site_id"], :name => "index_shake_prizes_on_site_id"
  add_index "shake_prizes", ["user_id"], :name => "index_shake_prizes_on_user_id"
  add_index "shake_prizes", ["shake_id"], :name => "index_shake_prizes_on_shake_id"
  add_index "shake_prizes", ["shake_user_id", "shake_round_id"], :name => "index_shake_prizes_on_shake_user_id_and_shake_round_id", :unique => true

  create_table "shake_rounds" do |t|
    t.integer  "site_id",                                    :null => false
    t.integer  "activity_id",                                :null => false
    t.integer  "shake_id",                                :null => false
    t.integer  "shake_round"
    t.integer  "shake_user_num"
    t.integer  "status",         :limit => 1, :default => 0, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "shake_rounds", ["activity_id"], :name => "index_shake_rounds_on_activity_id"
  add_index "shake_rounds", ["site_id"], :name => "index_shake_rounds_on_site_id"
  add_index "shake_rounds", ["shake_id"], :name => "index_shake_rounds_on_shake_id"

  create_table "shake_users" do |t|
    t.integer  "site_id",                                 :null => false
    t.integer  "user_id",                                 :null => false
    t.integer  "shake_id",                             :null => false
    t.string   "nickname"
    t.string   "avatar"
    t.string   "mobile"
    t.datetime "matched_at"
    t.integer  "status",      :limit => 1, :default => 1, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "shake_users", ["site_id"], :name => "index_shake_users_on_site_id"
  add_index "shake_users", ["user_id"], :name => "index_shake_users_on_user_id"
  add_index "shake_users", ["shake_id"], :name => "index_shake_users_on_shake_id"

  create_table "shakes" do |t|
    t.integer  "site_id",                                       :null => false
    t.integer  "material_id"
    t.integer  "mode",                        :default => 1
    t.integer  "mode_value"
    t.integer  "countdown"
    t.integer  "prize_user_num"
    t.string   "logo_key"
    t.integer  "template_id",                 :default => 1
    t.boolean  "mobile_check",                :default => true
    t.integer  "status",         :limit => 1, :default => 1,    :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "shakes", ["site_id"], :name => "index_shakes_on_site_id"

  create_table "wx_user_addresses" do |t|
    t.integer  "user_id",                                     :null => false
    t.integer  "wx_user_id",                                  :null => false
    t.string   "username",                                    :null => false
    t.string   "tel"
    t.integer  "province_id",              :default => 9,     :null => false
    t.integer  "city_id",                  :default => 73,    :null => false
    t.integer  "district_id"
    t.string   "address"
    t.string   "zipcode"
    t.boolean  "is_default",               :default => false, :null => false
    t.integer  "status",      :limit => 1, :default => 0,     :null => false
    t.text     "description"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "wx_user_addresses", ["city_id"], :name => "index_wx_user_addresses_on_city_id"
  add_index "wx_user_addresses", ["district_id"], :name => "index_wx_user_addresses_on_district_id"
  add_index "wx_user_addresses", ["province_id"], :name => "index_wx_user_addresses_on_province_id"
  add_index "wx_user_addresses", ["user_id"], :name => "index_wx_user_addresses_on_user_id"
  add_index "wx_user_addresses", ["wx_user_id"], :name => "index_wx_user_addresses_on_wx_user_id"

  create_table "wx_users" do |t|
    t.integer  "wx_mp_user_id"
    t.integer  "user_id"
    t.integer  "status",                  :default => 1,     :null => false
    t.string   "openid",                                     :null => false
    t.string   "nickname"
    t.integer  "subscribe"
    t.integer  "sex",                     :default => 0
    t.string   "language"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "headimgurl"
    t.datetime "subscribe_time"
    t.string   "unionid"
    t.string   "remark"
    t.integer  "groupid", :default => 0, :null => false
    t.string   "location_x"
    t.string   "location_y"
    t.string   "location_label"
    t.datetime "location_updated_at"
    t.boolean  "leave_message_forbidden",              :default => false
    t.boolean  "is_show_product_pic",                  :default => true
    t.integer  "match_type",                           :default => 1,     :null => false
    t.datetime "match_at"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "wx_users", ["nickname"], :name => "index_wx_users_on_nickname"
  add_index "wx_users", ["openid"], :name => "index_wx_users_on_openid"
  add_index "wx_users", ["user_id"], :name => "index_wx_users_on_user_id"
  add_index "wx_users", ["wx_mp_user_id"], :name => "index_wx_users_on_wx_mp_user_id"

  create_table "wx_wall_messages" do |t|
    t.integer  "wx_wall_id"
    t.integer  "wx_wall_user_id"
    t.string   "msg_type"
    t.text     "message"
    t.string   "pic_key"
    t.integer  "status",          :default => 1
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "wx_wall_messages", ["wx_wall_id"], :name => "index_wx_wall_messages_on_wx_wall_id"
  add_index "wx_wall_messages", ["wx_wall_user_id"], :name => "index_wx_wall_messages_on_wx_wall_user_id"

  create_table "wx_wall_prizes" do |t|
    t.integer  "wx_wall_id"
    t.string   "grade"
    t.string   "name"
    t.string   "pic_key"
    t.integer  "sort",       :default => 1
    t.integer  "num"
    t.integer  "status",     :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "wx_wall_prizes", ["wx_wall_id"], :name => "index_wx_wall_prizes_on_wx_wall_id"

  create_table "wx_wall_prizes_wx_wall_users" do |t|
    t.integer  "wx_wall_id"
    t.integer  "wx_wall_user_id"
    t.integer  "wx_wall_prize_id"
    t.string   "prize_grade"
    t.string   "prize_name"
    t.string   "prize_pic"
    t.string   "nickname"
    t.string   "avatar"
    t.string   "sn_code"
    t.integer  "status",           :default => 1
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "wx_wall_prizes_wx_wall_users", ["wx_wall_id"], :name => "index_wx_wall_prizes_wx_wall_users_on_wx_wall_id"
  add_index "wx_wall_prizes_wx_wall_users", ["wx_wall_prize_id"], :name => "index_wx_wall_prizes_wx_wall_users_on_wx_wall_prize_id"
  add_index "wx_wall_prizes_wx_wall_users", ["wx_wall_user_id"], :name => "index_wx_wall_prizes_wx_wall_users_on_wx_wall_user_id"

  create_table "wx_wall_users" do |t|
    t.integer  "user_id",                                  :null => false
    t.integer  "wx_wall_id",                               :null => false
    t.string   "nickname"
    t.string   "avatar"
    t.datetime "matched_at"
    t.integer  "matched_mode", :limit => 1, :default => 1
    t.text     "metadata"
    t.integer  "status",                    :default => 1
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "wx_wall_users", ["user_id"], :name => "index_wx_wall_users_on_user_id"
  add_index "wx_wall_users", ["wx_wall_id"], :name => "index_wx_wall_users_on_wx_wall_id"

  create_table "wx_wall_winning_users" do |t|
    t.integer  "wx_wall_id",                :null => false
    t.integer  "user_id",                   :null => false
    t.text     "metadata"
    t.integer  "status",     :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "wx_wall_winning_users", ["status"], :name => "index_wx_wall_winning_users_on_status"
  add_index "wx_wall_winning_users", ["user_id"], :name => "index_wx_wall_winning_users_on_user_id"
  add_index "wx_wall_winning_users", ["wx_wall_id"], :name => "index_wx_wall_winning_users_on_wx_wall_id"

  create_table "wx_walls" do |t|
    t.integer  "site_id",                            :null => false
    t.string   "sponsor"
    t.string   "logo"
    t.string   "qrcode"
    t.boolean  "system_template", :default => true
    t.string   "template_id"
    t.string   "custom_template"
    t.integer  "material_id"
    t.boolean  "pre_join",        :default => true
    t.boolean  "verify_message",  :default => false
    t.boolean  "scroll_message",  :default => false
    t.boolean  "repeat_draw",     :default => false
    t.string   "award_keyword"
    t.string   "password"
    t.text     "metadata"
    t.integer  "status",          :default => 1
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "wx_walls", ["site_id"], :name => "index_wx_walls_on_site_id"

end

Wp::Application.routes.draw do

  scope module: 'biz' do

    resources :unfolds do
      get :consumes, :chart, on: :collection
      get :settings, :find_consume, on: :member
      post :use_consume, on: :member
    end

    resources :recommends do
      get :consumes, :chart, on: :collection
      get :settings, :find_consume, on: :member
      post :use_consume, on: :member
    end

    resources :group_categories do
      match :move_lower, :move_higher, on: :member
    end
    resources :group_items
    resources :groups do
      collection do
        match :alipay, via: [:get, :put]
        get :categories, :items, :orders
      end
    end
    resources :group_orders do
      post :consume, on: :member
    end

    resources :albums do
      get  :comments, :activity, on: :collection
      delete :destroy_comment, on: :collection
      get  :delete_photo, on: :member
      post :create_activity, on: :collection
      put  :update_activity, on: :collection
      resources :album_photos, as: :photos
      post :sort, :visible, on: :member
    end

    resources :slots do
      get :edit_start_settings, :edit_rule_settings, :edit_prize_settings, on: :member
      post :setted, on: :member
    end

    resources :waves do
      member do
        get :edit_prize_settings, :edit_rule_settings
      end
    end

    resources :reservations do
      member do
        get :intro
        post :start, :stop
      end
      collection do
        get  :fields, :orders
        post :remove_logo
      end
    end

    resources :reservation_orders do
      post :done, :cancel, on: :member
    end

    resources :donations do
      resources :donation_orders do
        post :pay, on: :member
        post :unpay, on: :member
      end

      get   :activity, :list_activities, :orders, on: :collection
      post  :start, :stop, on: :member
      match :update_activity, :edit_activity, on: :collection
    end

    resources :wbbs_communities
    resources :scene_pages do
      collection do
        get :pages_config
        post :save_html
        post :save_json
      end
    end
    resources :scenes do
      member do
        get :pages
        get :qrcode
      end
    end
    resources :wbbs_topics do
      member do
        post :stickie, :normal
        post :forbid_user, :cancel_forbid_user
      end
      get :removed, :forbidden_users, :normal_users, on: :collection
    end

    resources :coupons do
      collection do
        get  :edit_activity, :reports, :consumes, :use_consume, :find_consume, :offline_consumes
        post :confirm_use_consume
      end

      post :start, :stop, :move_up, :move_down, on: :member
    end

    resources :govmails do
      collection do
        get :conditions
      end
      member do
        post :remove, :reply, :archive
        get :author_modal, :reply_modal
      end
    end

    resources :govmailboxes do
      member do
        post :remove
        get :mails, :edit_modal
      end
    end

    resources :govchats do
      collection do
        get :conditions, :reports, :complaints, :advises, :edit_modal
        post :update_activity_basecount
      end
      member do
        post :remove, :reply, :archive
        get :author_modal, :reply_modal
      end
    end

    resources :custom_fields do
      member do
        post :toggle_is_required, :toggle_editable,  :toggle_visible, :toggle_captcha_required, :move_up, :move_down
      end
      post :remove_option, on: :collection
    end

    resources :album_photos do
      post :upload, :save_qiniu_keys, on: :collection
      get :is_cover, on: :member
    end

    resources :greets do
      get  :activity, on: :collection
      post :create_activity, on: :collection
      put  :update_activity, on: :collection
    end

    resources :greet_cards do
      post :hidden, :view, on: :member
      get :help, on: :collection
      post :set_recommand_pic, on: :collection
    end

    resources :websites do
      member do
        post :clear, :open_popup_menu, :close_popup_menu
        delete :delete_home_cover_pic
      end
      collection do
        get  :help, :qrcode, :domain, :download, :pictures, :create_initial_data, :menus_sort
        post :custom_domain
      end
    end
    resources :website_popup_menus do
      get :copy, on: :collection
      post :update_menu_sort, on: :collection
    end

    resources :website_pictures do
      get :find_activities, :find_good, :select_ec_category, on: :collection
    end

    resources :website_settings do
      get :website_templates, on: :collection
      post :set_template_id, on: :collection
      get :bg_pic, on: :collection
      post :update_bg_pic, on: :collection
      get :navs,  on: :collection
      post :update_update_nav_template, :change_article_sort, on: :collection
    end

    resources :website_menus do
      get :update_sorts, :sort, :sub_menu, on: :member
      get :find_activities, :find_good, :select_ec_category, on: :collection
    end


    resources :website_article_categories do
      get :update_sorts, :copy, on: :member
    end

    resources :website_article_category_tags do
      get :update_sorts, :copy, on: :member
    end

    resources :website_articles do
      collection do
        get :copy_article, :select_categorie, :change_status, :copy_article, :delete_articles, :edit_pic, :delete_pic, :change_is_top
        post :update_sort, :update_pic
      end
    end

    resources :vip_privileges do
      get :stop, on: :member
    end

    resources :vip_groups do
      collection do
        post :remove_user_group_id, :change_group, :add_to_group, :search_user, :search_custom_value
        get :search_grade
      end
    end

    resources :vip_cares
    resources :vip_users do
      member do
        post :freeze, :normal, :deny, :delete, :pass, :save_point, :save_money, :save_grade
        get  :info, :transactions, :set_point, :money, :set_money, :set_grade, :transaction_check
        put  :award
      end
      get :pending, :freezed, :rejected, :deleted, :inactive, on: :collection
    end

    resources :vip_cards do
      resources :vip_privileges
      post :set_is_open_points, :change_cover_pic, :template, :end_introduce, :toggle_vip_importing, :toggle_label_custom_field, :toggle_use_vip_avatar, on: :collection
      get  :settings, :conditions, :template, :help, :marketing, on: :collection
      post :stop, :start, :remove_logo, on: :member
    end

    resources :vip_transactions do
      get :forget_password, :check_password, :check_protection, :back_password, on: :collection
      post :sub_forget_password, on: :collection
    end

    resources :vip_statistics, only: :index do
      get :show_chart, on: :collection
    end

    resources :vip_records, only: :index do
      get :point, :trend, on: :collection
    end

    resources :vip_grades do
      get :stop, on: :member
    end

    resources :point_types do
      get :edit_status, on: :member
    end

    resources :point_gifts do
      get :get_shop, on: :collection
      get :gift_exchange, :use_gift, :exchange_info, on: :member
      post :update_consumes, on: :member
    end

    resources :vip_packages do
      get :release, :find_vip_user, :use_package, :find_vip_package_item, :package_users, :item_consumes, :use_usable_amount, on: :collection
      post :save_release, :update_consumes, on: :collection
    end
    resources :vip_package_items

    resources :point_gift_exchanges, only: :index
    resources :vip_message_plans

    resources :vip_api_settings, only: [:index, :update] do
      collection do
        get :spec, :vip_fields_spec
        post :toggle_status
      end
    end
    resources :vip_external_http_apis, except: :show
    resources :vip_importings, only: [:index, :create, :destroy, :edit, :update] do
      post :import, on: :collection
    end

    resources :micro_shops do
      resources :micro_shop_branches
    end

    resources :micro_shop_branches do
      get :permissions, :new_permission, on: :collection
      match :permission, via: [:get, :post], on: :collection
      resources :shop_images
      member do
        post :create_pic, :toggle_sub_account
        get :highchart, :pictures, :del_picture
      end
    end
    match 'location_img/:id/img.png' => 'micro_shop_branches#location_img'

    namespace :shops do
      scope path: ':supplier_id' do
        match :sign_in, via: [ :get, :post ]
        get :index, :sign_out, :vip_deals, :point_gift_exchanges, :vip_consumes, :highchart, :find_vip_user, :exchange_info, :transaction_check, :package_users, :item_consumes, :find_vip_package_item, :find_consume, :consume_reports, :activity_consumes, :use_consume, :find_activities, :use_usable_amount
        post :save_point, :save_money, :save_release, :update_consumes, :use_consume, :use_exchange
      end
    end

    resources :activity_enrolls

    resources :activity_forms do
      post :edit_audited, :edit_fields_save, :checked_fields_save, on: :collection
      get :edit_fields, :checked_field, on: :collection
    end

    resources :share_photo_settings do
      collection do
        get :help, :tag, :my_setting, :photo
        put :update_activity
      end
    end
    resources :share_photos do
      resources :share_photo_comments
    end

    resources :wmall_groups
    resources :wmall_group_items do
      get :recommend_switch, on: :member
      get :recommend_list, on: :collection
    end
    resources :wmall_group_orders do
      post :consume, on: :member
      get :sn_consume, on: :member
      get  :list, :sn, :bill, on: :collection
    end

    resources :aids do
      member do
        get :edit_rule_settings, :edit_prize_settings
        post :setted
      end
    end

    resources :red_packets do
        get :settings, :set_value, :export, :payment_setting_new,  on: :collection
        post :off_or_on, :payment_setting, :test_pay, on: :collection
        post :update_follow_packet
    end
  end
end

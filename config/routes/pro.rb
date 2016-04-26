Wp::Application.routes.draw do

  namespace :pro do

    # wmall
    namespace :wmall do
      resources :malls
      resources :shops
      resources :products
      resources :shop_accounts
      resources :activities
      resources :slide_pictures
    end

    resources :website_popup_menus, :website_pictures, :website_assistants
    resources :websites do
      get :address, on: :collection
      post :clear, :toggle_popup, on: :member
    end

    resources :website_menus do
      post :reorder, on: :member
    end

    resources :website_articles do
      post :toggle_recommend, on: :member
    end
  end

  scope module: 'pro' do

    resources :hospitals, :hospital_job_titles, :doctor_arranges

    resources :doctor_watches do
      post :stop, on: :member
      post :start, on: :member
    end

    resources :hospital_departments do
      get :doctors, on: :member
    end

    resources :hospital_doctors do
      post :toggle, on: :member
    end

    resources :ktv_orders do
      post :toggle_status, on: :member
      get  :orders, on: :collection
    end

    resources :hospital_orders do
      post :cancele, :complete, on: :member
      get  :history, on: :collection
    end

    resources :bookings do
      resources :booking_categories, as: :categories do
        get :update_sorts, on: :member
      end
      resources :booking_ads,    as: :ads
      resources :booking_items,  as: :items
      resources :booking_orders, as: :orders do
        post :complete, :cancele, on: :member
      end
    end

    # resources :business do
    #   member do
    #     post :clear
    #     post :open_life_popup
    #     post :close_life_popup
    #   end
    # end

    # resources :business do
    #   get :address, on: :collection
    #   post :clear, :toggle_popup, on: :member
    # end

    # resources :busine_popup_menus, :busine_pictures, :busine_assistants
    # resources :busine_menus do
    #   post :reorder, on: :member
    # end
    # resources :busine_articles do
    #   post :toggle_recommend, on: :member
    # end

    # resources :business_shops do
    #   collection do
    #     get    :comments
    #     delete :destroy_comment
    #     get :set_template
    #     post :set_template
    #   end
    #   member do
    #     post :open_function
    #     post :toggle_vip_card
    #     get  :vip_card_branch
    #     put  :update_vip_card_branch
    #     get  :business_shop_admin
    #     put  :update_business_shop_admin
    #     get  :group_activities
    #     post  :update_group_activities
    #     delete  :delete_group_activities
    #   end
    #   resources :business_privileges, :business_items
    #   resources :business_shop_pictures, only: [:index, :destroy, :create]
    # end

    # resources :ec_shops    do
    #   collection do
    #     get :navigation
    #   end
    #   delete :delete_cover_pic, on: :member
    # end

    # resources :ec_ads

    # resources :ec_items do
    #   post :sync_taobao, on: :collection
    #   post :destroy_multi, on: :collection
    # end

    # resources :ec_seller_cats do
    #   post :sync_taobao, on: :collection
    #   get :update_sorts, on: :member
    # end

    # resources :ec_orders do
    #   post :destroy_order_item
    # end

    # resources :hotels, :hotel_branches, :hotel_comments, :hotel_order_items, :hotel_room_types

    # resources :hotel_room_settings do
    #   get :change_branch, on: :collection
    # end

    # resources :hotel_orders do
    #   post :revoked, :completed, on: :member
    # end

    # resources :hotel_pictures do
    #   post :cover, :discover, on: :member
    # end

    resources :colleges do
      get :intro, on: :member
      get :cities, :districts, :message, on: :collection
      put :create_activity, on: :collection
      resources :college_majors,   as: :majors,   except: [:show]
      resources :college_teachers, as: :teachers, except: [:show]
      resources :college_enrolls,  only: [:index, :destroy]
      resources :college_photos,   as: :photos,   only: [:index, :create, :update, :edit, :destroy]
      resources :college_branches, as: :branches, except: [:show]
    end

    resources :weddings do
      get  :cities,   on: :collection
      get :story,:edit_template     , on: :member
      post :set_seats_status, on: :collection
      put  :update_story,:update_template,     on: :member

      resources :wedding_wishes,   only: [:index, :destroy],                          as: :wishes
      resources :wedding_pictures, only: [:index, :create, :update, :destroy],        as: :pictures
      resources :wedding_seats,    only: [:index, :create, :show, :update, :destroy], as: :seats
      resources :wedding_guests,   only: [:index, :destroy],                          as: :guests
      resources :wedding_qr_codes, as: :qr_codes
    end

    resources :car_shops, :car_articles, :car_bespeak_options, :car_activity_notices, :car_assistants

    resources :car_catenas do
      get :catenas_data, on: :collection
    end

    resources :car_brands do
      post :delete , on: :member
    end

    resources :car_types do
      get :activity_notice, on: :collection
    end

    resources :car_bespeaks do
      get :activity_notice, on: :collection
      post :visit, on: :member
    end

    resources :car_sellers do
      get :activity_notice, on: :collection
    end

    resources :car_pictures do
      post :cover, :discover, on: :member
      get :panoramic, on: :collection
      post :remove,  on: :collection
    end

    resources :car_owners do
      get :list_owners, on: :collection
    end

    resources :recommend, only: [:index]

    # resources :wshops

    resources :houses
    resources :house_comments, :house_expert_comments, :house_experts

    resources :house_intros do
      collection do
        get :activity
        put :update_activity
        delete :picture
      end
    end

    resources :house_reviews do
      collection do
        get :activity
        put :update_activity
      end
    end
    resources :house_impressions do
      collection do
        get :activity
        put :update_activity
      end
    end
    resources :house_live_photos do
      collection do
        get :activity
        put :update_activity
      end
      member do
        put :approve
      end
    end

    put :standalone_panorama_info, to: "standalone_panoramas#info"
    resources :house_layouts do
      get :activity,        on: :collection
      put :update_activity, on: :collection
      post :panorama_360,   on: :member
      post :panorama_720,   on: :member
      resources :house_layout_panoramas
      resources :standalone_panoramas
    end
    resources :house_bespeaks, only: :index do
      get :activity,        on: :collection
      put :update_activity, on: :collection
    end

    resources :house_sellers do
      get :activity,        on: :collection
      put :update_activity, on: :collection
    end

    resources :house_pictures do
      post :cover, :discover, on: :member
    end

    resources :shop_order_items,  :shop_table_settings, :shop_images

    resources :shop_categories do
      get :second, on: :member
      post :up, on: :member
      post :down, on: :member
    end

    resources :shops do
      resources :shop_branches
      resources :shop_categories
      resources :shop_products do
        post :change_quantity, on: :collection
        post :change_shelve_status, on: :collection
      end
      get :pos, on: :collection
    end

    resources :shop_branches do
      resources :shop_categories, :shop_products, :shop_images
      resources :shop_branch_print_templates
      get :table, :roles, on: :collection
      post :print, on: :member
    end

    resources :shop_branch_print_templates do
      get :config_print, on: :member
      get :config_ec_print, on: :collection
    end

    resources :shop_products do
      post :import, on: :collection
      post :top, on: :member
      get  :sort, on: :member
      get  :root_categories,  on: :collection
      get  :child_categories, on: :collection
    end

    resources :shop_menus do
      get :assign, on: :member
      get :categories, on: :member
      get :root_categories, on: :member
      post :clone, on: :member
    end

    resources :book_rules do
      get :assign, on: :member
      match :copy, on: :member
    end

    resources :shop_orders do
      get  :report, :graphic,  on: :collection
      post :cancel, :complete, on: :member
      post :print, on: :member
      post :skip, on: :member
    end

    resources :shop_table_orders do
      post :complete, :cancel, on: :member
      post :print, on: :member
    end

    resources :trips do
      collection do
        get  :ads, :ticket, :order, :del_ad, :new_ticket, :ticket_status, :order_status
        match :up_ad_title
      end
      post :ad_add, :save_ticket, :destroy_ticket, on: :collection
      get :show_ticket, :show_order, on: :member
    end

    resources :trip_ticket_categories do
      post :update_position, on: :collection
    end

    resources :wx_plots, :wx_plot_telephones, :wx_plot_lives, :wx_plot_owners

    resources :wx_plot_categories do
      get :sms_setting, on: :collection
    end

    resources :wx_plot_bulletins do
      post :done, on: :member
    end

    resources :wx_plot_repair_complains do
      get :reply, :change, on: :member
    end

    resources :broches do
      put :update_activity, on: :collection
    end

    resources :broche_photos

  end

end

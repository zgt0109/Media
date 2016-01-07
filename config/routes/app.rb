Wp::Application.routes.draw do

  namespace :app do

    resources :consumes, :activity_groups, :hotel_comments, :ktv_orders
    resources :activity_enrolls do
      get :ok, on: :collection
    end

    resources :materials do
      get :blue, on: :member
    end

    resources :trips do
      get :new_order, on: :member
      get :order_list, on: :collection
      post :create_order, on: :collection
    end

    resources :hotels do
      get :list, :city, :map, :pictures, on: :collection
    end

    resources :hotel_orders do
      get :success, on: :collection
    end

    resources :whouse do
      collection do
       get :layout, :impress, :comment, :expert_comments, :intro, :flashshow
       post :comment
      end
    end

    resources :micro_stores do
      get :map, :list, on: :collection
    end

    resources :shop_orders do
      member do
        post :success
        get :menu, :confirm
      end

      resources :shop_order_items do
        post :add, :remove, :plus, :minus, on: :member
      end
    end

    resources :shops do
      get :book_dinner, :take_out, on: :collection
      resources :shop_categories do
        resources :shop_products, :only => :index
      end
      resources :shop_products, :only => :show
    end

    resources :shop_product_comments, :only => [:index, :create]

    resources :shop_branches do
      get :map, :menu, :want_dinner, :take_out, on: :member

      resources :shop_categories do
        resources :shop_products, :only => :index
      end
      resources :shop_products, :only => :show
    end

    resources :shop_table_orders do
      get  :success, on: :member
      post :confirm, on: :collection
    end

    resources :websites do
      get :map, :page, on: :member
    end

    resources :vip_cards do
      collection do
        get  :privilege, :consumes
        post :privilege, :signup
      end
    end

    resources :vip_user_payments, only: [:update, :show] do
      collection do
        match :payment
        match :update_transfer_result
      end
    end

    resources :gua do
      get :gua_list, :share, on: :collection
      post :gua, :draw_prize, on: :collection
    end

    resources :wheel, only: :show do
      collection do
        get :list, :share
        post :prize
      end
    end

    resources :fight do
      collection do
        get :register, :read, :answer, :result
        post :index
      end
    end

    resources :leaving_messages do
      post :reply, on: :collection
    end

    resources :slots do
      collection do
        get :slot, :get_prize, constraints: {format: :js}
        post :create_activity_consume
      end
    end

    resources :albums do
      get :list, on: :member
    end

    resources :weddings do
      collection do
        get :guest, :wish, :story, :seat, :address, :wedding_photo, :map
        post :create_guest, :create_wish
      end
    end

    resources :educations do
      collection do
        post :create_enroll
        get :address, :job, :environment, :map, :flash_photo
      end
    end

    resources :college_majors, :college_teachers

    resources :lives do
      get :page, :detail, :comment, on: :member
      post :create_comment, on: :collection
    end

    resources :ebusinesses

    resources :ecategories
    resources :ecomments

    resources :business_circles  do
      get :page, :detail, :comment, on: :member
      post :create_comment, on: :collection
    end

    resources :vips do
      collection do
        post :exchange_gift, :update_consumes, :recharge, :save_release
        get :apply, :vip_card_branches,:account,:description,:exchanged,:list,
            :success,:map, :gifts, :gift, :shops, :points, :consumes, :consume, :balances, :print,
            :privileges, :use_gift, :send_sms, :recharge_back, :recharge_check, :go_recharge,
            :get_gift, :mine, :information, :vip_packages, :vip_package_show, :my_consume_show, 
            :buy_vip_package, :by_usable_amount, :buy_success
        match :tenpay_callback, :tenpay_notify, :signin, :info, :old_coupons, :notes, :passwd, :edit_passwd, :find_passwd, :signup, :activate, :inactive, via: [ :get, :post ]
      end
    end
    resources :vip_apis do
      get :vip_info, :vip_transactions, on: :collection
    end

    resources :hit_eggs, only: :show do
      collection do
        get :hit_egg, :get_prize, constraints: {format: :js}
        post :create_activity_consume
      end
    end

    resources :house_markets
    resources :house_layouts do
      resources :house_layout_panoramas
      get :pictures, :panorama, :panoramas, on: :member
    end

    resources :house_sellers
    resources :house_live_photos do
      get :ugc, on: :collection
    end
    resources :house_impressions do
      get :ugc, :pro_list, on: :collection
    end
    resources :house_intros do
      get :pictures, on: :member
    end

    resources :donation_orders do
      match :test, :callback, :print, :notify, on: :collection
    end
  end

end

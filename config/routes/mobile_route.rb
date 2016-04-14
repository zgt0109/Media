# -*- coding: utf-8 -*-
Wp::Application.routes.draw do

  scope module: :mobile, as: :mobile do
    match '/notice' => 'base#notice'
  end

  constraints subdomain: /m+/  do
    # defaults subdomain: MOBILE_SUB_DOMAIN do
      #scope path: ":site_id(.:ext_name)", module: "mobile", as: "mobile" do
      scope path: ":site_id", module: "mobile", constraints: {site_id: /[^\/]+/ }, as: "mobile" do
        #微官网
        # 首页：
        # http://m.winwemedia.com/:site_id
        # 菜单页面（列表或详情页面）：
        # http://m.winwemedia.com/:site_id/channel/:website_menu_id
        root to: 'websites#index'
        match '/channel/:website_menu_id' => 'websites#channel', as: :channel
        match '/detail/:website_menu_id' => 'websites#detail', as: :detail
        match '/map' => 'websites#map', as: :map
        match '/sitemap' => 'websites#sitemap', as: :sitemap
        match '/unknown_identity' => 'websites#unknown_identity'
        match '/audio/:id' => 'websites#audio', as: :audio

        #微门店 http://m.winwemedia.com/site_id/shop_branches(/:id)
        resources :micro_stores, only: [:index, :show] do
          get :map, :list, on: :collection
        end

        #微相册 http://m.winwemedia.com/site_id/albums(/:id)
        resources :albums, only: [:index, :show] do
          get :list, :comments, :load_more_photos, :load_more_comments, on: :member
          post :create_comment, on: :member
        end

        #360全景
        resources :panoramagrams, only: [:index] do
          get :load_more_items, on: :collection
          get :panorama, on: :member
        end

        #微信卡券
        resources :wx_cards, only: [:index]

        #全民经纪人
        resources :brokerages, except: [:show, :destroy] do
          collection do
            get :broker, :send_sms, :put_clients, :commission_list, :my_clients
            post :save_client
          end
          get :client_change_list, on: :member
        end

        #节日礼包
        resources :red_packets, only: [:index, :show, :new, :create]

        resources :scenes, only: :index

        resources :donations, only: [:index, :show] do
          get :my_orders, on: :collection
        end

        resources :donation_orders, only: [:new, :create, :update] do
          match :callback, :print, :notify, :success, on: :collection
        end

        #微投票 http://m.winwemedia.com/site_id/votes(/:id)
        resources :vote, only: [] do
          get  :login, :result
          post :detail, :success
        end

        #微调研 http://m.winwemedia.com/site_id/surveys(/:id)
        resources :surveys, only: [:new, :show] do
          match :questions, on: :member
          member do
            get  :feedback, :success, :list
            post :create_feedback, :create_answer
          end
        end

        #微贺卡
        resources :greet_cards, only: [:index, :show] do
          resources :greet_card_items, only: [:index, :show, :create]
        end

        #微预定
        resources :reservations, only: [:index, :new, :show] do
          get :detail, :result, on: :member
          collection do
            post :reserve
            get :result, :abandon, :send_sms
          end
        end

        resources :govmails, :govchats, only: [:index, :new, :create] do
          get :my, on: :collection
        end

        resources :unfolds, only: :index do
          get :prize, :rules, :user, on: :collection
          post :participate, :help_friend, :update_info, on: :collection
        end
        resources :recommends, only: :index do
          get :prize, :user, on: :collection
          post :update_info, on: :collection
        end
        resources :guess, only: [:index, :show] do
          get :prizes, :detail, :hide_consume, on: :collection
          post :create_participation, on: :collection
        end

        #微社区 http://m.winwemedia.com/:site_id/wbbs_topics(/:id)
        resources :wbbs_topics, only: [:index, :new, :create, :show] do
          collection do
            get  :vote_up, :wbbs_notifications, :read_notification
            post :set_user_info
          end
          member do
            post :create_reply
            get :report, :load_replies, :display_photo
          end
        end

        #优惠券 http://m.winwemedia.com/:site_id/coupons
        resources :coupons, only: :index do
          collection do
            get :my, :detail, :user_detail, :shops
            post :apply
          end
        end

        resources :wx_plots, only: [] do
          collection do
            get :bulletins, :repair_complains, :telephones, :lives, :owners, :new_repair_complain
            post :create_repair_complain
          end
          member do
            get :bulletin, :repair_complain, :life
            post :cancel_repair_complain, :repair_complain_message
          end
        end

        resources :website_articles, only: [:index, :show] do
          get :tags, on: :collection
        end

        resources :likes, only: [:create, :destroy]
        resources :comments, only: [:index, :new, :create]
      end
    # end
  end

  scope path: ':site_id', module: :mobile, constraints: {site_id: /\d+/ },  as: :mobile do
    resources :wx_walls, only: :show
    resources :shakes, only: [:index, :show]
    resources :trips, only: [:index, :show]
    resources :trip_orders, only: [:index, :new, :create]

    resources :bookings, only: :index
    resources :booking_comments, only: [:index, :new, :create]
    resources :booking_items, :booking_categories, only: :show

    resources :booking_orders, except: [:edit, :update] do
      get :cancel, on: :member
    end

    resources :hospital_doctors, only: [:index, :show]
    resources :hospital_comments, :hospital_orders, only: [:index, :new, :create]

    resources :doctor_arrange_items, only: [:new, :show, :create] do
      get :my_items, on: :collection
    end

    resources :doctor_watches, only: :index do
      get :items, on: :collection
    end

    resources :groups, only: :index
    resources :group_comments, only: [:index, :new, :create]
    resources :group_orders do
      get :pay, :consume, on: :member
    end
    resources :group_items, only: :show do
      get :order, on: :member
      post :confirm, on: :member
    end

    resources :weddings, only: :index do
      get :list, on: :member
      post :create_guest, :create_wish, on: :collection
    end

    resources :car_shops, only: [:index, :show, :create] do
      get :car_type, :panorama, :compare, on: :member
      get :car_bespeak, :car_seller, :user_bespeak, :change_type, :delete_bespeak, :photo, on: :collection
    end

    resources :car_owners, except: [:show, :destroy] do
      get :select_type, on: :collection
    end
    resources :car_assistants, only: :index

    resources :waves, only: :index do
      collection do
        get :intro, :prizes, :has_end, :prepare
        post :draw_prize,  :get_prize, :check
      end
    end

    resources :share_photo_comments, only: [:index, :create]
    resources :share_photos, only: :show do
      post :like, on: :member
    end

    resources :business_shops, only: :show do
      member do
        get :privileges, :items, :item, :pictures, :flashshow, :comments, :leave_comment
        post :create_comment
      end
    end

    resources :sms_orders, only: [] do
      get :alipayapi, on: :member
      collection do
        get :callback
        post :notify, :payment_request
      end
    end

    #================== food start =========================================

    resources :shop_orders, only: [:index, :new, :show, :update, :destroy] do
      match :success, :send_captcha, :clone, on: :member
      member do
        get :menu, :confirm, :search
        post :add_item, :remove_item, :change_item, :cancel
      end

      post :toggle_is_show_product_pic, on: :collection
    end

    resources :shop_order_items, only: [:create, :destroy] do
      post :plus, :minus, on: :member
      post :change, on: :member
    end

    resources :shops, only: :index do
      get :book_dinner, :take_out, :book_table, on: :collection
      resources :shop_categories do
        resources :shop_products, only: :index
      end
      resources :shop_products, only: :show
    end

    resources :shop_product_comments, only: [:index, :create]

    resources :shop_branches, only: [:index, :show] do
      get :map, :want_dinner, :take_out, on: :member

      resources :shop_categories do
        resources :shop_products, only: :index
      end
      resources :shop_products, only: :show
    end

    resources :shop_table_orders do
      get  :success, on: :member
      post :confirm, on: :collection
    end

    #================== food end =======================================

    namespace :wmall do
      get :wx_user, to: 'dashboard#wx_user'
      get :following_shops, to: 'dashboard#following_shops'

      resources :activities, only: :index
      resources :products, only: [:index, :show]
      resources :shops, only: [:index, :show] do
        get :show_env, :slides, :products, :comments, :add_comment, on: :member
        get :category, on: :collection
      end

      root to: 'dashboard#index'
    end

    resources :broche_photos, only: :index
    resources :fans_games, only: [:index, :show]

    resources :aids, only: :index do
      collection do
        get  :verification, :award, :aid_friends, :rank_list
        post :friend_aid, :invite_friends, :receive, :acceptance
      end
    end
  end
end

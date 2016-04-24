# -*- coding: utf-8 -*-
Wp::Application.routes.draw do

  root to: 'home#index'

  # resources :logged_exceptions

  mount RuCaptcha::Engine => "/rucaptcha"

  require 'sidekiq/web'
  # authenticate :account do
  mount Sidekiq::Web => '/sidekiq'
  # end

  match "auth_agent/wx_oauth", to: "auth_agent#wx_oauth"
  match "auth_agent/wx_oauth_callback", to: "auth_agent#wx_oauth_callback"

  resources :sessions, only: :create
  match 'sign_in'  => 'sessions#new',     as: :sign_in
  match 'sign_out' => 'sessions#destroy', as: :sign_out
  match 'secret'   => 'sessions#secret'
  match 'register' => 'accounts#new', as: :register
  match 'profile' => 'accounts#index', as: :profile

  resources :passwords, only: [:new, :create]
  resources :password_resets do
    post :resend_email, on: :member
  end

  match :verify_code, :validate_image_code, :helpers, :games, :help_menus, :console, controller: :home
  match :about, :joins, :micro_channel, :h5_marketing, :large_customer, :optimal_code, :store, :electricity, :retail, :agents_inquiry, controller: 'site/pages'


  match '/recepit/print',  :to => "pro::shop_branch_print_templates#recepit"
  match '/printlog',       :to => "pro::shop_branch_print_templates#printlog"
  match '/recepit/export', :to => "pro::shop_branch_print_templates#export_print_data"

  match "/404", :to => "home#not_found", as: :four_o_four, constraints: {format: :html}
  match "/500", :to => "home#error", as: :five_o_o, constraints: {format: :html}

  resources :home, only: :index do
    get :help_post, on: :member
  end

  resources :system_messages, only: [:index, :destroy] do
    member do
      get :read
      post :ajax_update
    end
    post :read_all, :api, on: :collection
  end

  resources :payment_settings do
    post :enable, :disable, on: :member
  end

  resources :payments, only: [:new, :create] do
    get :alipayapi, on: :member

    collection do
      get :callback, :merchant
      post :notify, :payment_request
    end
  end

  resources :yeepay, only: :new do
    get :pay, :callback, on: :collection
  end

  namespace :payment do
    get 'yeepay/pay', to: "yeepay#pay"
    match 'yeepay/:merchantaccount/callback', to: "yeepay#callback", via: [:post, :put, :get]
    match 'yeepay/notify', to: "yeepay#notify", via: [:post, :put, :get]

    get 'alipay/pay', to: "alipay#pay"
    get 'alipay/callback', to: "alipay#callback"
    match 'alipay/notify', to: "alipay#notify", via: [:post, :put, :get]

    get 'vip_userpay/callback', to: "vip_userpay#callback"
    match 'vip_userpay/notify', to: "vip_userpay#notify", via: [:post, :put, :get]
    get 'wxpay/pay', to: "wxpay#pay"
    get 'wxpay/success', to: "wxpay#success"
    get 'wxpay/fail', to: "wxpay#fail"
    get 'wxpay/test', to: "wxpay#test"
    match 'wxpay/notify', to: "wxpay#notify", via: [:post, :put, :get]
  end

  match "/tenpay/callback", :to => "tenpay#callback", as: :tenpay_callback
  match "/tenpay/notify",   :to => "tenpay#notify",   as: :tenpay_notify
  match "/tenpay/pay",      :to => "tenpay#pay",      as: :tempay_pay

  match "/app/donation_orders/callback", :to => "tenpay#callback", as: :tenpay_callback

  resources :news, only: [:index, :show] do
    get :qa, :info, :company, on: :collection
  end
  resources :feedbacks, only: [:index, :create, :show]

  resources :assistants, only: [:index] do
    post :toggle, on: :collection
  end

  resources :activity_prize_elements, only: [:create, :update, :destroy]

  resources :activity_prizes, except: [:index] do
    get :probability, on: :collection
  end

  resources :leaving_messages, only: [:index, :create, :edit, :destroy] do
    collection do
      get :set_template, :edit_activity
      post :set_header_bg, :upload, :set_template_save, :update_activity
      put :update_activity
    end

    post :forbid_replier, :cancel_forbid_replier, :deny, :check, on: :member
  end

  resources :accounts, only: [:new, :create, :update, :edit] do
    collection do
      get :send_sms
      post :update_mobile
    end
  end

  resources :sites do
    get :switch, on: :collection
  end
  match 'copyright' => 'sites#copyright', as: :copyright
  post  'update_copyright' => 'sites#update_copyright', as: :update_copyright

  resources :prints do
    get :activities, on: :collection
  end

  match "/member/bind", :to => "wifi_clients#bind" #给潮wifi调用的接口
  match "/member/modify_bind", :to => "wifi_clients#modify_bind" #给潮wifi调用的接口

  resources :materials, :multiple_materials
  resources :materials_audios, only: [:index, :create, :destroy]

  resources :activities do
    member do
      post :stop, :active, :delete, :deal_failed, :deal_success, :prepare_settings
      post :start_settings, :rule_settings, :prize_settings

      put :prepare_settings, :start_settings, :rule_settings, :prize_settings

      get :survey, :vote_form, :edit_prepare_settings, :edit_start_settings
      get :edit_rule_settings, :edit_prize_settings, :vote_items
      get :edit_group, :show_group, :vote_qrcode, :vote_qrcode_download
      post :update_vote_items
      get :statistics
    end

    collection do
      get :new_group
      get :old_coupons, :guas, :wheels, :fights, :groups, :votes, :surveys, :hit_eggs, :slots, :aids, :vote_form, :waves, :unfolds, :recommends, :guesses
      get 'user_data', as: :votes_user_data
      get 'diagram',   as: :votes_diagram
      get 'survey'
      get :associated_activities
    end

    get :consumes, :report, on: :collection
  end

  resources :old_coupons, :guas, :wheels, :hit_eggs, only: [ :create, :update ]

  resources :activity_consumes, only: [:index, :show] do
    post :used, on: :member
  end

  resources :fight_questions
  resources :fight_papers  do
    get :user_data, on: :collection
    get :use_code, on: :member
  end

  resources :survey_questions do
    collection do
      get :diagram, :user_data, :update_sorts
    end
  end

  resources :qrcode_channel_statistics, only: :index
  resources :qrcode_channels, except: :show do
    get :download, :qrcode_download, on: :member
    get :index_json, on: :collection
  end
  resources :qrcode_channel_types, except: :show  do
    get :index_json, on: :collection
  end

  resources :addresses, only: []  do
    get :cities, :districts, on: :collection
  end

  resources :platforms, only: :index do
    get :bind, on: :collection
  end

  resources :keywords do
    post :destroy_multi, on: :collection
  end
  resources :replies do
    get :autoreply, on: :collection
  end

  namespace :site do
    resources :dev_logs
  end

  namespace :pay do
    resources :accounts do
      get :identity, :account, :apply, :conditions, on: :collection
    end
    resources :withdraws do
      get :apply, :request_withdraw, :service_recharge, on: :collection
      post :confirm_withdraw, on: :collection
    end
    resources :transactions do
      get :balance, on: :collection
    end
  end

  namespace :wx do
    resources :menus do
      get :up_menu, :down_menu, :menus, on: :collection
    end
    resources :mp_users, except: [:edit, :show, :destroy] do
      post :auth, :enable, :disable, :open_oauth, :close_oauth, on: :member
      get :qrcode, :oauth, on: :collection
    end

    resources :user_groups  do
      post :choose , on: :member
      post :add_to_group ,:search_user,on: :collection
    end

    resources :messages do
      post :send_message ,on: :collection
    end
  end

  namespace :data do
    resources :sites do
    end
    resources :vip_users do
      get :point, :amount, on: :collection
    end
    resources :wx_requests do
      get :subscribe, :keyword,:message,:message_hour,:article,:article_hour, :hit, :not_hit, on: :collection
    end
  end

  namespace :merchant do
    resources :sessions, only: :create
    match 'login'  => 'sessions#new',     as: :login
    match 'secret' => 'sessions#secret'
  end

  namespace :sms do
    resource :messages, only: [] do
      collection do
        get :switch
        post :toggle, :send_message, :send_text_message
      end
    end
    resources :expenses, only: :index
    resources :orders, except: [:edit, :show, :update] do
      get :alipayapi, :cancel, on: :member
      collection do
        get :callback, :merchant
        post :notify, :payment_request
      end
    end
  end

end

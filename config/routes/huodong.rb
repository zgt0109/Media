Wp::Application.routes.draw do
  scope module: 'huodong' do

    namespace :red_packet do
      resources :packets do
        member do
          get :preview_template
        end
      end

      resources :releases, only: :index do
        collection do
          get :consumes, :find_consume
          post :use_consume
        end
      end
    end

    namespace :brokerage do
      resources :settings, only: [:index, :create, :update]

      resources :commission_types, only: [:index, :edit, :update, :show] do
        get :edit_status, on: :member
      end

      resources :brokers ,only: [:index, :show] do
        resources :commission_transactions, only: [:index, :new, :create]
      end

      resources :clients, only: [:index, :edit, :update ,:create]

      resources :client_changes, only: :index
    end


    resources :wx_shakes, except: [:show, :destroy] do
      get :shake_round, on: :collection
      member do
        post :set_status, :set_prize_status
        get :shake_round_show
      end
    end

    resources :wx_shake_sites, only: :index do
      get :update_mobile, on: :collection
      get :update_user, :get_user_count, :shake_start, :shake_end, :start_next, :save_prize, on: :member
    end

    resources :fans_games, except: [:new, :edit]

    resources :guesses do
      get :settings, on: :member
      get :load_more, :consumes, :find_consume, on: :collection
      post :use_consume, on: :collection
    end

    resources :panoramagrams do
      get :list, on: :collection
      member do
        post :item_activity_create
        put :item_activity_update
        get :item_activity
      end
    end

    resources :guess_questions
    resources :guess_reports, only: :index

    resources :wx_cards do
      collection do
        get  :card_admins, :card_consumes, :card_reports, :use_consume, :find_consume
        post :confirm_use_consume
      end
    end

    resources :wx_walls do
      member do
        post :stop, :start
        get :add_new_prize, :extra_settings, :get_message, :lottery, :winner_list, :delete_prize_user, :preview_template
      end
      collection do
        get :help
        post :save_qiniu_keys
        delete :destroy_qiniu_keys
      end
    end

    resources :wx_wall_user_prizes do
      member do
        post :update_user_prize
        get :exchange_prize
      end
    end

    resources :wx_wall_messages do
      post :pull_black, :allow, on: :member
    end

    resources :wx_wall_datas, only: :index

  end
end
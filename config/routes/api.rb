Wp::Application.routes.draw do

  scope module: :api do
    post  'ticket', to: 'wx_plugin#ticket'
    match 'wx_plugin/auth', to: 'wx_plugin#auth'
  end

  namespace :api do

    # wmall
    namespace :wmall do
      resources :wx_users, only: [:show] do
        get :following_shops, on: :member
      end
      resources :categories
      resources :shops do
        get :all, :list, :category, on: :collection
        member do
          get :comments
          post :comment, :follow_switching
        end
        resources :pictures, controller: 'shop_pictures'
        resources :activities, controller: 'shop_activities'
      end
      resources :products, only: [:index, :show] do
        get :list, :categories, :shop, on: :collection
      end
      resources :shop_accounts
      resources :activities, only: :index do
        get :list, on: :collection
      end
      resources :slide_pictures
    end

    namespace :fxt do
      resources :tasks, only: [] do
        get :rebate, on: :collection
      end
    end

  end

  # namespace :api, path: "", defaults: { format: :json }, constraints: { subdomain: "api" } do
  namespace :api, path: '', defaults: { format: :json } do
    namespace :v1 do
      resources(:vips, only: []) {
        collection do
          post :pay, :earn_points, :consume_points, :return_points, :return_amount, :spm_points
          get :usable_points, :earnable_points, :user_info, :spm_vip
        end
      }

      resources(:coupons, only: []) {
        collection do
          post :use, :cancel
          get :coupon_list, :consume_list, :recommend_coupons
        end
      }

      resources(:wbbs, only: []) {
        collection do
          post :create_wbbs
          get :find
        end
      }

      resources(:wx, only: []) do
        get :jsapi_config, :token, on: :collection
      end

      resources(:vip_packages, only: []) do
        get :get_vip_packages_api, :get_vip_packages_life_api, on: :collection
      end

      resources(:channel_qrcodes, only: []) do
        get :qrcode_user_amount_api, on: :collection
      end

    end
  end

end

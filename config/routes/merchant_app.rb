Wp::Application.routes.draw do

  namespace :merchant_app do

    resources :orders, only: [] do
      collection do
        get :plot_orders, :reservation_orders, :shop_orders, :shop_table_orders, :car_orders, :gov_orders
      end
      member do
        get :plot_order_detail, :reservation_order_detail, :shop_order_detail, :car_order_detail, :shop_table_order_detail, :gov_order_detail
      end
    end

    resources :houses, :dev_logs, only: [:index, :show]

  end

end

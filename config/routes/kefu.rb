Wp::Application.routes.draw do

  scope module: 'kefu' do
    match 'kefu_api', to: "api#index"

    resources :staffs do
      collection do
        post :validate_staff_no, :validate_staff_role
      end
    end

    resources :kf_settings, only: [:index] do
      collection do
        put :update
        post :reset
      end
    end
  end

end

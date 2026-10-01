Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      devise_for :users, path: "auth", controllers: {
        sessions: "api/v1/auth/sessions",
        registrations: "api/v1/auth/registrations"
      },
      defaults: { format: :json }

      resources :practitioners, only: %i[show index] do
        member do
          get :available_slots
        end
      end

      resources :conversations, only: %i[index show create] do
        resources :messages, only: %i[index create] do
          collection do
            patch :mark_as_read
          end
        end
      end

      resources :appointments, only: %i[index show create] do
        member do
          patch :cancel
          patch :reschedule
          patch :payment_status
          patch :status
        end
      end

      namespace :profiles do
        resource :patient_profiles, only: %i[show update]
        resource :practitioner_profiles, only: %i[show update]
      end
    end
  end
end

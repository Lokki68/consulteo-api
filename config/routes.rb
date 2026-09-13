Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, path: "auth", controllers: {
        sessions: "api/v1/auth/sessions",
        registrations: "api/v1/auth/registrations"
      },
      defaults: { format: :json }

      namespace :profiles do
        resource :patient_profile, only: [ :show, :update ]
        resource :practitioner_profile, only: [ :show, :update ]
      end
    end
  end
end

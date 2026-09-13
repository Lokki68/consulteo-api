Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, path: 'auth', controllers: {
        sessions: "api/v1/auth/sessions",
        registrations: "api/v1/auth/registrations",
      },
      defaults: { format: :json }


    end
  end
end

# app/controllers/api/v1/auth/registrations_controller.rb
module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        def create
          build_resource(sign_up_params)

          if resource.save
            sign_up(resource_name, resource)
            render json: {
              data: UserSerializer.new(resource).as_json,
              message: 'User registered successfully'
            }, status: :created
          else
            render json: {
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              data: UserSerializer.new(resource).as_json,
              message: 'User registered successfully'
            }, status: :created
          else
            render json: {
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :profile_type)
        end
      end
    end
  end
end
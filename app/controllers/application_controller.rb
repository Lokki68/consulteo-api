class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Devise::Controllers::Helpers

  respond_to :json

  private

  def authenticate_user!
    authenticate_api_v1_user!
  end

  def current_user
    current_api_v1_user
  end
end

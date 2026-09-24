# spec/support/auth_helpers.rb
module AuthHelpers
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

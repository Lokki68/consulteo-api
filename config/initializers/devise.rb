require 'devise/orm/active_record'

Devise.setup do |config|
  config.navigational_formats = []
  config.mailer_sender = 'noreply@consulteo.fr'

  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/sign_outs$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/sign_outs$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end

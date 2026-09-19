# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      return reject_unauthorized_connection if token.blank?

      payload = decode_jwt(token)
      user = User.find_by(id: payload["sub"])

      return reject_unauthorized_connection if user.nil? || revoked?(payload)

      user
    end

    def decode_jwt(token)
      JWT.decode(
        token,
        ENV["DEVISE_JWT_SECRET_KEY"],
        true,
        algorithm: "HS256"
      ).first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      reject_unauthorized_connection
    end

    def revoked?(payload)
      JwtDenylist.exists?(jti: payload["jti"])
    end
  end
end
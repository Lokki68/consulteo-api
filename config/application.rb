require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module ConsulteoApi
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.session_store :cookie_store, key: "_consulteo_api_v1_session"
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
  end
end

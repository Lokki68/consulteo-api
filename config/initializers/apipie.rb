Apipie.configure do |config|
  config.app_name                = "ConsulteoApi"
  config.app_info                = "API for managing medical appointment"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/api/documentation"
  config.copyright               = "© 2026 LokkiDevelopment"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.validate                = false
  config.markup                  = :markdown
end

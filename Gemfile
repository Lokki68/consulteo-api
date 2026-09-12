source "https://rubygems.org"



gem "rails", "~> 8.1.3", ">= 8.1.3.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"


gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

gem "image_processing", "~> 1.2"

# Auth
gem 'devise'
gem 'devise-jwt'

# Authorization
gem "pundit"

# Background Jobs
gem "sidekiq", "~> 7.0"
gem "redis", "~> 5.0"

# Chiffrement des données sensibles
gem "lockbox"
gem "blind_index" # Rechercher sur des champs chiffrés

# Audit Trail
gem "paper_trail"

# Cors
gem "rack-cors"

# Pagination
gem "pagy"

# Serialization
gem "alba"


group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "brakeman", require: false
  gem "annotate"
end

group :test do
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end

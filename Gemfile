source "https://rubygems.org"

ruby "3.4.1"

gem "rails", "~> 7.1.5"
gem "pg", "~> 1.5"
gem "puma", ">= 6.4"
gem "rack-cors"
gem "bootsnap", require: false

gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "rswag-specs"
  gem "debug", platforms: %i[mri]
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "database_cleaner-active_record"
end

group :development do
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end
source 'https://rubygems.org'

gem 'rails', '3.2.8'

gem 'forgery'

gem 'puma'

gem 'sqlite3'

# group :assets do
#   gem 'haml-rails'
#   gem "coffee-rails"
#   gem 'sass-rails'
#   gem 'uglifier'
# end

gem 'httparty'

group :development do
  gem "quiet_assets"
end

group :development, :test do
  gem 'letter_opener'
  gem 'pry-rails'
  gem "rspec-rails"
  gem 'awesome_print'
  gem "launchy"
end

group :test do
  gem "database_cleaner"
  gem "simplecov", :require => false
  gem 'shoulda'
  gem "ffaker"
  gem 'rb-fsevent'
  gem "guard-rspec"
  gem 'terminal-notifier-guard'
  gem 'test_after_commit'
end

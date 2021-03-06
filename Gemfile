source 'https://rubygems.org'

gem 'unicorn', '4.6.2'
gem 'rake', '0.9.2.2'
gem 'sinatra', '1.3.2'

if ENV['CONTENT_MODELS_DEV']
  gem 'govuk_content_models', path: '../govuk_content_models'
else
  gem "govuk_content_models", '28.6.0'
end

# TODO: This was previously pinned due to a replica set bug in >1.6.2
# Consider whether this still needs to be pinned when it is provided
# as a dependency of govuk_content_models
gem 'mongo', '>= 1.7.1'

gem 'gds-sso', '10.0.0'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '10.14.0'
end

gem 'govspeak', '~> 3.1'
gem 'plek', '1.7.0'
gem 'yajl-ruby'
gem 'kaminari', '0.14.1'
gem 'link_header', '0.0.5'
gem 'rack-cache', '1.2'
gem 'dalli', '2.6.4'

gem 'rack-logstasher', '0.0.3'
gem 'airbrake', '4.0.0'

group :test do
  gem 'database_cleaner', '0.7.2'
  gem 'factory_girl', '3.6.1'
  gem 'mocha', '0.12.4', require: false
  gem 'simplecov', '0.6.4'
  gem 'simplecov-rcov', '0.2.3'
  gem 'minitest', '3.4.0'
  gem 'turn', require: false
  gem 'ci_reporter', '1.7.0'
  gem 'webmock', '~> 1.8', require: false
  gem 'timecop', '0.5.9.2'
end

group :development do
  # (Intelligent) reloading server in development
  gem "mr-sparkle", "0.2.0"
end

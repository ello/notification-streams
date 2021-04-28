# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.3'

gem 'pg', '~> 0.18'
gem 'puma'
gem 'puma_worker_killer'
gem 'rails', '~> 5.2.4.5'

# New Relic just added Rails 5 support
gem 'newrelic_rpm'

gem 'rack-timeout', require: 'rack/timeout/base'

gem 'redis', '~> 3.2'

gem 'interactor-rails', '~> 2.0'

group :development do
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :test do
  gem 'rspec-rails-time-metadata'
  gem 'shoulda-matchers', '~> 3.1'
end

group :production do
  gem 'honeybadger', '~> 2.0'
  gem 'rails_12factor'
end

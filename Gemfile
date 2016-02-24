source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '>= 5.0.0.beta2', '< 5.1'
gem 'pg', '~> 0.18'
gem 'puma'

# New Relic doesn't support Rails 5 yet :(
# gem 'newrelic_rpm'

gem 'interactor-rails', '~> 2.0'

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

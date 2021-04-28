Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: Integer(ENV['REQUEST_TIMEOUT'] || 30) # seconds

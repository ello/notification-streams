Rack::Timeout.timeout = Integer(ENV['REQUEST_TIMEOUT'] || 30)  # seconds

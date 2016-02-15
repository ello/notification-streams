RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.around(:example, :freeze_time) do |example|
    time = Time.zone.now.change(usec: 0)
    travel_to(time) do
      example.run
    end
  end
end

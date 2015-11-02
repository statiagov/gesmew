require 'capybara/rspec'
require 'capybara/rails'

RSpec.configure do |config|
  Capybara.javascript_driver = :selenium
  Capybara.default_wait_time = 10
end

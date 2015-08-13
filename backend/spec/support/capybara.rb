require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

RSpec.configure do |config|
  Capybara.javascript_driver = :selenium
  Capybara.default_wait_time = 7
end

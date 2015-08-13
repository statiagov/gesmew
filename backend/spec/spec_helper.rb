if ENV["COVERAGE"]
  # Run Coverage report
  require 'simplecov'
  SimpleCov.start do
    add_group 'Controllers', 'app/controllers'
    add_group 'Helpers', 'app/helpers'
    add_group 'Mailers', 'app/mailers'
    add_group 'Models', 'app/models'
    add_group 'Views', 'app/views'
    add_group 'Libraries', 'lib'
  end
end

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'

begin
  require File.expand_path("../dummy/config/environment", __FILE__)
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
  exit
end

require 'rspec/rails'

require 'database_cleaner'
require 'ffaker'
require 'timeout'

require 'gesmew/testing_support/authorization_helpers'
require 'gesmew/testing_support/factories'
require 'gesmew/testing_support/preferences'
require 'gesmew/testing_support/controller_requests'
require 'gesmew/testing_support/flash'
require 'gesmew/testing_support/url_helpers'
require 'gesmew/testing_support/inspection_walkthrough'
require 'gesmew/testing_support/capybara_ext'

require 'paperclip/matchers'


RSpec.configure do |config|
  config.filter_run focus: true
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.mock_with :rspec do |mock|
    mock.syntax = [:should, :expect]
  end
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    Rails.cache.clear
    WebMock.disable!
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    # TODO: Find out why open_transactions ever gets below 0
    # See issue #3428
    if ActiveRecord::Base.connection.open_transactions < 0
      ActiveRecord::Base.connection.increment_open_transactions
    end

    DatabaseCleaner.start
    reset_gesmew_preferences
  end

  config.after do
    wait_for_ajax if RSpec.current_example.metadata[:js]
    DatabaseCleaner.clean
  end

  config.after(:each, :type => :feature) do |example|
    missing_translations = page.body.scan(/translation missing: #{I18n.locale}\.(.*?)[\s<\"&]/)
    if missing_translations.any?
      puts "Found missing translations: #{missing_translations.inspect}"
      puts "In spec: #{example.location}"
    end
  end

  config.include FactoryGirl::Syntax::Methods

  config.include Gesmew::TestingSupport::Preferences
  config.include Gesmew::TestingSupport::UrlHelpers
  config.include Gesmew::TestingSupport::ControllerRequests, type: :controller
  config.include Gesmew::TestingSupport::Flash

  config.include Paperclip::Shoulda::Matchers

  config.extend WithModel
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

module Gesmew
  module TestingSupport
    module Flash
      def assert_flash_success(flash)
        flash = convert_flash(flash)

        within(".alert-success") do
          expect(page).to have_content(flash)
        end
      end
    end
  end
end

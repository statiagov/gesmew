namespace :email do
  desc 'Sends test email to specified address - Example: EMAIL=gesmew@example.com bundle exec rake email:test'
  task test: :environment do
    unless ENV['EMAIL'].present?
      raise ArgumentError, "Must pass EMAIL environment variable. " \
                           "Example: EMAIL=gesmew@example.com bundle exec rake email:test"
    end
    Gesmew::TestMailer.test_email(ENV['EMAIL']).deliver_now
  end
end

module Gesmew
  class TestMailer < BaseMailer
    def test_email(email)
      # subject = "#{Gesmew::Store.current.name} #{Gesmew.t('test_mailer.test_email.subject')}"
      mail(to: email, from: from_address, subject: subject)
    end
  end
end

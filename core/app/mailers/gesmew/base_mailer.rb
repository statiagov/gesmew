module Gesmew
  class BaseMailer < ActionMailer::Base

    def from_address
      "mjgumbs.200@gmail.com"
    end

    def mail(headers={}, &block)
      super if Gesmew::Config[:send_core_emails]
    end

  end
end

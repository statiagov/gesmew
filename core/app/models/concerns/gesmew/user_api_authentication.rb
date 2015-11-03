module Gesmew
  module UserApiAuthentication
    def generate_gesmew_api_key!
      self.gesmew_api_key = SecureRandom.hex(24)
      save!
    end

    def clear_gesmew_api_key!
      byebug
      self.gesmew_api_key = nil
      save!
    end
  end
end

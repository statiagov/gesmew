module Gesmew
  module Api
    module TestingSupport
      module Setup
        def sign_in_as_admin!
          let!(:current_api_user) do
            user = stub_model(Gesmew.user_class)
            allow(user).to receive_message_chain(:gesmew_roles, :pluck).and_return(["admin"])
            allow(user).to receive(:has_gesmew_role?).with("admin").and_return(true)
            user
          end
        end
      end
    end
  end
end

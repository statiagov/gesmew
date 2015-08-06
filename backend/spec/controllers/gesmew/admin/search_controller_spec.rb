require 'spec_helper'

describe Gesmew::Admin::SearchController, :type => :controller do
  stub_authorization!
  # Regression test for ernie/ransack#176

  describe "users" do
    let(:user) { create(:user, :email => "gesmew_commerce@example.com") }

    it "can find a user by their email "do
      gesmew_xhr_get :users, :q => user.email
      expect(assigns[:users]).to include(user)
    end
  end
end

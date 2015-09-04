require 'spec_helper'

describe Gesmew::Admin::SearchController, :type => :controller do
  stub_authorization!
  # Regression test for ernie/ransack#176

  describe "users" do
    let(:user) { create(:user, :email => "gesmew_commerce@example.com", firstname:'Vaughn', lastname:'Sams') }

    it "can find a user by their first or last name "do
      gesmew_xhr_get :users, :q => user.first_name
      expect(assigns[:users]).to include(user)
      byebug
    end
  end
end

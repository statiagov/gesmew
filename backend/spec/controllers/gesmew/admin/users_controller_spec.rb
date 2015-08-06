require 'spec_helper'
require 'gesmew/testing_support/bar_ability'

describe Gesmew::Admin::UsersController, :type => :controller do
  let(:user) { create(:user) }
  let(:mock_user) { mock_model Gesmew.user_class }

  before do
    allow(controller).to receive_messages :gesmew_current_user => user
    user.gesmew_roles.clear
    stub_const('Gesmew::User', user.class)
  end

  context "#show" do
    before do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
    end

    it "redirects to edit" do
      gesmew_get :show, id: user.id
      expect(response).to redirect_to gesmew.edit_admin_user_path(user)
    end
  end

  context '#authorize_admin' do
    before { use_mock_user }

    it 'grant access to users with an admin role' do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      gesmew_post :index
      expect(response).to render_template :index
    end

    it "allows admins to update a user's API key" do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:generate_gesmew_api_key!).and_return(true)
      gesmew_put :generate_api_key, id: mock_user.id
      expect(response).to redirect_to(gesmew.edit_admin_user_path(mock_user))
    end

    it "allows admins to clear a user's API key" do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
      expect(mock_user).to receive(:clear_gesmew_api_key!).and_return(true)
      gesmew_put :clear_api_key, id: mock_user.id
      expect(response).to redirect_to(gesmew.edit_admin_user_path(mock_user))
    end

    it 'deny access to users with an bar role' do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
      Gesmew::Ability.register_ability(BarAbility)
      gesmew_post :index
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users with an bar role' do
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
      Gesmew::Ability.register_ability(BarAbility)
      gesmew_post :update, { id: '9' }
      expect(response).to redirect_to '/unauthorized'
    end

    it 'deny access to users without an admin role' do
      allow(user).to receive_messages :has_gesmew_role? => false
      gesmew_post :index
      expect(response).to redirect_to '/unauthorized'
    end
  end

  describe "#update" do
    before do
      use_mock_user
      user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
    end

    it "allows updating without password resetting" do
      expect(mock_user).to receive(:update_attributes).with(hash_not_including(password: '', password_confirmation: ''))
      gesmew_put :update, id: mock_user.id, user: { password: '', password_confirmation: '', email: 'gesmew@example.com' }
    end
  end
end

def use_mock_user
  allow(mock_user).to receive(:save).and_return(true)
  allow(Gesmew.user_class).to receive(:find).with(mock_user.id.to_s).and_return(mock_user)
  allow(Gesmew.user_class).to receive(:new).and_return(mock_user)
end

require 'spec_helper'

class FakesController < ApplicationController
  include Gesmew::Core::ControllerHelpers::Auth
  def index; render text: 'index'; end
end

describe Gesmew::Core::ControllerHelpers::Auth, type: :controller do
  controller(FakesController) {}

  describe '#current_ability' do
    it 'returns Gesmew::Ability instance' do
      expect(controller.current_ability.class).to eq Gesmew::Ability
    end
  end

  describe '#redirect_back_or_default' do
    controller(FakesController) do
      def index; redirect_back_or_default('/'); end
    end
    it 'redirects to session url' do
      session[:gesmew_user_return_to] = '/redirect'
      get :index
      expect(response).to redirect_to('/redirect')
    end
    it 'redirects to HTTP_REFERER' do
      request.env["HTTP_REFERER"] = '/dummy_redirect'
      get :index
      expect(response).to redirect_to('/dummy_redirect')
    end
    it 'redirects to default page' do
      get :index
      expect(response).to redirect_to('/')
    end
  end

  describe '#set_guest_token' do
    controller(FakesController) do
      def index
        set_guest_token
        render text: 'index'
      end
    end
    it 'sends cookie header' do
      get :index
      expect(response.cookies['guest_token']).not_to be_nil
    end
  end

  describe '#store_location' do
    it 'sets session return url' do
      allow(controller).to receive_messages(request: double(fullpath: '/redirect'))
      controller.store_location
      expect(session[:gesmew_user_return_to]).to eq '/redirect'
    end
  end

  describe '#try_gesmew_current_user' do
    it 'calls gesmew_current_user when define gesmew_current_user method' do
      expect(controller).to receive(:gesmew_current_user)
      controller.try_gesmew_current_user
    end
    it 'calls current_gesmew_user when define current_gesmew_user method' do
      expect(controller).to receive(:current_gesmew_user)
      controller.try_gesmew_current_user
    end
    it 'returns nil' do
      expect(controller.try_gesmew_current_user).to eq nil
    end
  end

  describe '#redirect_unauthorized_access' do
    controller(FakesController) do
      def index; redirect_unauthorized_access; end
    end
    context 'when logged in' do
      before do
        allow(controller).to receive_messages(try_gesmew_current_user: double('User', id: 1, last_incomplete_gesmew_order: nil))
      end
      it 'redirects unauthorized path' do
        get :index
        expect(response).to redirect_to('/unauthorized')
      end
    end
    context 'when guest user' do
      before do
        allow(controller).to receive_messages(try_gesmew_current_user: nil)
      end
      it 'redirects login path' do
        allow(controller).to receive_messages(gesmew_login_path: '/login')
        get :index
        expect(response).to redirect_to('/login')
      end
      it 'redirects root path' do
        allow(controller).to receive_message_chain(:gesmew, :root_path).and_return('/root_path')
        get :index
        expect(response).to redirect_to('/root_path')
      end
    end
  end
end

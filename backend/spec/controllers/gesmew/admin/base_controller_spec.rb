# Gesmew's rpsec controller tests get the Gesmew::ControllerHacks
# we don't need those for the anonymous controller here, so
# we call process directly instead of get
require 'spec_helper'

describe Gesmew::Admin::BaseController, type: :controller do
  controller(Gesmew::Admin::BaseController) do
    def index
      authorize! :update, Gesmew::Inspection
      render text: 'test'
    end
  end

  context "unauthorized request" do
    before do
      allow_any_instance_of(Gesmew::Admin::BaseController).to receive(:gesmew_current_user).and_return(nil)
    end

    it "redirects to root" do
      allow(controller).to receive_message_chain(:gesmew, :root_path).and_return('/root')
      get :index
      expect(response).to redirect_to '/root'
    end
  end
end

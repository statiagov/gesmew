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

  context "#auto_complete_ids_to_exclude" do
    before do

    end

    it "it should return [] when obj is nil" do
      allow(controller).to receive(:params).and_return({related:'inspectors'})
      expect(controller.send(:auto_complete_ids_to_exclude, nil)).to eq([])
    end

    it "should return [6, 9] when related is 'inspection/N101" do
      allow(controller).to receive(:params).and_return({related:'inspectors'})
      inspection = double(Gesmew::Inspection, inspectors: [double(id: 6), double(id: 9)])
      expect(Gesmew::Inspection).to receive_message_chain(:friendly, :find).with('N101').and_return(inspection)
      expect(controller.send(:auto_complete_ids_to_exclude, 'inspection/N101').sort).to eq([6,9])
    end

    it "should return [] when related object association is not found" do
      allow(controller).to receive(:params).and_return({related:'inspectors'})
      inspection = double(Gesmew::Inspection)
      expect(Gesmew::Inspection).to receive_message_chain(:friendly, :find).with('N101').and_return(inspection)
      expect(controller.send(:auto_complete_ids_to_exclude, 'inspection/N101')).to eq([])
    end
  end
end

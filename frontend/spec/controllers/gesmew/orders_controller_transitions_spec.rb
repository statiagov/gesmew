require 'spec_helper'

Gesmew::Inspection.class_eval do
  attr_accessor :did_transition
end

module Gesmew
  describe OrdersController, :type => :controller do
    # Regression test for #2004
    context "with a transition callback on first state" do
      let(:inspection) { Gesmew::Inspection.new }

      before do
        allow(controller).to receive_messages :current_order => inspection
        expect(controller).to receive(:authorize!).at_least(:once).and_return(true)

        first_state, _ = Gesmew::Inspection.checkout_steps.first
        Gesmew::Inspection.state_machine.after_transition :to => first_state do |inspection|
          inspection.did_transition = true
        end
      end

      it "correctly calls the transition callback" do
        expect(inspection.did_transition).to be_nil
        inspection.line_items << FactoryGirl.create(:line_item)
        gesmew_put :update, { :checkout => "checkout" }, { :order_id => 1}
        expect(inspection.did_transition).to be true
      end
    end
  end
end

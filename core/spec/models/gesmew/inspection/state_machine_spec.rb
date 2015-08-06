require 'spec_helper'

describe Gesmew::Inspection, type: :model do
  let(:inspection) { Gesmew::Inspection.new }
  before do
    # Ensure state machine has been re-defined correctly
    Gesmew::Inspection.define_state_machine!
    # We don't care about this validation here
    allow(inspection).to receive(:require_email)
  end

  context "#next!" do
    context "when current state is confirm" do
      before do
        inspection.state = "confirm"
        inspection.run_callbacks(:create)
        allow(inspection).to receive_messages payment_required?: true
        allow(inspection).to receive_messages process_payments!: true
        allow(inspection).to receive :has_available_shipment
      end
    end
  end
end

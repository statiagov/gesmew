require 'spec_helper'

describe Gesmew::Inspection, type: :model do
  let(:inspection) { Gesmew::Inspection.new }
  before do
    # Ensure state machine has been re-defined correctly
    Gesmew::Inspection.define_state_machine!
    # We don't care about this validation here
    allow(inspection).to receive(:require_email)
    allow(inspection).to receive(:ensure_at_least_two_inspectors)
    allow(inspection).to receive(:ensure_establishment_present)
  end

  context "#next!" do
    context "when current state is pending" do
      before do
        inspection.state = "pending"
        inspection.run_callbacks(:create)
      end
      it "should transistion to processed" do
        inspection.next
        expect(inspection.state).to eq("processed")
      end
    end
    context "when current state is processed" do
      before do
        inspection.state = "processed"
        inspection.run_callbacks(:create)
      end
      it "shouild transistion to grading and commenting" do
        inspection.next
        expect(inspection.state).to eq("grading_and_commenting")
      end
    end
    context "when current state is grading and commenting" do
      before do
        inspection.state = "grading_and_commenting"
        inspection.run_callbacks(:create)
      end
      it "shouild transistion to completed" do
        inspection.next
        expect(inspection.state).to eq("completed")
      end
    end
  end
end

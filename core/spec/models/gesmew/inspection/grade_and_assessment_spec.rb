require 'spec_helper'

module Gesmew
  describe Gesmew::Inspection, type: :model do
    let(:inspection){build(:inspection)}
    let(:user){create(:user)}
    before do
      # Ensure state machine has been re-defined correctly
      Gesmew::Inspection.define_state_machine!
      # We don't care about this validation here
      allow(inspection).to receive(:require_email)
      allow(inspection).to receive(:ensure_at_least_two_inspectors)
      allow(inspection).to receive(:ensure_establishment_present)
      allow(inspection).to receive(:ensure_scope_present)
      allow(inspection).to receive(:gesmew_user).and_return(user)
    end
    context "#initial_assessment" do
      it "should be called after transistion to pending" do
        # Explicity set the inspection state
        inspection.state = 'pending'
        expect(inspection).to receive(:initial_assessment)
        inspection.next
      end
      it "should not be called unless assessed is false" do
        # Explicity set the inspection state
        inspection.state = 'pending'
        inspection.assessed = true
        expect(inspection).to_not receive(:initial_assessment)
        inspection.next
      end
    end
  end
end

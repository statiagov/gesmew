require 'spec_helper'
require 'cancan'
require 'gesmew/testing_support/bar_ability'

# Ability to test access to specific model instances
class InspectionSpecificAbility
  include CanCan::Ability

  def initialize(user)
    can [:admin, :manage], Gesmew::Inspection, number: 'I987654321'
  end
end

describe Gesmew::Admin::Inspections::CommentsController, type: :controller do


  context "with authorization" do
    stub_authorization!

    let(:inspection) do
      create(:inspection)
    end

    before do
      allow(Gesmew::Inspection).to receive_message_chain(:friendly, :find).and_return(inspection)
    end

    context "#create" do
      before do
        user = create(:admin_user)
        allow(controller).to receive(:try_gesmew_current_user).and_return(user)
      end

      it "assigns commentable" do
        gesmew_post   :create, :inspection_id => inspection.to_param, comment:{comment: "Failure"}
        expect(assigns[:commentable]).to be_a(Gesmew::Inspection)
      end

      it "creates a valid comment for the inspection" do
        gesmew_post :create, :inspection_id => inspection.to_param, comment:{comment: "Failure"}
        expect(assigns[:comment].user).to eq (controller.try_gesmew_current_user)
        expect(assigns[:comment].commentable).to eq(inspection)
        expect(assigns[:comment].comment).to eq "Failure"
      end
    end

  end
end

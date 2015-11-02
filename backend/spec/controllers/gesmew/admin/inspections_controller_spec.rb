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

describe Gesmew::Admin::InspectionsController, type: :controller do
  def allow_pending_validations_after_callback
    allow(inspection).to receive(:require_email)
    allow(inspection).to receive(:ensure_at_least_two_inspectors)
    allow(inspection).to receive(:ensure_establishment_present)
    allow(inspection).to receive(:ensure_scope_present)

    allow(controller).to receive_message_chain(:try_gesmew_current_user, :is_part_of_inspection?).and_return(true)
    allow(inspection).to receive(:initial_assessment)
    association = Gesmew::RubricAssociation.new
    rubric = inspection.scope.rubric
    assessment = Gesmew::RubricAssessment.new
    allow(rubric).to receive(:associate_with).and_return(association)
    allow(association).to receive(:assessment).and_return(assessment)
    allow(association).to receive(:id).and_return(1)
  end

  context "with authorization" do
    stub_authorization!

    before do
      request.env["HTTP_REFERER"] = "http://localhost:3000"

      # ensure no respond_overrides are in effect
      if Gesmew::BaseController.gesmew_responders[:InspectionsController].present?
        Gesmew::BaseController.gesmew_responders[:InspectionsController].clear
      end
    end

    let(:inspection) do
      mock_model(
        Gesmew::Inspection,
        completed?:      true,
        number:          'I123456789'
      )
    end

    before do
      allow(Gesmew::Inspection).to receive_message_chain(:friendly, :find).and_return(inspection)
    end

    # context "#approve" do
    #   it "approves an inspections" do
    #     expect(inspection).to receive(:approved_by).with(controller.try_gesmew_current_user)
    #     gesmew_put :approve, id: inspection.number
    #     expect(flash[:success]).to eq Gesmew.t(:inspection_approved)
    #   end
    # end

    # context "#cancel" do
    #   it "cancels an inspection" do
    #     expect(inspection).to receive(:canceled_by).with(controller.try_gesmew_current_user)
    #     gesmew_put :cancel, id: inspection.number
    #     expect(flash[:success]).to eq Gesmew.t(:inspection_canceled)
    #   end
    # end
    #
    # context "#resume" do
    #   it "resumes an inspection" do
    #     expect(inspection).to receive(:resume!)
    #     gesmew_put :resume, id: inspection.number
    #     expect(flash[:success]).to eq Gesmew.t(:inspection_resumed)
    #   end
    # end
    #
    context "pagination" do
      it "can page through the inspections" do
        gesmew_get :index, page: 2, per_page: 10
        expect(assigns[:inspections].offset_value).to eq(10)
        expect(assigns[:inspections].limit_value).to eq(10)
      end
    end
    #
    # # Test for #3346
    # context "#new" do
    #   it "a new inspection has the current user assigned as a creator" do
    #     gesmew_get :new
    #     expect(assigns[:inspection].created_by).to eq(controller.try_gesmew_current_user)
    #   end
    # end
    #
    # # Regression test for #3684
    # context "#edit" do
    #   it "does not refresh rates if the inspection is completed" do
    #     allow(inspection).to receive_messages completed?: true
    #     expect(inspection).not_to receive :refresh_shipment_rates
    #     gesmew_get :edit, id: inspection.number
    #   end
    #
    #   it "does refresh the rates if the inspection is incomplete" do
    #     allow(inspection).to receive_messages completed?: false
    #     expect(inspection).to receive :refresh_shipment_rates
    #     gesmew_get :edit, id: inspection.number
    #   end
    # end
    #
    context "search" do
      let(:user) { create(:admin_user) }

      before do
        allow(controller).to receive_messages gesmew_current_user: user

        create(:inspection, completed_at: Date.today)
        expect(Gesmew::Inspection.count).to eq 1
      end

      it "does not display duplicated results" do
        gesmew_get :index, q: {
          number_cont: Gesmew::Inspection.first.number
        }
        expect(assigns[:inspections].count).to eq 1
      end
    end

    context "#grade_and_comment" do
      let(:inspection) {create(:inspection)}
      before do
        user = create(:admin_user)
        allow(controller).to receive(:try_gesmew_current_user).and_return(user)
      end
      it "it returns an assessment object and association id" do
        allow_pending_validations_after_callback
        gesmew_get :grade_and_comment, id: inspection.number
        expect(assigns[:assessment]).to be_a(Gesmew::RubricAssessment)
        expect(assigns[:association_id]).to be_an(Integer)
      end

      it "redirects back unless passes validiation" do
        gesmew_get :grade_and_comment, id: inspection.number
        expect(response).to redirect_to(redirect_to process_inspection_admin_inspection_url(inspection))
      end
    end

    # context "#close_adjustments" do
    #   let(:open) { double('open_adjustments') }
    #
    #   before do
    #     allow(adjustments).to receive(:where).and_return(open)
    #     allow(open).to receive(:update_all)
    #   end
    #
    #   it "changes all the open adjustments to closed" do
    #     expect(adjustments).to receive(:where).with(state: 'open')
    #       .and_return(open)
    #     expect(open).to receive(:update_all).with(state: 'closed')
    #     gesmew_post :close_adjustments, id: inspection.number
    #   end
    #
    #   it "sets the flash success message" do
    #     gesmew_post :close_adjustments, id: inspection.number
    #     expect(flash[:success]).to eql('All adjustments successfully closed!')
    #   end
    #
    #   it "redirects back" do
    #     gesmew_post :close_adjustments, id: inspection.number
    #     expect(response).to redirect_to(:back)
    #   end
    # end
  end

  # context '#authorize_admin' do
  #   let(:user) { create(:user) }
  #   let(:inspection) { create(:completed_inspection_with_totals, number: 'R987654321') }
  #
  #   def with_ability(ability)
  #     Gesmew::Ability.register_ability(ability)
  #     yield
  #   ensure
  #     Gesmew::Ability.remove_ability(ability)
  #   end
  #
  #   before do
  #     allow(Gesmew::Inspection).to receive_messages find: inspection
  #     allow(controller).to receive_messages gesmew_current_user: user
  #   end
  #
  #   it 'should grant access to users with an admin role' do
  #     user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
  #     gesmew_post :index
  #     expect(response).to render_template :index
  #   end
  #
  #   it 'should grant access to users with an bar role' do
  #     with_ability(BarAbility) do
  #       user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
  #       gesmew_post :index
  #       expect(response).to render_template :index
  #     end
  #   end
  #
  #   it 'should deny access to users with an bar role' do
  #     with_ability(BarAbility) do
  #       allow(inspection).to receive(:update_attributes).and_return true
  #       allow(inspection).to receive(:user).and_return Gesmew.user_class.new
  #       allow(inspection).to receive(:token).and_return nil
  #       user.gesmew_roles.clear
  #       user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')
  #       gesmew_put :update, id: inspection.number
  #       expect(response).to redirect_to('/unauthorized')
  #     end
  #   end
  #
  #   it 'should deny access to users without an admin role' do
  #     allow(user).to receive_messages has_gesmew_role?: false
  #     gesmew_post :index
  #     expect(response).to redirect_to('/unauthorized')
  #   end
  #
  #   it 'should restrict returned inspection(s) on index when using InspectionSpecificAbility' do
  #     number = inspection.number
  #
  #     3.times { create(:completed_inspection_with_totals) }
  #     expect(Gesmew::Inspection.complete.count).to eq 4
  #
  #     with_ability(InspectionSpecificAbility) do
  #       allow(user).to receive_messages has_gesmew_role?: false
  #       gesmew_get :index
  #       expect(response).to render_template :index
  #       expect(assigns['inspections'].size).to eq 1
  #       expect(assigns['inspections'].first.number).to eq number
  #       expect(Gesmew::Inspection.accessible_by(Gesmew::Ability.new(user), :index).pluck(:number)).to eq  [number]
  #     end
  #   end
  # end
  #
  # context "inspection number not given" do
  #   stub_authorization!
  #
  #   it "raise active record not found" do
  #     expect {
  #       gesmew_get :edit, id: 99999999
  #     }.to raise_error ActiveRecord::RecordNotFound
  #   end
  # end
end

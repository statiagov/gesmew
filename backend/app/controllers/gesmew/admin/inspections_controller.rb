module Gesmew
  module Admin
    class InspectionsController < Gesmew::Admin::BaseController
      before_action :initialize_inspection_events
      before_action :load_inspection, only: [:edit, :update, :cancel, :resume, :approve, :resend, :open_adjustments, :close_adjustments, :cart]

      respond_to :html

      def index
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Gesmew::Config[:show_only_complete_inspections_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
        params[:q][:completed_at_not_null] = '' unless @show_only_completed

        @includes_risky = true

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        if params[:q][:created_at_gt].present?
          params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
        end

        if params[:q][:created_at_lt].present?
          params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Inspection.accessible_by(current_ability, :index).ransack(params[:q])

        # lazyoading other models here (via includes) may result in an invalid query
        # e.g. SELECT  DISTINCT DISTINCT "gesmew_inspections".id, "gesmew_inspections"."created_at" AS alias_0 FROM "gesmew_inspections"
        @inspections = @search.result(distinct: true).includes(:inspectors).
          page(params[:page]).
          per(params[:per_page] || Gesmew::Config[:inspections_per_page])
        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def new
        @inspection = Inspection.create(inspection_params)
        redirect_to cart_admin_inspection_url(@inspection)
      end

      def edit
        can_not_transition_without_customer_info

        unless @inspection.completed?
          @inspection.refresh_shipment_rates(ShippingMethod::DISPLAY_ON_FRONT_AND_BACK_END)
        end
      end

      def cart
        unless @inspection.completed?
          @inspection.refresh_shipment_rates
        end
        if @inspection.shipments.shipped.count > 0
          redirect_to edit_admin_inspection_url(@inspection)
        end
      end

      def update
        if @inspection.update_attributes(params[:inspection]) && @inspection.line_items.present?
          @inspection.update!
          unless @inspection.completed?
            # Jump to next step if inspection is not completed.
            redirect_to admin_inspection_customer_path(@inspection) and return
          end
        else
          @inspection.errors.add(:line_items, Gesmew.t('errors.messages.blank')) if @inspection.line_items.empty?
        end

        render :action => :edit
      end

      def cancel
        @inspection.canceled_by(try_gesmew_current_user)
        flash[:success] = Gesmew.t(:inspection_canceled)
        redirect_to :back
      end

      def resume
        @inspection.resume!
        flash[:success] = Gesmew.t(:inspection_resumed)
        redirect_to :back
      end

      def approve
        @inspection.approved_by(try_gesmew_current_user)
        flash[:success] = Gesmew.t(:inspection_approved)
        redirect_to :back
      end

      def resend
        InspectionMailer.confirm_email(@inspection.id, true).deliver_later
        flash[:success] = Gesmew.t(:inspection_email_resent)

        redirect_to :back
      end

      def open_adjustments
        adjustments = @inspection.all_adjustments.where(state: 'closed')
        adjustments.update_all(state: 'open')
        flash[:success] = Gesmew.t(:all_adjustments_opened)

        respond_with(@inspection) { |format| format.html { redirect_to :back } }
      end

      def close_adjustments
        adjustments = @inspection.all_adjustments.where(state: 'open')
        adjustments.update_all(state: 'closed')
        flash[:success] = Gesmew.t(:all_adjustments_closed)

        respond_with(@inspection) { |format| format.html { redirect_to :back } }
      end

      private
        def inspection_params
          params[:created_by_id] = try_gesmew_current_user.try(:id)
          params.permit(:created_by_id, :user_id)
        end

        def load_inspection
          @inspection = Inspection.friendly.find(params[:id])
          authorize! action, @inspection
        end

        # Used for extensions which need to provide their own custom event links on the inspection details view.
        def initialize_inspection_events
          @inspection_events = %w{approve cancel resume}
        end

        def model_class
          Gesmew::Inspection
        end

        def excluded_states
          ['pending']
        end
    end
  end
end

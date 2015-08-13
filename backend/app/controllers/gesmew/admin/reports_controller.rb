module Gesmew
  module Admin
    class ReportsController < Gesmew::Admin::BaseController
      respond_to :html

      class << self
        def available_reports
          @@available_reports
        end

        def add_available_report!(report_key, report_description_key = nil)
          if report_description_key.nil?
            report_description_key = "#{report_key}_description"
          end
          @@available_reports[report_key] = {name: Gesmew.t(report_key), description: Gesmew.t(report_description_key)}
        end
      end

      def initialize
        super
        ReportsController.add_available_report!(:sales_total)
      end

      def index
        @reports = ReportsController.available_reports
      end

      def sales_total
        params[:q] = {} unless params[:q]

        if params[:q][:completed_at_gt].blank?
          params[:q][:completed_at_gt] = Time.zone.now.beginning_of_month
        else
          params[:q][:completed_at_gt] = Time.zone.parse(params[:q][:completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
        end

        if params[:q] && !params[:q][:completed_at_lt].blank?
          params[:q][:completed_at_lt] = Time.zone.parse(params[:q][:completed_at_lt]).end_of_day rescue ""
        end

        params[:q][:s] ||= "completed_at desc"

        @search = Inspection.complete.ransack(params[:q])
        @inspections = @search.result

        @totals = {}
        @inspections.each do |inspection|
          @totals[inspection.currency] = { :item_total => ::Money.new(0, inspection.currency), :adjustment_total => ::Money.new(0, inspection.currency), :sales_total => ::Money.new(0, inspection.currency) } unless @totals[inspection.currency]
          @totals[inspection.currency][:item_total] += inspection.display_item_total.money
          @totals[inspection.currency][:adjustment_total] += inspection.display_adjustment_total.money
          @totals[inspection.currency][:sales_total] += inspection.display_total.money
        end
      end

      private

      def model_class
        Gesmew::Admin::ReportsController
      end

      @@available_reports = {}

    end
  end
end

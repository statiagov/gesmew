require_dependency 'gesmew/api/controller_setup'

module Gesmew
  module Api
    class BaseController < ActionController::Base
      include Gesmew::Api::ControllerSetup
      include Gesmew::Core::ControllerHelpers::StrongParameters

      attr_accessor :current_api_user

      before_action :set_content_type
      before_action :load_user
      # before_action :authorize_for_order, if: Proc.new { order_token.present? }
      before_action :authenticate_user
      before_action :load_user_roles

      rescue_from ActionController::ParameterMissing, with: :error_during_processing
      rescue_from ActiveRecord::RecordInvalid, with: :error_during_processing
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from CanCan::AccessDenied, with: :unauthorized
      rescue_from Gesmew::Core::GatewayError, with: :gateway_error

      helper Gesmew::Api::ApiHelpers

      def map_nested_attributes_keys(klass, attributes)
        nested_keys = klass.nested_attributes_options.keys
        attributes.inject({}) do |h, (k,v)|
          key = nested_keys.include?(k.to_sym) ? "#{k}_attributes" : k
          h[key] = v
          h
        end.with_indifferent_access
      end

      def content_type
        case params[:format]
        when "json"
          "application/json; charset=utf-8"
        when "xml"
          "text/xml; charset=utf-8"
        end
      end

      private

      def set_content_type
        headers["Content-Type"] = content_type
      end

      def load_user
        @current_api_user = Gesmew.user_class.find_by(gesmew_api_key: api_key.to_s)
      end

      def authenticate_user
        return if @current_api_user

        if requires_authentication? && api_key.blank? && inspection_token.blank?
          render "gesmew/api/errors/must_specify_api_key", status: 401 and return
        elsif inspection_token.blank? && (requires_authentication? || api_key.present?)
          render "gesmew/api/errors/invalid_api_key", status: 401 and return
        else
          # An anonymous user
          @current_api_user = Gesmew.user_class.new
        end
      end

      def load_user_roles
        @current_user_roles = @current_api_user ? @current_api_user.gesmew_roles.pluck(:name) : []
      end

      def unauthorized
        render "gesmew/api/errors/unauthorized", status: 401 and return
      end

      def error_during_processing(exception)
        Rails.logger.error exception.message
        Rails.logger.error exception.backtrace.join("\n")

        unprocessable_entity(exception.message)
      end

      def unprocessable_entity(message)
        render text: { exception: message }.to_json, status: 422
      end

      def gateway_error(exception)
        @inspection.errors.add(:base, exception.message)
        invalid_resource!(@inspection)
      end

      def requires_authentication?
        Gesmew::Api::Config[:requires_authentication]
      end

      def not_found
        render "gesmew/api/errors/not_found", status: 404 and return
      end

      def current_ability
        Gesmew::Ability.new(current_api_user)
      end

      def invalid_resource!(resource)
        @resource = resource
        render "gesmew/api/errors/invalid_resource", status: 422
      end

      def api_key
        request.headers["X-Gesmew-Token"] || params[:token]
      end
      helper_method :api_key

      def inspection_token
        request.headers["X-Gesmew-Inspection-Token"] || params[:inspection_token]
      end

      def find_establishment(id)
        Gesmew::Establishment.friendly.find(id.to_s)
      rescue ActiveRecord::RecordNotFound
        Gesmew::Establishment.find(id)
      end

      def inspection_id
        params[:inspection_id] || params[:inspection_number]
      end

      def authorize_for_inspection
        @inspection = Gesmew::Inspection.find_by(number: order_id)
        authorize! :read, @inspection, inspection_token
      end

      protected
        def inspection
          @inspection ||= Gesmew::Inspection.includes(:inspectors).find_by(number: inspection_id)
          authorize! :update, @inspection
        end
    end
  end
end

module Gesmew
  module Admin
    class EstablishmentsController < ResourceController
      # helper 'gesmew/establishments'

      before_action :load_data, except: :index
      create.before :create_before
      update.before :update_before
      helper_method :clone_object_url

      def show
        session[:return_to] ||= request.referer
        redirect_to action: :edit
      end

      def index
        session[:return_to] = request.url
        respond_with(@collection)
      end

      def update
        if params[:establishment][:taxon_ids].present?
          params[:establishment][:taxon_ids] = params[:establishment][:taxon_ids].split(',')
        end
        if params[:establishment][:option_type_ids].present?
          params[:establishment][:option_type_ids] = params[:establishment][:option_type_ids].split(',')
        end
        invoke_callbacks(:update, :before)
        if @object.update_attributes(permitted_resource_params)
          invoke_callbacks(:update, :after)
          flash[:success] = flash_message_for(@object, :successfully_updated)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
            format.js   { render layout: false }
          end
        else
          # Stops people submitting blank slugs, causing errors when they try to
          # update the establishment again
          @establishment.slug = @establishment.slug_was if @establishment.slug.blank?
          invoke_callbacks(:update, :fails)
          respond_with(@object)
        end
      end

      def destroy
        @establishment = Establishment.friendly.find(params[:id])
        @establishment.destroy

        flash[:success] = Gesmew.t('notice_messages.establishment_deleted')

        respond_with(@establishment) do |format|
          format.html { redirect_to collection_url }
          format.js  { render_js_for_destroy }
        end
      end

      def clone
        @new = @establishment.duplicate

        if @new.save
          flash[:success] = Gesmew.t('notice_messages.establishment_cloned')
        else
          flash[:error] = Gesmew.t('notice_messages.establishment_not_cloned')
        end

        redirect_to edit_admin_establishment_url(@new)
      end

      def stock
        @variants = @establishment.variants.includes(*variant_stock_includes)
        @variants = [@establishment.master] if @variants.empty?
        @stock_locations = StockLocation.accessible_by(current_ability, :read)
        if @stock_locations.empty?
          flash[:error] = Gesmew.t(:stock_management_requires_a_stock_location)
          redirect_to admin_stock_locations_path
        end
      end

      protected

      def find_resource
        Establishment.with_deleted.friendly.find(params[:id])
      end

      def location_after_save
        Gesmew.edit_admin_establishment_url(@establishment)
      end

      def load_data
        @taxons = Taxon.inspection(:name)
        @option_types = OptionType.inspection(:name)
        @tax_categories = TaxCategory.inspection(:name)
        @shipping_categories = ShippingCategory.inspection(:name)
      end

      def collection
        return @collection if @collection.present?
        params[:q] ||= {}
        params[:q][:deleted_at_null] ||= "1"

        params[:q][:s] ||= "name asc"
        @collection = super
        # Don't delete params[:q][:deleted_at_null] here because it is used in view to check the
        # checkbox for 'q[deleted_at_null]'. This also messed with pagination when deleted_at_null is checked.
        if params[:q][:deleted_at_null] == '0'
          @collection = @collection.with_deleted
        end
        # @search needs to be defined as this is passed to search_form_for
        # Temporarily remove params[:q][:deleted_at_null] from params[:q] to ransack establishments.
        # This is to include all establishments and not just deleted establishments.
        @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })
        @collection = @search.result.
              distinct_by_establishment_ids(params[:q][:s]).
              includes(establishment_includes).
              page(params[:page]).
              per(params[:per_page] || Gesmew::Config[:admin_establishments_per_page])
        @collection
      end

      def create_before
        return if params[:establishment][:prototype_id].blank?
        @prototype = Gesmew::Prototype.find(params[:establishment][:prototype_id])
      end

      def update_before
        # note: we only reset the establishment properties if we're receiving a post
        #       from the form on that tab
        return unless params[:clear_establishment_properties]
        params[:establishment] ||= {}
      end

      def establishment_includes
        [{ variants: [:images], master: [:images, :default_price] }]
      end

      def clone_object_url(resource)
        clone_admin_establishment_url resource
      end

      private

      def variant_stock_includes
        [:images, stock_items: :stock_location, option_values: :option_type]
      end
    end
  end
end

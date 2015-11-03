module Gesmew
  module Admin
    class UsersController < ResourceController
      # rescue_from Gesmew::Core::DestroyWithInspectionsError, :with => :user_destroy_with_inspections_error

     after_action :sign_in_if_change_own_password, only: :update

     # http://spreecommerce.com/blog/2010/11/02/json-hijacking-vulnerability/
     before_action :check_json_authenticity, only: :index
     before_action :load_roles
     before_action :extract_roles_from_params, only: [:create, :update]

     def index
       respond_with(@collection) do |format|
         format.html
         format.json { render :json => json_data }
       end
     end

     def show
       redirect_to edit_admin_user_path(@user)
     end

     def create

       @user = Gesmew.user_class.new(user_params)
       if @user.save
         set_roles

         flash.now[:success] = flash_message_for(@user, :successfully_created)
         render :edit
       else
         render :new
       end
     end

     def update
       if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
         params[:user].delete(:password)
         params[:user].delete(:password_confirmation)
       end

       if @user.update_attributes(user_params)
         set_roles
         flash.now[:success] = Gesmew.t(:account_updated)
       end

       render :edit
     end

     def addresses
       if request.put?
         if @user.update_attributes(user_params)
           flash.now[:success] = Gesmew.t(:account_updated)
         end

         render :addresses
       end
     end

     def inspections
       params[:q] ||= {}
       @search = Gesmew::Inspection.reverse_chronological.ransack(params[:q].merge(user_id_eq: @user.id))
       @inspections = @search.result.page(params[:page]).per(Gesmew::Config[:inspections_per_page])
     end

     def items
       params[:q] ||= {}
       @search = Gesmew::Inspection.includes(:inspectors).ransack(params[:q].merge(user_id_eq: @user.id))
       @inspections = @search.result.page(params[:page]).per(Gesmew::Config[:inspections_per_page])
     end

     def generate_api_key
       if @user.generate_spree_api_key!
         flash[:success] = Gesmew.t('api.key_generated')
       end
       redirect_to edit_admin_user_path(@user)
     end

     def clear_api_key
       if @user.clear_spree_api_key!
         flash[:success] = Gesmew.t('api.key_cleared')
       end
       redirect_to edit_admin_user_path(@user)
     end

     def model_class
       Gesmew.user_class
     end

     protected

       def collection
         return @collection if @collection.present?
         if request.xhr? && params[:q].present?
           @collection = Gesmew.user_class.limit(params[:limit] || 100)
         else
           @search = Gesmew.user_class.ransack(params[:q])
           @collection = @search.result.page(params[:page]).per(Gesmew::Config[:inspections_per_page])
         end
       end

     private

     def set_roles
       if @roles_ids
         @user.spree_roles = Gesmew::Role.where(id: @roles_ids)
       end
     end

     def extract_roles_from_params
       if params[:user]
         @roles_ids = params[:user].delete("spree_role_ids")
       end
     end

     def user_params
       params.require(:user).permit(permitted_user_attributes |
                                    [:spree_role_ids])
     end

     # handling raise from Gesmew::Admin::ResourceController#destroy
     def user_destroy_with_inspections_error
       invoke_callbacks(:destroy, :fails)
       render status: :forbidden, text: Gesmew.t(:error_user_destroy_with_inspections)
     end

     # Allow different formats of json data to suit different ajax calls
     def json_data
       json_format = params[:json_format] || 'default'
       case json_format
       when 'basic'
         collection.map { |u| { 'id' => u.id, 'name' => u.email } }.to_json
       else
         address_fields = [:firstname, :lastname, :address1, :address2, :city, :zipcode, :phone, :state_name, :state_id, :country_id]
         includes = { only: address_fields, include: { state: { only: :name }, country: { only: :name } } }

         collection.to_json(only: [:id, :email], include:
                            { bill_address: includes, ship_address: includes })
       end
     end

     def sign_in_if_change_own_password
       if try_gesmew_current_user == @user && @user.password.present?
         sign_in(@user, event: :authentication, bypass: true)
       end
     end

     def load_roles
       @roles = Gesmew::Role.all
     end
    end
  end
end

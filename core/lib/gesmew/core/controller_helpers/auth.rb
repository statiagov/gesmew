module Gesmew
  module Core
    module ControllerHelpers
      module Auth
        extend ActiveSupport::Concern

        included do
          before_filter :set_guest_token
          helper_method :try_gesmew_current_user

          rescue_from CanCan::AccessDenied do |exception|
            redirect_unauthorized_access
          end
        end

        # Needs to be overriden so that we use Gesmew's Ability rather than anyone else's.
        def current_ability
          @current_ability ||= Gesmew::Ability.new(try_gesmew_current_user)
        end

        def redirect_back_or_default(default)
          redirect_to(session["gesmew_user_return_to"] || request.env["HTTP_REFERER"] || default)
          session["gesmew_user_return_to"] = nil
        end

        def set_guest_token
          unless cookies.signed[:guest_token].present?
            cookies.permanent.signed[:guest_token] = SecureRandom.urlsafe_base64(nil, false)
          end
        end

        def store_location
          # disallow return to login, logout, signup pages
          authentication_routes = [:gesmew_signup_path, :gesmew_login_path, :gesmew_logout_path]
          disallowed_urls = []
          authentication_routes.each do |route|
            if respond_to?(route)
              disallowed_urls << send(route)
            end
          end

          disallowed_urls.map!{ |url| url[/\/\w+$/] }
          unless disallowed_urls.include?(request.fullpath)
            session['gesmew_user_return_to'] = request.fullpath.gsub('//', '/')
          end
        end

        # proxy method to *possible* gesmew_current_user method
        # Authentication extensions (such as gesmew_auth_devise) are meant to provide gesmew_current_user
        def try_gesmew_current_user
          # This one will be defined by apps looking to hook into Gesmew
          # As per authentication_helpers.rb
          if respond_to?(:gesmew_current_user)
            gesmew_current_user
          # This one will be defined by Devise
          elsif respond_to?(:current_gesmew_user)
            current_gesmew_user
          else
            nil
          end
        end

        # Redirect as appropriate when an access request fails.  The default action is to redirect to the login screen.
        # Override this method in your controllers if you want to have special behavior in case the user is not authorized
        # to access the requested action.  For example, a popup window might simply close itself.
        def redirect_unauthorized_access
          if try_gesmew_current_user
            flash[:error] = Gesmew.t(:authorization_failure)
            redirect_to '/unauthorized'
          else
            store_location
            if respond_to?(:gesmew_login_path)
              redirect_to gesmew_login_path
            else
              redirect_to gesmew.respond_to?(:root_path) ? gesmew.root_path : main_app.root_path
            end
          end
        end

      end
    end
  end
end

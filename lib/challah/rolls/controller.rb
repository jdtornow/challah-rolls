module Challah::Rolls
  # These methods are added into ActionController::Base and are available in all
  # of your app's controllers.
  module Controller
    # @private
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Restrict the current controller to the given permission key. All actions in the
      # controller will be restricted unless otherwise stated. All normal options
      # for a before_filter are observed.
      #
      # If the current user does not have the given permission key, they are shown the
      # access denied message.
      #
      # @example
      #   class YourController < ApplicationController
      #     restrict_to_permission :manage_users
      #
      #     # ...
      #   end
      #
      # @example Restrict only the given actions
      #   class YourOtherController < ApplicationController
      #     restrict_to_permission :manage_users, :only => [ :create, :update, :destroy ]
      #
      #     # ...
      #   end
      #
      # @param [String, Symbol] permission_key The permission to restrict action(s) to.
      def restrict_to_permission(permission_key, options = {})
        before_filter(options) do |controller|
          unless controller.send(:has, permission_key)
            access_denied!
          end
        end
      end
      alias_method :permission_required, :restrict_to_permission
    end

    module InstanceMethods
      protected
        # Stop execution of the current action and display the access denied message.
        #
        # If the user is not logged in, they are redirected to the login screen.
        #
        # By default the built-in access denied message is displayed, but you can display a different
        # message by setting the following option in an initializer:
        #
        #   Challah.options[:access_denied_view] = 'controller/denied-view-name'
        #
        # A status code of :unauthorized (401) will be returned.
        #
        # Override this method if you'd like something different to happen when your users
        # get an access denied notification.
        def access_denied!
          if current_user?
            render :template => Challah.options[:access_denied_view], :status => :unauthorized and return
          else
            session[:return_to] = request.url
            redirect_to signin_path and return
          end
        end

        # Checks the current user to see if they have the given permission key. If there is
        # not a user currently logged in, false is always returned.
        #
        # @note This method is also available as a helper in your views.
        #
        # @example
        #   class SecureController < ApplicationController
        #     def index
        #       # Redirect anyone that doesn't have :see_secure_stuff permission.
        #       unless has(:see_secure_stuff)
        #         redirect_to root_path and return
        #       end
        #     end
        #   end
        #
        # @see AuthableUser::InstanceMethods#has User#has
        def has(permission_key)
          current_user and current_user.has(permission_key)
        end
        alias_method :permission?, :has
    end
  end
end
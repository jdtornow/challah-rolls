module Challah
  module Rolls
    require 'abstract_controller/rendering'

    class Engine < Rails::Engine
      initializer 'challah.rolls.active_record' do |app|
        ActiveSupport.on_load :active_record do
          Challah::Rolls::Engine.setup_active_record!
        end
      end

      initializer 'challah.rolls.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          Challah::Rolls::Engine.setup_action_controller!
        end
      end

      class << self
        # Set up controller methods
        def setup_action_controller!
          if defined?(ActionController)
            ActionController::Base.send(:include, Challah::Rolls::Controller)
            ActionController::Base.send(:helper_method, :has)
          end
        end

        # Set up active record with Challah methods
        def setup_active_record!
          if defined?(ActiveRecord)
            ActiveRecord::Base.send(:extend, Challah::Rolls::AuthablePermission)
            ActiveRecord::Base.send(:extend, Challah::Rolls::AuthablePermissionRole)
            ActiveRecord::Base.send(:extend, Challah::Rolls::AuthablePermissionUser)
            ActiveRecord::Base.send(:extend, Challah::Rolls::AuthableRole)
          end
        end
      end
    end
  end
end
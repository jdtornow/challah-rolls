module Challah
  module Rolls
    require 'abstract_controller/rendering'

    class Engine < Rails::Engine
    end
  end
end

Challah.register_plugin :rolls do
  on_load :action_controller do
    ActionController::Base.send(:include, Challah::Rolls::Controller)
    ActionController::Base.send(:helper_method, :has)
  end

  on_load :active_record do
    ActiveRecord::Base.send(:extend, Challah::Rolls::Permission)
    ActiveRecord::Base.send(:extend, Challah::Rolls::PermissionRole)
    ActiveRecord::Base.send(:extend, Challah::Rolls::PermissionUser)
    ActiveRecord::Base.send(:extend, Challah::Rolls::Role)
  end

  extend_user Challah::Rolls::User, :challah_rolls_user
end
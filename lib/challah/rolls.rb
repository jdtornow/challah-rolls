require 'challah/rolls/version'

module Challah
  module Rolls
    autoload :AuthablePermissionRole,           'challah/rolls/authable/permission_role'
    autoload :AuthablePermissionUser,           'challah/rolls/authable/permission_user'
    autoload :AuthablePermission,               'challah/rolls/authable/permission'
    autoload :AuthableRole,                     'challah/rolls/authable/role'
    autoload :AuthableUser,                     'challah/rolls/authable/user'

    autoload :Controller,                       'challah/rolls/controller'
  end
end

require 'challah/rolls/railtie' if defined?(Rails)
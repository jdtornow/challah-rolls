require 'challah/rolls/version'

module Challah
  module Rolls
    autoload :PermissionRole,                   'challah/rolls/permission_role'
    autoload :PermissionUser,                   'challah/rolls/permission_user'
    autoload :Permission,                       'challah/rolls/permission'
    autoload :Role,                             'challah/rolls/role'
    autoload :User,                             'challah/rolls/user'

    autoload :Controller,                       'challah/rolls/controller'
  end
end
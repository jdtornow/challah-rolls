module Challah
  module Rolls
    module User
      def challah_rolls_user
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
          extend ClassMethods
        end

        class_eval do
          validates :role_id,         :presence => true

          # Relationships
          ################################################################

          belongs_to :role,             :touch => true

          has_many :permission_users,   :dependent => :destroy

          has_many :permissions,        :through => :permission_users,
                                        :order => 'permissions.name'

          # Scoped Finders
          ################################################################

          scope :with_role,   lambda { |role| where([ "users.role_id = ?", role ]) }

          # Callbacks
          ################################################################

          after_save          :save_permission_keys
        end
      end

      module ClassMethods
        # Returns a scope of all users that are assigned with the given permission.
        # This takes into account permissions assigned by a user role, or permissions
        # given to a user on an ad-hoc basis.
        def find_all_by_permission(permission_id_or_key)
          permission = case permission_id_or_key
          when ::Permission
            permission_id_or_key
          when Symbol
            ::Permission[permission_id_or_key]
          else
            ::Permission.find_by_id(permission_id_or_key)
          end

          unless ::Permission === permission
            return self.scoped.limit(0)
          end

          user_ids = permission.permission_users.pluck(:user_id).to_a
          role_ids = permission.permission_roles.pluck(:role_id).to_a

          if user_ids.count.zero?
            self.where(:role_id => role_ids)
          else
            t = self.arel_table
            self.where(t[:role_id].in(role_ids).or(t[:id].in(user_ids)))
          end
        end
        alias_method :find_by_permission, :find_all_by_permission

        # Returns a scope of all users that are assigned to the given role.
        # Accepts a `Role` instance, a role_id, or a Symbol of the role name.
        def find_all_by_role(role_or_id_or_name)
          role_id = case role_or_id_or_name
          when ::Role
            role_or_id_or_name[:id]
          when Symbol
            ::Role[role_or_id_or_name][:id]
          else
            role_or_id_or_name
          end

          ::User.with_role(role_id)
        end
        alias_method :find_by_role, :find_all_by_role
      end

      # Instance methods to be included once authable_user is set up.
      module InstanceMethods
        # The default url where this user should be redirected to after logging in. Also can be used as the main link
        # at the top of navigation.
        def default_path
          role ? role.default_path : '/'
        end

        # Returns the permission keys in an array for exactly what this user can access.
        # This includes all role based permission keys, and any specifically given to this user
        # through permissions_users
        def permission_keys
          return @permission_keys if @permission_keys

          role_keys = if role(true)
            role_key = "#{role.cache_key}/permissions"

            keys = Rails.cache.fetch(role_key) do
              role.permission_keys.clone
            end

            Rails.cache.write(role_key, keys)
            keys
          else
            []
          end

          user_keys = Rails.cache.fetch(permissions_cache_key) do
            user_permission_keys.clone
          end

          user_keys = [] unless user_keys

          Rails.cache.write(permissions_cache_key, keys) unless new_record?

          @permission_keys = (role_keys + user_keys).uniq
        end

        # Returns true if this user has permission to the provided permission key
        def has(permission_key)
          self.permission_keys.include?(permission_key.to_s)
        end
        alias_method :permission?, :has

        # Set the permission keys that this role can access
        def permission_keys=(value)
          Rails.cache.delete(permissions_cache_key)

          @permission_keys = value
          @permission_keys
        end

        # When a role is set, reset the permission_keys
        def role_id=(value)
          @permission_keys = nil
          @user_permission_keys = nil

          self[:role_id] = value
        end

        # Returns the permission keys used by this specific user, does not include any role-based permissions.
        def user_permission_keys
          new_record? ? [] : self.permissions(true).collect(&:key)
        end

        # Allow dynamic checking for permissions
        #
        # +admin?+ is shorthand for:
        #
        #   def admin?
        #     has(:admin)
        #   end
        def method_missing(sym, *args, &block)
          return has(sym.to_s.gsub(/\?/, '')) if sym.to_s =~ /^[a-z_]*\?$/
          super(sym, *args, &block)
        end

        protected
          # The cache key to use for saving user permissions.
          def permissions_cache_key
            "#{self.cache_key}/permissions"
          end

          # Saves any updated permission keys to the database for this user.
          # Any permission keys that are specifically given to this user and are also in the
          # user's role will be removed. So, the only permission keys added here will be those
          # in addition to the user's role.
          def save_permission_keys
            if @permission_keys and Array === @permission_keys
              self.permission_users(true).clear

              @permission_keys = @permission_keys.uniq - self.role.permission_keys

              @permission_keys.each do |key|
                permission = ::Permission[key]

                if permission
                  self.permission_users.create({
                    :permission_id => permission.id,
                    :user_id => self.id
                    }, :without_protection => true)
                end
              end

              @permission_keys = nil
              @user_permission_keys = nil

              self.permissions(true).collect(&:key)
            end
          end
      end
    end
  end
end
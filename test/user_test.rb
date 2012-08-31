require 'helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :role_id

  should belong_to :role

  should have_many :permission_users
  should have_many :permissions

  context "A User class" do
    should "be able to find users by role" do
      admin_role = create(:administrator_role)
      another_role = create(:role, :name => 'Another')

      create_list(:user, 5, :role_id => admin_role.id)
      create_list(:user, 2, :role_id => another_role.id)

      assert_equal 7, User.count

      assert_equal 5, User.find_all_by_role(:administrator).count
      assert_equal 5, User.find_by_role(:administrator).count
      assert_equal 5, User.find_all_by_role(admin_role.id).count
      assert_equal 2, User.find_all_by_role(another_role).count
    end

    should "be able to find users by a permission" do
      # Set up admin role first so it gets all subsequent permissions
      admin_role = create(:administrator_role)

      # Create a fake permission for checking
      permission = create(:permission, :name => 'Test Permission', :key => 'test')

      # Create a new fake role to house the new permission
      role = build(:role, :name => 'Test Role')
      role.permission_keys = %w( test )
      role.save

      # Create another fake role that doesn't have permissions
      other_role = create(:role, :name => 'Another Role')

      # Add a few users in each of these roles
      create_list(:user, 3, :role_id => role.id)
      create_list(:user, 2, :role_id => admin_role.id)
      create_list(:user, 4, :role_id => other_role.id)

      # Make sure the roles are assigned to the permission
      assert_equal [ admin_role, role ].sort, permission.roles.sort

      # Make sure the users are assigned to the right roles
      assert_equal 3, role.users.count
      assert_equal 2, admin_role.users.count
      assert_equal 4, other_role.users.count

      # Create a few fake users that are not in these roles and manually
      # assign the permission to them
      user1 = build(:user, :role_id => other_role.id)
      user1.permission_keys = %w( test manage_users )
      user1.save

      user2 = build(:user, :role_id => other_role.id)
      user2.permission_keys = %w( test )
      user2.save

      # Check to make sure the users have the right keys
      assert_equal %w( manage_users test ), user1.permission_keys.sort
      assert_equal %w( test ), user2.permission_keys

      # Now we should be able to find users by a specific permission key
      assert_equal 7, User.find_all_by_permission(:test).count
      assert_equal 7, User.find_all_by_permission(Permission[:test]).count
      assert_equal 7, User.find_all_by_permission(permission).count
      assert_equal 7, User.find_all_by_permission(permission.id).count

      assert_equal 0, User.find_by_permission(nil).count

      assert_equal 2, User.find_all_by_permission(:admin).count
      assert_equal 3, User.find_by_permission(:manage_users).count
    end
  end

  context "A user instance" do
    should "have a default_path where this user will be sent upon login" do
      role = ::Role.new
      role.stubs(:default_path).returns('/role-path')

      user = ::User.new

      user.stubs(:role).returns(role)
      assert_equal '/role-path', user.default_path

      user.stubs(:role).returns(nil)
      assert_equal '/', user.default_path
    end

    should "get and set permission keys" do
      %w( run pass throw block ).each { |p| create(:permission, :key => p) }

      user = build(:user)

      user.stubs(:role).returns(::Role.new)
      user.role.stubs(:permission_keys).returns([])

      user.save

      assert_equal [], user.permission_keys

      user.permission_keys = %w( pass throw run )

      assert_difference 'PermissionUser.count', 3 do
        user.save
      end

      assert_equal true, user.pass?
      assert_equal true, user.has(:pass)
      assert_equal true, user.permission?(:pass)

      assert_equal true, user.run?
      assert_equal true, user.has(:run)
      assert_equal true, user.permission?(:run)

      assert_equal false, user.fake?
      assert_equal false, user.has(:fake)
      assert_equal false, user.permission?(:fake)

      assert_raises NoMethodError do
        user.does_not_exist
      end
    end
  end
end
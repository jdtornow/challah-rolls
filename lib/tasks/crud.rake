require 'highline/import'

namespace :challah do
  namespace :permissions do
    desc "Create a new permission"
    task :create => :environment do
      check_for_tables
      check_for_roles

      banner('Creating a permission')

      # Grab the required fields.
      name = ask('Permission name: ')
      key = name.to_s.parameterize.underscore
      key = ask('Key: ') { |q| q.default = key }
      description = ask('Description (optional): ')

      permission = Permission.new({ :name => name, :key => key, :description => description }, :without_protection => true)

      puts "\n"

      if permission.save
        puts "Permission has been created successfully! [ID: #{permission.id}]"
      else
        puts "Permission could not be added for the following errors:"
        permission.errors.full_messages.each { |m| puts "  - #{m}" }
      end
    end
  end

  namespace :roles do
    desc "Create a new role"
    task :create => :environment do
      check_for_tables
      check_for_roles

      banner('Creating a role')

      # Grab the required fields.
      name = ask('Name: ')
      description = ask('Description (optional): ')

      role = Role.new({ :name => name, :description => description }, :without_protection => true)

      puts "\n"

      if role.save
        puts "Role has been created successfully! [ID: #{role.id}]"
      else
        puts "Role could not be added for the following errors:"
        role.errors.full_messages.each { |m| puts "  - #{m}" }
      end
    end
  end
end

def banner(msg)
  puts "=========================================================================="
  puts "  #{msg}"
  puts "==========================================================================\n\n"
end

def check_for_roles
  unless Role.table_exists? and Role.count > 0 and !!Role.admin
    unless admin
      puts "Oops, you need to run `rake challah:rolls:setup` before you run this step, the administrator role is required."
      exit 1
    end
  end
end

def check_for_tables
  unless User.table_exists?
    puts "Oops, you need to run `rake challah:setup` before you create a user. The users table is required."
    exit 1
  end
end
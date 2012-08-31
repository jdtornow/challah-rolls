# Challah Rolls

[![Build Status](https://secure.travis-ci.org/jdtornow/challah-rolls.png)](http://travis-ci.org/jdtornow/challah-rolls) [![Dependency Status](https://gemnasium.com/jdtornow/challah-rolls.png?travis)](https://gemnasium.com/jdtornow/challah-rolls)

Challah (pronounced HAH-lah) Rolls is an extension to the [Challah](http://github.com/jdtornow/challah) gem that brings basic authorization support in the form of user roles and permissions.

** Note: Prior to Challah v0.8, this functionality was baked in to the main gem. Since then, the roles and permissions are included into this extension instead. **

## Requirements

* Ruby 1.9.2+
* Bundler
* Rails 3.1+
* Challah Gem 0.8+

## Installation

    gem install challah-rolls

Or, in your `Gemfile`

    gem 'challah-rolls'

## Set up

Once the gem has been set up and installed, run the following command to set up the database migrations:

    rake challah:setup:rolls

This will copy over the necessary migrations to your app, migrate the database and add some seed data. You will be prompted to add the first user as the last step in this process.

### Manual set up

If you would prefer to handle these steps manually, you can do so by using these rake tasks instead:

    rake challah:setup:rolls
    rake db:migrate
    rake challah:setup:rolls:seeds

### Creating permissions and roles

Since Challah doesn't provide any controller and views for permissions and roles there are a few handy rake tasks you can use to create new records.

The following tasks will prompt for the various attributes in each model:

    rake challah:permissions:create     # => Create a new Permission record
    rake challah:roles:create           # => Create a new Role record

## Models

Challah Rolls provides two additional models to your app: `Permission`, `Role`. By default, these models are hidden away in the Challah Rolls gem engine, but you can always copy the models into your app to make further modifications to the functionality.

### Permission

A permission is used to identify something within your application that you would like to restrict to certain users. A permission does not inherently have any functionality of its own and is just used as a reference point for pieces of functionality in your app. A permission record requires the presence of a name and key.

A permission's key is used throughout Challah to refer to this permission. Each key (and name) must be unique and will be used later to restrict access to functionality. Permission keys must be lowercase and contain only letters, numbers, and underscores.

If there is a role named 'Administrator' in your app, all permissions will be available to that role. Any new permissions that are added will also be automatically added to the 'Administrator' role, so this is a great role to use for anyone that needs to be able to do everything within your app.

The default Challah installation creates two permissions by default: `admin` and `manage_users`.

To unpack the `Permission` model into your app so you can extend it further, run:

    rake challah:unpack:permission        # => Copy the Permission model into your app

### Role

A role is used to group together various permissions and assign them to a user. Roles can also be thought of as user groups. Each role record requires a unique name.

Roles should only be used within your app to consolidate various permissions into logical groups. Roles are not intended to be used to restrict functionality, use permissions instead.

The default Challah installation creates two roles by default: 'Administrator' and 'Default'. Administrators have all permissions, now and in the future. Default users have no permissions other than being able to log in.

Once you've added a few other permissions, you can easily add them to a role. In this case, the `moderator` permission key is added to the default role:

    role = Role[:default]
    role.permission_keys = %w( moderator )
    role.save

To unpack the `Role` model into your app so you can extend it further, run:

    rake challah:unpack:role        # => Copy the Role model into your app

### User

Several modifications are made to the user model by Challah Rolls:

Each user is assigned to exactly one `Role` and can also be assigned to multiple `Permission` objects as needed. Because a user can be assigned to a role (and therefore its permissions) *and* permissions on an ad-hoc basis, it is important to always check a user record for restrictions based on permissions and not to use roles as a mechanism for restricting functionality in your app.

There are a few helpful scopes to help find users by role and for a particular role:

    User.find_all_by_role(:administrator)       # => Finds all users that are administrators
    User.find_all_by_permission(:manage_users)  # => Finds all users that have the :manage_users permission.

## Restricted access

One of the main reasons to use a user- and permission-based system is to restrict access to certain portions of your application. Challah Rolls provides basic restriction methods for your controllers, views and directly from any User instance.

### Checking for a permission

Since Challah is a permissions-based system, all restricted access should be performed by testing a user for the given permission.

Anywhere you can access a user instance, you can use the `has` method and pass in a single permission key to test that user for access:

    <ul>
      <li><a href="/">Home</a></li>

      <% if current_user? and current_user.has(:secret_stuff) %>
        <li><a href="/secret-stuff">Secret Stuff</a></li>
      <% end %>

      <li><a href="/public-stuff">Not-so-secret Stuff</a></li>
    </ul>

Notice that we checked for existence of the user before we checked to see if the user has a permission. If you used the `restrict_to_authenticated` method in your controller, you can likely skip this step.

Note: `current_user` will return `nil` if there is no user available, so checking for `current_user?` prevents you from calling `has` on `nil`.

For controller restrictions, use the `restrict_to_permission` method:

    class WidgetsController < ApplicationController
      restrict_to_permission :manage_widgets

      # ...
    end

The `restrict_to_permission` method will also fail if there is no user currently authenticated.

And, just as before, we can use the Rails filter options to limit the restriction to certain actions.

    class WidgetsController < ApplicationController
      restrict_to_permission :admin, :only => [ :destroy ]

      # ...
    end

And of course, you can stack up multiple restrictions get very specific about what your users can do:

    # Everyone can view index,
    # :manage_widgets users can perform basic editing
    # and, only :admins can delete
    #
    class WidgetsController < ApplicationController
      restrict_to_authenticated :only => [ :index ]
      restrict_to_permission :manage_widgets, :except => [ :index, :destroy ]
      restrict_to_permission :admin, :only => [ :destroy ]

      # ...
    end

Whichever method you use will yield the same results. Just make sure you are checking for a permission key, and not checking for a role. Checking for roles (i.e.: `user.role_id == 1`) is shameful practice. Use permissions!
## Full documentation

Documentation is available at: [http://rubydoc.info/gems/challah-rolls](http://rubydoc.info/gems/challah-rolls/frames)

## Example App

A fully-functional example app, complete with some basic tests, is available at [http://challah-example.herokuapp.com/](http://challah-example.herokuapp.com/).

The source code to the example is available at [https://github.com/jdtornow/challah-example](https://github.com/jdtornow/challah-example).

### Issues

If you have any issues or find bugs running Challah Rolls, please [report them on Github](https://github.com/jdtornow/challah-rolls/issues). While most functions should be stable, Challah is still in its infancy and certain issues may be present.

### Testing

Challah Rolls is fully tested using Test Unit, Shoulda and Mocha. To run the test suite, `bundle install` then run:

    rake test

## License

Challah Rolls is released under the [MIT license](http://www.opensource.org/licenses/MIT)

Contributions and pull-requests are more than welcome.

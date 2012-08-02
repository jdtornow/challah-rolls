namespace :challah do
  namespace :rolls do
    desc "Setup the challah-rolls gem within this rails app."
    task :setup => [ "challah:rolls:setup:migrations", "db:migrate", "challah:rolls:setup:seeds" ]

    desc "Insert the default users, roles and permissions."
    task :seeds => [ "challah:rolls:setup:seeds" ]

    namespace :setup do
      task :migrations do
        puts "Copying migrations..."
        ENV['FROM'] = 'challah_rolls_engine'
        Rake::Task['railties:install:migrations'].invoke
      end

      task :seeds => :environment do
        puts "Populating seed data..."
        Challah::Rolls::Engine.load_seed
      end
    end
  end
end
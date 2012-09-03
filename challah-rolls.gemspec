# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'challah/rolls/version'

Gem::Specification.new do |s|
  s.name          = "challah-rolls"
  s.version       = Challah::Rolls::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["John Tornow"]
  s.email         = ["john@johntornow.com"]
  s.homepage      = "http://github.com/jdtornow/challah-rolls"
  s.summary       = "Authorization extension for Challah and Rails."
  s.description   = %Q{A Challah plugin for basic roles and permissions in your Rails app.}
  s.files         = Dir.glob("{app,config,db,test,lib,vendor}/**/*") + %w(README.md CHANGELOG.md)
  s.require_paths = ["lib"]

  s.add_dependency 'challah', '>= 0.8.0'
  s.add_dependency 'highline'
  s.add_dependency 'rails', '>= 3.1'
  s.add_dependency 'rake', '>= 0.9.2'
  s.add_dependency 'bcrypt-ruby', '>= 0'

  s.required_ruby_version     = Gem::Requirement.new('>= 1.9.2')
end
# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cowtech-rails"
  s.version = "2.5.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shogun"]
  s.date = "2011-12-17"
  s.description = "A general purpose Rails utility plugin."
  s.email = "shogun_panda@me.com"
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "app/helpers/cowtech/ruby_on_rails/helpers/application_helper.rb",
    "app/helpers/cowtech/ruby_on_rails/helpers/ar_crud_helper.rb",
    "app/helpers/cowtech/ruby_on_rails/helpers/browser_helper.rb",
    "app/helpers/cowtech/ruby_on_rails/helpers/format_helper.rb",
    "app/helpers/cowtech/ruby_on_rails/helpers/mongoid_crud_helper.rb",
    "app/helpers/cowtech/ruby_on_rails/helpers/validation_helper.rb",
    "app/models/cowtech/ruby_on_rails/models/ar/model_base.rb",
    "app/models/cowtech/ruby_on_rails/models/e_mail.rb",
    "app/models/cowtech/ruby_on_rails/models/mongoid/cowtech.rb",
    "app/models/cowtech/ruby_on_rails/models/mongoid/logging.rb",
    "app/models/cowtech/ruby_on_rails/models/mongoid/sequence.rb",
    "app/models/cowtech/ruby_on_rails/models/scheduler.rb",
    "lib/cowtech.rb",
    "lib/cowtech/extensions.rb",
    "lib/cowtech/monkey_patches.rb",
    "lib/cowtech/tasks/app.rake",
    "lib/cowtech/tasks/log.rake",
    "lib/cowtech/tasks/mongodb.rake",
    "lib/cowtech/tasks/server.rake",
    "lib/cowtech/tasks/sql.rake",
    "lib/cowtech/version.rb",
    "rails/init.rb"
  ]
  s.homepage = "http://github.com/ShogunPanda/cowtech-rails"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "A general purpose Rails utility plugin."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cowtech-extensions>, [">= 0"])
    else
      s.add_dependency(%q<cowtech-extensions>, [">= 0"])
    end
  else
    s.add_dependency(%q<cowtech-extensions>, [">= 0"])
  end
end


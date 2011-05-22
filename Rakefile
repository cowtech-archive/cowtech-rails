require 'rubygems'
require 'jeweler'
require "./lib/cowtech/version.rb"

#begin
#  require 'yaml'
#  require 'psych'
#  YAML::ENGINE.yamler = 'psych'
#rescue LoadError => e
#  $stderr.puts e.message
#  $stderr.puts "Run `gem install psych` to install missing gems"
#  exit e.status_code
#end

Jeweler::Tasks.new do |gem|
  gem.name = "cowtech-rails"
  gem.homepage = "http://github.com/ShogunPanda/cowtech-rails"
  gem.license = "MIT"
  gem.summary = %Q{A general purpose Rails utility plugin.}
  gem.description = %Q{A general purpose Rails utility plugin.}
  gem.email = "shogun_panda@me.com"
  gem.authors = ["Shogun"]
  gem.version = Cowtech::Rails::Version::STRING
  gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "{rails}/**/*"]
end

Jeweler::RubygemsDotOrgTasks.new

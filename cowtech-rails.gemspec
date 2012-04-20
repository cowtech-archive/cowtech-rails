# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "./lib/cowtech/version"

Gem::Specification.new do |s|
	s.name = "cowtech-rails"
	s.version = Cowtech::Rails::Version::STRING
	s.authors = ["Shogun"]
	s.email = ["shogun_panda@me.com"]
	s.homepage = "http://github.com/ShogunPanda/cowtech-lib"
	s.summary = %q{A general purpose Rails utility plugin.}
	s.description = %q{A general purpose Rails utility plugin.}

	s.rubyforge_project = "cowtech-rails"
	s.files = `git ls-files`.split("\n")
	s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ["lib"]

	s.required_ruby_version = ">= 1.9.2"
	s.add_dependency "actionmailer"
	s.add_dependency "actionpack"
	s.add_dependency "activerecord"
	s.add_dependency "bson_ext"
	s.add_dependency "cowtech-extensions"
	s.add_dependency "mongoid"
	s.add_dependency "rake"
end
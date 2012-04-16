# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module RubyOnRails
		class AppUtils
			def self.run_command(cmd)
				IO.popen(cmd, "r") { |f| puts f.gets }
			end

			def self.get_version(as_string = true)
				info = YAML.load_file(Rails.root + "config/application_info.yml")
				(as_string ? "Current application info --- Version #{info["version"]} - Release date: #{info["release-date"]}" : info)
			end

			def self.set_version(info)
				puts "--- Setting application version ..."
				version = Cowtech::RubyOnRails::AppUtils.get_version(false)
				File.open(Rails.root + "config/application_info.yml", "w") { |f| f.write(version.merge(info.stringify_keys).to_yaml) }
				puts Cowtech::RubyOnRails::AppUtils.get_version
			end

			def self.tag
				info = Cowtech::RubyOnRails::AppUtils.get_version(false)
				tag = "v-#{info["version"]}"
				puts "--- Tagging current version as tag #{tag}"
				Cowtech::RubyOnRails::AppUtils.run_command("git tag -f #{tag}")
			end

			def self.commit(msg)
				# Commit data
				puts "--- Adding data to repository..."
				Cowtech::RubyOnRails::AppUtils.run_command("git add .")

				puts "--- Commiting changes ..."
				Cowtech::RubyOnRails::AppUtils.run_command("git commit -a --allow-empty-message -m \"#{msg}\"")
				puts "--- Checking repository status ..."
				Cowtech::RubyOnRails::AppUtils.run_command("git status")
			end

			def self.push
				puts "--- Pushing to server ..."
				run_command("git push server")
			end

			def self.clear_cache
				puts "--- Clearing rails cache ..."
				Rails.cache.clear
			end
		end
	end
end

namespace :app do
	namespace :version do
		desc "Get application info"
		task :get do |task|
			puts Cowtech::RubyOnRails::AppUtils.get_version
		end

		desc "Set application info"
		task :set, :version do |task, args|
			if args[:version] then
				Cowtech::RubyOnRails::AppUtils.set_version({"version" => args[:version], "release-date" => Time.now.strftime("%Y-%m-%d")})
			end
		end
	end

	desc "Clears all Rails cache"
	task clear_cache: :environment do |task|
		Cowtech::RubyOnRails::AppUtils.clear_cache
	end

	desc "Set application info, add all files and commits to git"
	task :commit, :message, :version do |task, args|
		args[:message] ||= ""

		Cowtech::RubyOnRails::AppUtils.set_version({"version" => args[:version], "release-date" => Time.now.strftime("%Y-%m-%d")}) if args[:version].present?
		Cowtech::RubyOnRails::AppUtils.commit(args[:message])
		Cowtech::RubyOnRails::AppUtils.tag if args[:version].present?
	end

	desc "Commit application and then push it to server"
	task :push, :message, :version do |task, args|
		Cowtech::RubyOnRails::AppUtils.set_version({"version" => args[:version], "release-date" => Time.now.strftime("%Y-%m-%d")}) if args[:version].present?
		Cowtech::RubyOnRails::AppUtils.commit(args[:message])
		Cowtech::RubyOnRails::AppUtils.tag if args[:version].present?
		Cowtech::RubyOnRails::AppUtils.push
	end

	desc "Tags current application version in git"
	task :tag do |task|
		Cowtech::RubyOnRails::AppUtils.tag
	end
end

namespace :css do
	desc "Regenerating CSS..."
	task regenerate: :environment do |task|
		puts "Regenerating CSS..."

		if defined?(Less) then # More
			puts "Using More"
			Rake::Task["more:clean"].execute
			Rake::Task["more:generate"].execute
		elsif defined?(Sass) # Sass
			Sass::Plugin.on_updating_stylesheet do |template, css|
				puts "[SCSS] Compiling #{template} to #{css} ..."
			end

			Sass::Plugin.force_update_stylesheets
		end
	end
end
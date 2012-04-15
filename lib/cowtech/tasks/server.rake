# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module RubyOnRails
		class ServerUtils
			@@yml_path = "config/server.yml"
			@@config = nil

			def self.thin_path; "config/thin.yml"; end
			def self.default_environment; "development"; end

			def self.load_config(force = false)
				begin
					@@config = YAML.load_file(Rails.root + @@yml_path) if @@config == nil || force == true
				rescue
					@@config = []
				end
				@@config
			end

			def self.save_config(args = nil)
				args = Cowtech::RubyOnRails::ServerUtils.load_config if !args
				File.open(Rails.root + @@yml_path, "w") { |f| f.write(YAML::dump(args)) }
			end

			def self.stringify_keys(hash)
				rv = {}
				hash.each { |k, v| rv[k.to_s] = v }
				rv
			end

			def self.merge(base, other)
				rv = {}
				base.each { |k, v| rv[k] = (other[k] ? other[k] : v)  }
				rv
			end

			def self.run_command(cmd)
				system(cmd)
			end
		end

		class Cowtech::RubyOnRails::ThinServer < Cowtech::RubyOnRails::ServerUtils
			def self.prepare(rake_args)
				self.load_config
				Cowtech::RubyOnRails::ThinServer.merge(@@config["thin"], Cowtech::RubyOnRails::ThinServer.stringify_keys(rake_args))
			end

			def self.start(rake_args)
				args = self.prepare(rake_args)
				@@config["thin"] = args
				Cowtech::RubyOnRails::ThinServer.save_config
				puts "--- Starting thin server with config file #{args["config"]} in environment #{args["environment"]}..."
				Cowtech::RubyOnRails::ThinServer.execute("start", args["config"], args["environment"])
			end

			def self.stop(rake_args)
				args = self.prepare(rake_args)
				puts "--- Stopping Thin server ..."
				Cowtech::RubyOnRails::ThinServer.execute("stop", args["config"], args["environment"])
			end

			def self.restart(rake_args)
				args = self.prepare(rake_args)
				puts "--- Restarting thin server with config file #{args["config"]} in environment #{args["environment"]}..."
				Cowtech::RubyOnRails::ThinServer.execute("restart", args["config"], args["environment"])
			end

			def self.execute(command, config, environment)
				run_command("thin -C #{config} -e #{environment} #{command}")
			end

			def self.test
				puts "--- Testing thin server in the foreground"
				run_command("thin start")
			end
		end
	end
end

namespace :server do
	namespace :thin do
		desc "Starts Thin server"
		task :start, ["environment", "config"],  do |task, rake_args|
			Cowtech::RubyOnRails::ThinServer.start(rake_args.with_defaults("config" => Cowtech::RubyOnRails::ServerUtils.thin_path, "environment" => Cowtech::RubyOnRails::ServerUtils.default_environment))
		end

		desc "Stops Thin server"
		task :stop, ["environment", "config"] do |task, rake_args|
			Cowtech::RubyOnRails::ThinServer.stop(rake_args.with_defaults("config" => nil, "environment" => nil))
		end

		desc "Restarts Thin server"
		task :restart, ["environment", "config"] do |task, rake_args|
			Cowtech::RubyOnRails::ThinServer.restart(rake_args.with_defaults("config" => nil, "environment" => nil))
		end

		desc "Tests Thin server into the foreground"
		task :test do |task|
			Cowtech::RubyOnRails::ThinServer.test
		end
	end
end
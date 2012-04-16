# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module RubyOnRails
		class Scheduler
			attr_accessor :application
			attr_accessor :logger
			attr_accessor :pid
			attr_accessor :definitions
			attr_accessor :scheduler

			def self.start(application_class, log_file, pid_file, &definitions)
				self.new(application_class, log_file, pid_file, definitions).execute
			end

			def self.log(msg)
				puts msg
				#@@class_logger ||= Logger.new(Rails.root.to_s + "/log/scheduler.log")
				#@@class_logger.debug(msg)				
			end

			def initialize(application_class, log_file, pid_file, block = nil, &definitions)
				@application = application_class
				@logger = Logger.new(log_file)
				@pid = pid_file.to_s
				@definitions = block || definitions
				@scheduler = Rufus::Scheduler.start_new
				@rake_loaded = false
			end

			def log_string(message, options = {})
				rv = ""

				rv += "[#{Time.now.strftime("%Y-%m-%d %T")}] " if !options[:no_time]
				rv += options[:prefix].ensure_array.collect { |p| "[" + p.center(6, " ") + "]" }.join(" ")  + " " if options[:prefix].present?
				rv += message

				rv
			end

			def log(message, options = {})
				msg = self.log_string(message, options)
				type = options[:type] || :info
				(options[:logger] || @logger).send(type, msg)
			end

			def execute_rake_task(label, name, args)
				begin
					args = args.symbolize_keys
					args_string = args.present? ? " with arguments #{args.to_json}" : ""

					task = Rake::Task[name]
					values = task.arg_names.collect { |a| args[a.to_sym] }

					self.log(label + args_string + " ...", {prefix: ["RAKE", "START", name]})
					task.reenable
					task.invoke(*values)
					self.log("Rake task ended.", {prefix: ["RAKE", "END", name]})
				rescue Exception => e
					self.log("Rake task failed with exception: [#{e.class.to_s}] #{e.to_s}.", {prefix: ["RAKE", "ERROR", name]})
				end
			end

			def execute_inline_task(label, name)
				begin
					self.log(label + " ...", {prefix: ["INLINE", "START", name]})
					yield if block_given?
					self.log("Inline task ended.", {prefix: ["INLINE", "END", name]})
				rescue Exception => e
					self.log("Inline task failed with exception: [#{e.class.to_s}] #{e.to_s}.", {prefix: ["RAKE", "ERROR", name]})
				end
			end

			def execute
				self.log("Scheduler started.", {prefix: "MAIN"})
				self.handle_plain
			end

			def handle_phusion_passenger
				if defined?(PhusionPassenger) then
					File.delete(@pid) if FileTest.exists?(@pid)

					PhusionPassenger.on_event(:starting_worker_process) do |forked|
						if forked && !FileTest.exists?(@pid) then
							self.log("Starting process with PID #{$$}", {prefix: ["WORKER", "START"]})
							File.open(@pid, "w") { |f| f.write($$) }
							self.handle_plain
						end
					end

					PhusionPassenger.on_event(:stopping_worker_process) do
						if FileTest.exists?(@pid) then
							if File.open(@pid, "r") { |f| pid = f.read.to_i} == $$ then
								self.log("Stopped process with PID #{$$}", {prefix: ["WORKER", "STOP"]})
								File.delete(@pid)
							end
						end
					end
				else
					self.handle_plain
				end
			end

			def handle_plain
				if !@rake_loaded then
					@application.load_tasks
					@rake_loaded = true
				end

				@definitions.call(self)
			end

			def method_missing(method, *args, &block)
				self.scheduler.send(method, *args, &block)
			end
		end
	end
end

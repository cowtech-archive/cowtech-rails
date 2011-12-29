# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    class LogUtils
      @@log_compressor_command = "bzip2"
      @@log_compressed_extension = "bz2"

      def self.generate_new_name(base, i = 0)
        (Rails.root + "backups/logs/#{base}#{if i > 0 then "-#{i}" else "" end}").to_s  
      end

      def self.run_command(cmd)
        IO.popen(cmd) do |f| print f.gets end
      end

      def self.rotate(rake_args)
        Cowtech::RubyOnRails::Scheduler.log "Rotating log files..."
    
        # Get timestamp
        tstamp = Time.now.strftime("%Y%m%d")

        # For each log file
        Dir.glob(Rails.root + "log/*.log") do |log_file|
          Cowtech::RubyOnRails::Scheduler.log "\tRotating #{log_file} ..."
          new_name = "#{File.basename(log_file)}-#{tstamp}" # CREIAMO IL NOME
      
          # Resolv duplicates
          i = 0
          new_file = catch(:name) do
            i += 1
            name = generate_new_name(new_name, i)
            redo if File.exists?(name . + "." + @@log_compressed_extension)
            throw :name, name
          end

          dir = File.dirname(new_file)
          FileUtils.mkdir_p(dir) if !File.directory?(dir)
      
          # Send file via mail
					if (Rails.env == "production" || rake_args["force"].to_boolean) && rake_args["email_class"].present? then
						Cowtech::RubyOnRails::Scheduler.log "\tForwarding log file to requested email address..."
	        	rake_args["email_class"].constantize.log_report(log_file).deliver
					end

          # Copy file
          FileUtils.cp(log_file, new_file)
      
          # BZIPPIAMO IL FILE
          system(@@log_compressor_command, new_file)
        end
    
        # Truncate files
        Cowtech::RubyOnRails::Scheduler.log "Truncating current log files ..."
        Dir.glob(Rails.root + "log/*.log") do |log_file|
          File.open(log_file, "w").close
        end
      end
  
      def self.clean
        Cowtech::RubyOnRails::Scheduler.log "Cleaning log files..."
  
        ["backups/logs/*.log", "backups/logs/*.#{@@log_compressed_extension}"].each do |path|
          Dir.glob(Rails.root + path) do |log_file|
            Cowtech::RubyOnRails::Scheduler.log "\tDeleting #{log_file.gsub(Rails.root.to_s + "/", "")} ..."
            File.delete(log_file)
          end
        end
      end
    end
  end
end

namespace :log do
  desc "Rotates log files"
  task :rotate, [:email_class, :force] => [:environment] do |task, args|
    Cowtech::RubyOnRails::LogUtils.rotate(args)
  end
  
  desc "Clean every log file"
  task :clean do |task|
    Cowtech::RubyOnRails::LogUtils.clean
  end
end

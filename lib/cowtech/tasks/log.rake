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

      def self.generate_new_name(base, i = 0); "#{base}#{if i > 0 then "-#{i}" else "" end}"  end

      def self.run_command(cmd)
        IO.popen(cmd) do |f| print f.gets end
      end
  
      def self.rotate(email_class = nil)
        puts "Rotating log files..."
    
        # Get timestamp
        tstamp = Time.now.strftime("%Y%m%d")

        # For each log file
        Dir.glob(Rails.root + "log/*.log") do |log_file|
          puts "\tRotating #{log_file} ..."
          new_name = "#{log_file}-#{tstamp}" # CREIAMO IL NOME
      
          # Resolv duplicates
          i = 0
          i += 1 while File.exists?("#{generate_new_name(new_name, i)}.#{@@log_compressed_extension}")
          new_file = generate_new_name(new_name, i)
      
          # Send file via mail
          email_class.constantize.log_report(log_file).deliver if Rails.env == "production" && email_class.present?

          # Copy file
          FileUtils.cp(log_file, new_file)
      
          # BZIPPIAMO IL FILE
          system(@@log_compressor_command, new_file)
        end
    
        # Truncate files
        puts "Truncating current log files ..."
        Dir.glob(Rails.root + "log/*.log") do |log_file|
          File.open(log_file, "w").close
        end
      end
  
      def self.clean
        puts "Cleaning log files..."
  
        ["log/*.log", "log/*.#{@@log_compressed_extension}"].each do |path|
          Dir.glob(Rails.root + path) do |log_file|
            puts "\tDeleting #{log_file.gsub(Rails.root.to_s + "/", "")} ..."
            File.delete(log_file)
          end
        end
      end
    end
  end
end

namespace :log do
  desc "Rotates log files"
  task :rotate, [:email_class] => [:environment] do |task, args|
    Cowtech::RubyOnRails::LogUtils.rotate(args[:email_class])
  end
  
  desc "Clean every log file"
  task :clean do |task|
    Cowtech::RubyOnRails::LogUtils.clean
  end
end

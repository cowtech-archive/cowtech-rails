# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#
module Cowtech
  module RubyOnRails
    class MongoUtils
      @@log_compressor_command = "tar cjvf"
      @@log_compressed_extension = "tbz2"

      def self.run_command(cmd); system(cmd) end

      def self.backup
        puts "--- Backupping MongoDB ..."
        
        # Get configuration
        mongo_config = YAML.load_file(Rails.root + "config/mongoid.yml")
        databases = mongo_config["backup_databases"].as_s.split(/\s*,\s*/)        
        return if databases.blank?

        # Set output dir
        dest_file = Rails.root + "backups/mongodb/mongo-#{Time.now.strftime("%Y%m%d-%H%M%S")}"

        # Create directory
        dir = File.dirname(dest_file)
        FileUtils.mkdir_p(dir) if !File.directory?(dir)
        
        databases.each do |db|
          puts "\t\tBackupping DB #{db} ..."

          dump_cmd = "mongodump"
          dump_args = {"" => "-o \"#{dest_file}\"", "database" => "-d #{db}"}

          # Execute command
          puts "\t\tDumping data ..."
          Cowtech::RubyOnRails::MongoUtils.run_command(dump_cmd + " " + dump_args.values.join(" "))
        end
        
        # Compress
        puts "\t\tCompressing backup ..."
        Cowtech::RubyOnRails::MongoUtils.run_command(@@log_compressor_command + " " + dest_file.to_s + "." + @@log_compressed_extension + " " + dest_file.to_s)
        FileUtils.rm_rf(dest_file.to_s)
  
        puts "Backup saved in #{dest_file}.#{@@log_compressed_extension}"
      end

      def self.backup_clean
        puts "--- Cleaning database backup files ..."

        ["backups/mysql/*.sql", "backups/mysql/backup/*.#{@@log_compressed_extension}"].each do |path|
          Dir.glob(Rails.root + path) do |log_file|
            puts "\tDeleting #{log_file.gsub(Rails.root.to_s + "/", "")} ..."
            File.delete(log_file)
          end
        end
      end
    end
  end
end

namespace :mongodb do
  desc "Backups MongoDB collections"
  task :backup do |task|
    Cowtech::RubyOnRails::MongoUtils.backup
  end
  
  desc "Clean every backup file"
  task :backup_clean do |task|
    Cowtech::RubyOnRails::MongoUtils.backup_clean    
  end
end
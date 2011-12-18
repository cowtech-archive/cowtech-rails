# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    class MysqlUtils
      @@log_compressor_command = "bzip2"
      @@log_compressed_extension = "bz2"

      def self.run_command(cmd); system(cmd) end

      def self.mysql_execute(config, rake_args)
        dest_file = Rails.root + "backups/mysql/mysql-#{Time.now.strftime("%Y%m%d-%H%M%S")}.sql"
    		final_file = dest_file.to_s + "." + @@log_compressed_extension
		
        dump_cmd = "mysqldump"
        dump_args = {"" => "-R -r \"#{dest_file}\"", "host" => "-h @@ARG@@", "username" => "-u @@ARG@@", "password" => "--password=\"@@ARG@@\"", "database" => "@@ARG@@"}

        # Build command
        args = dump_args.dup
        args.keys.each do |k|
          if k == "" || config[k] then
            args[k].gsub!("@@ARG@@", config[k] || "")
          else
            args.delete(k)
          end
        end
    
        # Create directory
        dir = File.dirname(dest_file)
        FileUtils.mkdir_p(dir) if !File.directory?(dir)
    
        # Execute command
        Cowtech::RubyOnRails::Models::Scheduler.log "\tDumping data ..."
        Cowtech::RubyOnRails::MysqlUtils.run_command(dump_cmd + " " + dump_args.values.join(" "))
    
        # Compress
        Cowtech::RubyOnRails::Models::Scheduler.log "\tCompressing backup ..."
        Cowtech::RubyOnRails::MysqlUtils.run_command(@@log_compressor_command + " " + dest_file.to_s)
    
        # Send file via mail
				if (Rails.env == "production" || rake_args["force"].to_boolean) && rake_args["email_class"].present? then
					Cowtech::RubyOnRails::Models::Scheduler.log "\tForwarding backup file to requested email address..."
        	rake_args["email_class"].constantize.backup(final_file).deliver
				end

        Cowtech::RubyOnRails::Models::Scheduler.log "Backup saved in #{final_file}"
      end

      # ALIAS
      class << self
        alias_method :mysql2_execute, :mysql_execute
      end
    end
    
    class SqlUtils
      @@log_compressor_command = "bzip2"
      @@log_compressed_extension = "bz2"

      def self.to_fixtures
        Cowtech::RubyOnRails::Models::Scheduler.log "--- Dumping database into fixtures ..."
        sql = "SELECT * FROM %s" 
        skip_tables = ["schema_info"] 
        ActiveRecord::Base.establish_connection 
        (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name| 
          Cowtech::RubyOnRails::Models::Scheduler.log "--- --- Dumping table #{table_name} ..."
          i = "01" 
          File.open("#{RAILS_ROOT}/test/fixture/#{table_name}.yml", 'w') do |file| 
            data = ActiveRecord::Base.connection.select_all(sql % table_name) 
            file.write data.inject({}) { |hash, record| 
              hash["#{table_name}_#{i.succ!}"] = record 
              hash 
            }.to_yaml 
          end 
        end 
      end

      def self.backup(rake_args)
        Cowtech::RubyOnRails::Models::Scheduler.log "--- Backupping database ..."
        # OTTENIAMO LA CONFIGURAZIONE
        db_config = YAML.load_file(Rails.root + "config/database.yml")
        env = Rails.env

        # ESEGUIAMO
        Cowtech::RubyOnRails::MysqlUtils.send("#{db_config[env]["adapter"]}_execute", db_config[env], rake_args)
      end

      def self.backup_clean
        Cowtech::RubyOnRails::Models::Scheduler.log "--- Cleaning database backup files ..."

        ["backups/mysql/*.sql", "backups/mysql/backup/*.#{@@log_compressed_extension}"].each do |path|
          Dir.glob(Rails.root + path) do |log_file|
            Cowtech::RubyOnRails::Models::Scheduler.log "\tDeleting #{log_file.gsub(Rails.root.to_s + "/", "")} ..."
            File.delete(log_file)
          end
        end
      end
    end
  end
end

namespace :mysql do
  desc 'Converting data to fixtures' 
  task :to_fixtures => :environment do 
    Cowtech::RubyOnRails::SqlUtils.to_fixtures
  end 
  
  desc "Backups database"
  task :backup, [:email_class, :force] => [:environment] do |task, args|
    Cowtech::RubyOnRails::SqlUtils.backup(args)
  end
  
  desc "Clean every backup file"
  task :backup_clean do |task|
    Cowtech::RubyOnRails::SqlUtils.backup_clean
  end
end
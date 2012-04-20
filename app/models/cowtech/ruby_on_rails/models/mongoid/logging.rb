# encoding: utf-8
#
# This file is part of the Gestione Exodus Comics application. Copyright (C) 2010 and above Paolo Insogna <p.insogna@me.com>.
# Licensed as stated in the COPYRIGHT file, which can be found in the root of the application.
#

module Cowtech
	module RubyOnRails
		module Models
			module Mongoid
				module Logging
					extend ActiveSupport::Concern

					included do
						set_callback(:create, :after) { |d| d.log_activity(:create) }
						set_callback(:update, :after) { |d| d.log_activity(:update) }
					end

					def delete(options = {})
						log_activity(:delete)
						super(options)
					end

					def restore
						log_activity(:restore)
						super
					end
				end
			end
		end
	end
end
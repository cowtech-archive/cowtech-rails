# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module DebugHelper
				attr_reader :debug_msg
			
				def debug_timestamp
					"[" + Time.now.strftime("%F %T.%L %z") + "]"
				end
				
				def debug_file
					@debug_file ||= Logger.new(Rails.root + "log/debug.log")
				end
				
				def debug_msgs
					@debug_msgs ||= []
				end
				
				def debug_dump_object(object, target = nil, method = :to_yaml)
					self.debug_log("OBJECT DUMP", object.send(method).ensure_string, target)
				end
				
				def debug_log(tags, msg, target = nil, no_timestamp = false)
					tags = tags.ensure_array if tags.present?
					
					final_msg = []					
					final_msg << self.debug_timestamp if !no_timestamp
					tags.collect { |tag| "[" + tag + "]" }.each { |tag| final_msg << tag } if tags.present?
					final_msg << msg					
					final_msg = final_msg.join(" ")
					
					if !target.nil? && target.respond_to?(:debug) then
						self.debug_file.debug(final_msg)
					else
						self.debug_msgs << final_msg
					end
				end
			end
		end
	end
end
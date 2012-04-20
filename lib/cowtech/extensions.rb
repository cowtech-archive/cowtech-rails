# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

if defined?(SubdomainFu) then
	module SubdomainFu
		def self.override_only_path?
			true
		end
	end
end

module Cowtech
	module RubyOnRails
		module Extensions
			module AR
				extend ActiveSupport::Concern

				module ClassMethods
					def find_or_create(oid, attributes = nil)
						begin
							self.find(oid)
						rescue ActiveRecord::RecordNotFound
							self.new(attributes)
						end
					end

					def safe_find(oid)
						begin
							rv = self.find(oid)
						rescue ActiveRecord::RecordNotFound
							nil
						end
					end

					def random
						c = self.count
						c != 0 ? self.find(:first, offset: rand(c)) : nil
					end

					def per_page
						25
					end
				end
			end
		end
	end
end
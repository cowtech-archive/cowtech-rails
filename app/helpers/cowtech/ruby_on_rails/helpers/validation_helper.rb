# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module ValidationHelper
        def exists?(cls, query, params)
          cls.constantize.where(query, params).count > 0
        end

        def json_is_available?(cls, query, params, must_exists = false, internal = false)
          rv = self.setup_json_response(:validator)

          rv["success"] = true
          rv["valid"] = (self.exists?(cls, query, params) == must_exists)

          if internal then
            rv
          else
            custom_respond_with(rv.to_json)
          end
        end
        
        def valid_email?(field)
          /^([a-z0-9_\.\-\+]+)@([\da-z\.\-]+)\.([a-z\.]{2,6})$/i.match(field.to_s) != nil
        end

        def valid_phone?(field)
          /^(((\+|00)\d{1,4}\s?)?(\d{0,4}\s?)?(\d{5,}))?$/i.match(field.to_s) != nil
        end

        def valid_letter?(field)
          /^([a-z])$/i.match(field.to_s) != nil
        end

        def valid_number?(field)
          field.to_s.is_valid_float?
        end

        def valid_date?(field)
          begin
            DateTime.strptime(field.to_s, "%d/%m/%Y")
            true
          rescue ArgumentError
            false
          end
        end

        def valid_time?(field)
          begin
            DateTime.strptime(field.to_s, "%H:%M")
            true
          rescue ArgumentError
            false
          end
        end

        def valid_piva?(field)
          /^([0-9A-Z]{11,17})$/i.match(field.to_s) != nil
        end

        def valid_cf?(field)
          /^([0-9A-Z]{16})$/i.match(field.to_s) != nil
        end

        def valid_cap?(field)
          /^([0-9]{5})$/i.match(field.to_s) != nil
        end

        def valid_password?(field)
          field.to_s.length >= 8
        end
      end
    end
  end
end
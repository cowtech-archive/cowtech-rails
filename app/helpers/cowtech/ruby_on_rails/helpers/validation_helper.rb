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
      end
    end
  end
end
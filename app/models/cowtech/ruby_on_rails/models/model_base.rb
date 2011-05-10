# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Models
      class ModelBase < ::ActiveRecord::Base
        def safe_id
          if self.id then self.id else 0 end
        end
        
        def editable?(user = nil)
          true
        end
  
        def deletable?(user = nil)
          true
        end
  
        def delete(definitive = false)
          super()
        end
      end
    end
  end
end

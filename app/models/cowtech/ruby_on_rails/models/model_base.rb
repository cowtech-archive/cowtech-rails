# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Models
      class ModelBase < ::ActiveRecord::Base
        def self.deleted_column
          "deleted"
        end
        
        def self.status_column
          "status_id"
        end
        
        def self.deleted_status_id
          0
        end
        
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
          if !definitive then
            if self.deletable? then
              if self.has_attribute?(self.deleted_column) then
                self.update_attribute(self.deleted_column, true)
                true
              elsif self.has_attribute?(self.status_column) then
                self.update_attribute(self.status_column, self.deleted_status)
                true
              else
                super()
              end
            else
              false
            end
          else
            super()
          end
        end
      end
    end
  end
end

# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Models
      class ModelBase < ::ActiveRecord::Base
        def deleted_column
          "deleted"
        end
        
        def status_column
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
              if self.respond_to?(self.deleted_column) then
                self.send(self.deleted_column, true)
                self.save
                true
              elsif self.respond_to?(self.status_column) then
                self.send(self.status_column, self.deleted_status)
                self.save
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

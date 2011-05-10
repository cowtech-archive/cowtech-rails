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
        
        def self.[](what, only_id = false)
          self.__finalize(self.__index_find(what), only_id) 
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
              if self.has_attribute?(self.class.deleted_column) then
                self.update_attribute(self.class.deleted_column, true)
                true
              elsif self.has_attribute?(self.class.status_column) then
                self.update_attribute(self.class.status_column, self.deleted_status)
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
        
        def ==(other)
          if other.class.to_s != self.class.to_s then
            self.id == self.class.__index_find(other).id
          else
            super
          end
        end

        def !=(other)
          ! (self == other)
        end
        
        private
          def self.__index_find(what)
            self.find(what)
          end
          
          def self.__finalize(record, only_id = false)
            only_id ? record.id : record
          end          
      end
    end
  end
end

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
  
        # TODO: Internationalize this. :eliminato => :deleted, :stato => :status, Stato => Status
        def delete(definitive = false)
          unless definitive then
            if self.deletable? then
              if self.respond_to?(:eliminato) then
                self.eliminato = true
                self.save
                true
              elsif self.respond_to?(:stato) then
                self.stato = Stato[:eliminato]
                self.save
                true
              else
                super()
              end
            else
              false
            end
          else
            super(definitive)
          end
        end
      end
    end
  end
end

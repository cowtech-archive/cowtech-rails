# encoding: utf-8
#
# This file is part of the Gestione Exodus Comics application. Copyright (C) 2010 and above Paolo Insogna <p.insogna@me.com>.
# Licensed as stated in the COPYRIGHT file, which can be found in the root of the application.
#

module Cowtech
	module RubyOnRails
		module Models
			module Mongoid
				module Cowtech
					extend ActiveSupport::Concern

					# Uncomment for numeric ID
					# included do
					#   include Mongoid::Sequence
					#   identity type: Integer
					#   sequence :_id
					# end

					module ClassMethods
						def [](what, only_id = false)
							self.__finalize(self.__safe_index_find(what), only_id)
						end

						def find_or_create(oid, attributes = nil)
							self.safe_find(oid) || self.new(attributes)
						end

						def safe_find(oid)
							rv = oid.blank? ? nil : self.find(BSON::ObjectId(oid))
						rescue ::Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId
							nil
						end

						def random
							c = self.count
							c != 0 ? self.skip(rand(c)).first : nil
						end

						def per_page
							25
						end

						# Overrides for paranoia module to allow find associations on deleted documents
						def criteria(*args)
							rv = super
							rv.selector = {}
							rv
						end

						def not_deleted
							where(:deleted_at.exists => false)
						end

						def valid_object_id?(oid)
							oid.blank? || BSON::ObjectId.legal?(oid)
						end

						def __index_find(oid)
							oid.blank? ? nil : self.find(BSON::ObjectId(oid))
						rescue ::Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId
							nil
						end

						def __finalize(record, only_id = false)
							record ? (only_id ? record.id : record) : nil
						end

						def __safe_index_find(what)
							self.__index_find(what)
						rescue ::Mongoid::Errors::DocumentNotFound, BSON::InvalidObjectId
							nil
						end
					end

					module InstanceMethods
						# Decommentare for numeric type ids
						# def safe_id
						#   self.id ? self.id : 0
						# end

						def editable?(user = nil)
							true
						end

						def deletable?(user = nil)
							true
						end

						def delete(definitive = false)
							if definitive != true then
								if self.deletable? then
									super()
									true
								else
									false
								end
							else
								self.delete!
							end
						end

						def is?(other)
							other ? (self.id == self.class.__safe_index_find(other).id) : false
						end
					end
				end
			end
		end
	end
end
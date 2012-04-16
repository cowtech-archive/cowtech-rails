# encoding: utf-8
#
# This file is part of the Gestione Exodus Comics application. Copyright (C) 2010 and above Paolo Insogna <p.insogna@me.com>.
# Licensed as stated in the COPYRIGHT file, which can be found in the root of the application.
#

module Cowtech
	module RubyOnRails
		module Models
			module Mongoid
				# Include this module to add automatic sequence feature (also works for _id field, so SQL-Like autoincrement primary key can easily be simulated)
				# usage:
				# class KlassName
				#   include Mongoid::Document
				#   include Mongoid::Sequence
				# ...
				#   field :number, :type=>Integer
				#   sequence :number
				# ...
				module Sequence
					extend ActiveSupport::Concern

					module ClassMethods
						def sequence(_field)
							# REPLACE FIELD DEFAULT VALUE
							_field = _field.to_s
							field(_field, fields[_field].options.merge(default: lambda{ self.class.set_from_sequence(_field)}))
						end

						def set_from_sequence(_field)
							sequences = self.db.collection("__sequences")
							counter_id = "#{self.class.name.underscore}_#{_field}"

							# Increase the sequence value and also avoids conflicts
							catch(:value) do
								value = nil
								begin
									value = sequences.find_and_modify(
										query: {"_id" => counter_id},
											:update=> {"$inc" => {"value" => 1}},
											new: true,
											upsert: true
									).send("[]", "value")
								end while self.first({conditions: {_field => value}})
								throw :value, value
							end
						end

						def reset_sequence(_field)
							sequences = self.db.collection("__sequences")
							counter_id = "#{self.class.name.underscore}_#{_field.to_s}"
							sequences.find_and_modify(query: {"_id" => counter_id}, :update=> {"$set" => {"value" => 0}}, new: true, upsert: true)
						end
					end
				end
			end
		end
	end
end
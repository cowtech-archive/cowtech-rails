# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

Object.class_eval do
  include Cowtech::RoR::Extensions::Object
end

TrueClass.class_eval do
  include Cowtech::RoR::Extensions::True
end

FalseClass.class_eval do
  include Cowtech::RoR::Extensions::False
end

String.class_eval do
  include Cowtech::RoR::Extensions::String
end

Time.class_eval do
  include Cowtech::RoR::Extensions::DateTime
end

Date.class_eval do
  include Cowtech::RoR::Extensions::DateTime
end

DateTime.class_eval do
  include Cowtech::RoR::Extensions::DateTime
end

Hash.class_eval do
  include Cowtech::RoR::Extensions::Hash  
end

Pathname.class_eval do
  include Cowtech::RoR::Extensions::Pathname  
end
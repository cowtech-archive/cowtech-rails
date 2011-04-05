# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

if defined?(Rails) && Rails::VERSION::MAJOR == 3 then
  require 'engine' 
  require 'extensions' 
  require 'monkey_patches'
  
  dir = File.dirname(__FILE__) + '/../'
  require dir + '/app/models/e_mail'
  require dir + '/app/models/model_base'
end
